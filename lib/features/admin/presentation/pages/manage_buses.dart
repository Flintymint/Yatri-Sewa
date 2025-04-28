import 'package:drive/config.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:drive/features/admin/data/bus_category_repository.dart';
import 'package:drive/features/auth/data/user_session.dart';

class ManageBusesPage extends StatefulWidget {
  const ManageBusesPage({super.key});

  @override
  State<ManageBusesPage> createState() => _ManageBusesPageState();
}

class _ManageBusesPageState extends State<ManageBusesPage> {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedCategoryId;
  String? _selectedAvailability;
  bool _isLoading = false;
  List<dynamic> _buses = [];
  List<Map<String, dynamic>> _categories = [];

  @override
  void initState() {
    super.initState();
    _fetchCategoriesAndBuses();
  }

  Future<void> _fetchCategoriesAndBuses() async {
    setState(() => _isLoading = true);
    final cats = await BusCategoryRepository.fetchCategories();
    setState(() {
      _categories = cats;
    });
    await _fetchBuses();
  }

  Future<void> _fetchBuses() async {
    setState(() => _isLoading = true);
    try {
      final query = <String, String>{};
      if (_searchController.text.trim().isNotEmpty) {
        query['busNumber'] = _searchController.text.trim();
      }
      if (_selectedCategoryId != null) {
        query['categoryId'] = _selectedCategoryId!;
      }
      if (_selectedAvailability != null) {
        query['available'] = _selectedAvailability == 'available' ? 'true' : 'false';
      }
      final uri = Uri.parse('${AppConfig.backendBaseUrl}/api/buses/search').replace(queryParameters: query.isEmpty ? null : query);
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        setState(() {
          _buses = List.from(json.decode(response.body));
          _isLoading = false;
        });
      } else {
        setState(() {
          _buses = [];
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _buses = [];
        _isLoading = false;
      });
    }
  }

  Future<bool> _addBus(String busNumber, String busCategoryId) async {
    setState(() => _isLoading = true);
    try {
      final token = UserSession.token;
      final uri = Uri.parse('${AppConfig.backendBaseUrl}/api/buses');
      final body = jsonEncode({
        'busNumber': busNumber,
        'busCategoryId': int.parse(busCategoryId),
      });
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: body,
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        await _fetchBuses();
        return true;
      }
    } catch (e) {}
    setState(() => _isLoading = false);
    return false;
  }

  Future<void> _deleteBus(dynamic busId) async {
    setState(() => _isLoading = true);
    final token = UserSession.token;
    final headers = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
    final uri = Uri.parse('${AppConfig.backendBaseUrl}/api/buses/$busId');
    final response = await http.delete(uri, headers: headers);
    if (response.statusCode == 200 || response.statusCode == 204) {
      await _fetchBuses();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bus deleted'), backgroundColor: Colors.green),
      );
    } else {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete bus'), backgroundColor: Theme.of(context).colorScheme.error),
      );
    }
  }

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _selectedCategoryId = null;
      _selectedAvailability = null;
    });
    _fetchBuses();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Manage Buses'),
        centerTitle: true,
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search Bus number',
                      filled: true,
                      fillColor: colorScheme.surfaceContainerHighest,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Material(
                  color: colorScheme.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: _fetchBuses,
                    child: const Padding(
                      padding: EdgeInsets.all(12.0),
                      child: Icon(Icons.search, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedCategoryId,
                    decoration: InputDecoration(
                      labelText: 'Category',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: colorScheme.surfaceContainerHighest,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                    ),
                    items: _categories.map((cat) => DropdownMenuItem(
                      value: cat['id'].toString(),
                      child: Text(cat['name'] ?? ''),
                    )).toList(),
                    onChanged: (val) {
                      setState(() => _selectedCategoryId = val);
                      _fetchBuses();
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedAvailability,
                    decoration: InputDecoration(
                      labelText: 'Availability',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: colorScheme.surfaceContainerHighest,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'available', child: Text('Available')),
                      DropdownMenuItem(value: 'unavailable', child: Text('Unavailable')),
                    ],
                    onChanged: (val) {
                      setState(() => _selectedAvailability = val);
                      _fetchBuses();
                    },
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: Icon(Icons.clear, color: colorScheme.primary),
                  tooltip: 'Clear filters',
                  onPressed: _clearFilters,
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Bus list area
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _buses.isEmpty
                      ? Center(
                          child: Text(
                            'No Buses Available',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurface.withOpacity(0.8),
                            ),
                          ),
                        )
                      : ListView.builder(
                          itemCount: _buses.length,
                          itemBuilder: (context, index) {
                            final bus = _buses[index];
                            final isAvailable = bus['available'] == true;
                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              color: colorScheme.surfaceContainerHighest,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Text(
                                                bus['busNumber'] ?? '',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 20,
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              Icon(
                                                Icons.circle,
                                                color: isAvailable ? Colors.green : Colors.red,
                                                size: 16,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                isAvailable ? 'Available' : 'Unavailable',
                                                style: TextStyle(
                                                  color: isAvailable ? Colors.green : Colors.red,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            bus['category']?['name'] ?? '',
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: bus['available'] == true
                                          ? null
                                          : () {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(
                                                  content: Text('Only available buses can be deleted'),
                                                  backgroundColor: Colors.orange,
                                                ),
                                              );
                                            },
                                      child: IconButton(
                                        icon: Icon(Icons.delete_outline, color: colorScheme.error, size: 32),
                                        tooltip: bus['available'] == true ? 'Delete bus' : 'Only available buses can be deleted',
                                        onPressed: bus['available'] == true
                                            ? () async {
                                                final confirm = await showDialog<bool>(
                                                  context: context,
                                                  builder: (ctx) => AlertDialog(
                                                    title: const Text('Delete Bus'),
                                                    content: Text('Are you sure you want to delete bus "${bus['busNumber']}"?'),
                                                    actions: [
                                                      TextButton(
                                                        onPressed: () => Navigator.of(ctx).pop(false),
                                                        child: const Text('Cancel'),
                                                      ),
                                                      ElevatedButton(
                                                        onPressed: () => Navigator.of(ctx).pop(true),
                                                        style: ElevatedButton.styleFrom(backgroundColor: colorScheme.error),
                                                        child: const Text('Delete'),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                                if (confirm == true) {
                                                  await _deleteBus(bus['id']);
                                                }
                                              }
                                            : null,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await showDialog<bool>(
            context: context,
            builder: (ctx) => _AddBusDialog(
              categories: _categories,
              onAddBus: _addBus,
            ),
          );
          if (result == true) {
            _fetchBuses();
          }
        },
        icon: Icon(Icons.add, color: colorScheme.onPrimary),
        label: const Text('Add a bus'),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

class _AddBusDialog extends StatefulWidget {
  final List<Map<String, dynamic>> categories;
  final Future<bool> Function(String, String) onAddBus;
  const _AddBusDialog({required this.categories, required this.onAddBus});

  @override
  State<_AddBusDialog> createState() => _AddBusDialogState();
}

class _AddBusDialogState extends State<_AddBusDialog> {
  final TextEditingController _busNumberController = TextEditingController();
  String? _selectedCategoryId;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _busNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add a bus'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _busNumberController,
            decoration: const InputDecoration(
              labelText: 'Bus Number',
            ),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _selectedCategoryId,
            items: widget.categories
                .map((cat) => DropdownMenuItem(
                      value: cat['id'].toString(),
                      child: Text(cat['name'] ?? ''),
                    ))
                .toList(),
            onChanged: (val) => setState(() => _selectedCategoryId = val),
            decoration: const InputDecoration(
              labelText: 'Category',
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(false);
          },
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isSubmitting
              ? null
              : () async {
                  final busNumber = _busNumberController.text.trim();
                  final catId = _selectedCategoryId;
                  if (busNumber.isEmpty || catId == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Bus number and category are required')),
                    );
                    return;
                  }
                  setState(() => _isSubmitting = true);
                  final success = await widget.onAddBus(busNumber, catId);
                  setState(() => _isSubmitting = false);
                  if (success) {
                    Navigator.of(context).pop(true);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Failed to add bus')),
                    );
                  }
                },
          child: _isSubmitting ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Add'),
        ),
      ],
    );
  }
}
