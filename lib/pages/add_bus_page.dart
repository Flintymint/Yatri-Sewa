import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yatrisewa/datasource/temp_db.dart';
import 'package:yatrisewa/providers/app_data_provider.dart';
import 'package:yatrisewa/utils/helper_functions.dart';
import '../drawers/main_drawer.dart';
import '../models/bus_model.dart';
import '../utils/constants.dart';

class AddBusPage extends StatefulWidget {
  const AddBusPage({Key? key}) : super(key: key);

  @override
  State<AddBusPage> createState() => _AddBusPageState();
}

class _AddBusPageState extends State<AddBusPage> {
  final _formKey = GlobalKey<FormState>();
  String? busType;
  final seatController = TextEditingController();
  final nameController = TextEditingController();
  final numberController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const MainDrawer(),
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Add Bus'),
        backgroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.view_list, color: Colors.white),
            onPressed: () {
              Navigator.pushNamed(context, routeNameViewBuses);
            },
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDropdownField('Select Bus Type', busTypes),
                const SizedBox(height: 12),
                _buildTextField(nameController, 'Bus Name', Icons.directions_bus),
                _buildTextField(numberController, 'Bus Number', Icons.confirmation_number),
                _buildTextField(seatController, 'Total Seats', Icons.event_seat, isNumber: true),
                const SizedBox(height: 20),
                _buildSubmitButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownField(String hint, List<String> items) {
    return DropdownButtonFormField<String>(
      value: busType,
      style: const TextStyle(color: Colors.white, fontSize: 16),
      decoration: _underlinedInputDecoration(hint, Icons.directions_bus_filled),
      dropdownColor: Colors.black,
      onChanged: (value) => setState(() => busType = value),
      validator: (value) => value == null ? 'Please select a Bus Type' : null,
      items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, IconData icon, {bool isNumber = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        style: const TextStyle(color: Colors.white, fontSize: 16),
        decoration: _underlinedInputDecoration(hint, icon),
        validator: (value) => value == null || value.isEmpty ? 'This field cannot be empty' : null,
      ),
    );
  }

  // Input decoration with underline
  InputDecoration _underlinedInputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey[400], fontSize: 16),
      filled: true,
      fillColor: Colors.black,
      prefixIcon: Icon(icon, color: Colors.white),
      enabledBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.grey),
      ),
      focusedBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.white),
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
    );
  }

  // "ADD BUS" button (No underline)
  Widget _buildSubmitButton() {
    return Center(
      child: SizedBox(
        width: 150,
        child: ElevatedButton(
          onPressed: addBus,
          child: const Text('ADD BUS', style: TextStyle(fontSize: 16)),
        ),
      ),
    );
  }

  // Function to add a bus
  void addBus() {
    if (_formKey.currentState!.validate()) {
      final bus = Bus(
        busId: TempDB.tableBus.length + 1,
        busName: nameController.text,
        busNumber: numberController.text,
        busType: busType!,
        totalSeat: int.parse(seatController.text),
      );
      Provider.of<AppDataProvider>(context, listen: false)
          .addBus(bus)
          .then((response){
        if(response.responseStatus == ResponseStatus.SAVED){
          showMsg(context, response.message);
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bus added successfully!')),
      );

      resetFields();
    }
  }

  // Reset form fields
  void resetFields() {
    nameController.clear();
    numberController.clear();
    seatController.clear();
    setState(() => busType = null);
  }

  @override
  void dispose() {
    seatController.dispose();
    nameController.dispose();
    numberController.dispose();
    super.dispose();
  }
}
