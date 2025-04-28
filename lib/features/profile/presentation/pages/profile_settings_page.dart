import 'dart:io';
import 'package:drive/config.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:drive/features/auth/data/user_session.dart';
import 'package:path/path.dart' as path;

class ProfileSettingsPage extends StatefulWidget {
  const ProfileSettingsPage({Key? key}) : super(key: key);

  @override
  State<ProfileSettingsPage> createState() => _ProfileSettingsPageState();
}

class _ProfileSettingsPageState extends State<ProfileSettingsPage> {
  File? _imageFile;
  bool _uploading = false;
  bool _updatingPassword = false;
  String? _profileImageUrl;
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _showNewPassword = false;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _uploadProfilePicture() async {
    if (_imageFile == null) return;
    setState(() { _uploading = true; });
    try {
      final uri = Uri.parse('${AppConfig.backendBaseUrl}/api/auth/upload-profile-picture');
      final request = http.MultipartRequest('POST', uri)
        ..headers['Authorization'] = 'Bearer ${UserSession.token}'
        ..files.add(await http.MultipartFile.fromPath('file', _imageFile!.path));
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      if (response.statusCode == 200) {
        setState(() {
          _profileImageUrl = _getProfileImageUrlFromFilename(_imageFile!.path);
          _uploading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile picture updated!')),
        );
      } else {
        setState(() { _uploading = false; });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to upload profile picture.')),
        );
      }
    } catch (e) { 
      setState(() { _uploading = false; });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error uploading profile picture: ${e.toString()}')),
      );
    }
  }

  String _getProfileImageUrlFromFilename(String filePath) {
    final filename = path.basename(filePath);
    return '${AppConfig.backendBaseUrl}/uploads/$filename';
  }

  Future<void> _updatePassword() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _updatingPassword = true; });
    try {
      final uri = Uri.parse('${AppConfig.backendBaseUrl}/api/auth/update-password');
      final body = '{"oldPassword": "${_oldPasswordController.text}", "newPassword": "${_newPasswordController.text}"}';
      final response = await http.post(
        uri,
        headers: {
          'Authorization': 'Bearer ${UserSession.token}',
          'Content-Type': 'application/json',
        },
        body: body,
      );
      if (response.statusCode == 200) {
        setState(() { _updatingPassword = false; });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password updated successfully!')),
        );
      } else {
        setState(() { _updatingPassword = false; });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update password.')),
        );
      }
    } catch (e) {
      setState(() { _updatingPassword = false; });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating password: ${e.toString()}')),
      );
    }
  }

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile Settings'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 56,
                    backgroundImage: _imageFile != null
                        ? FileImage(_imageFile!)
                        : (_profileImageUrl != null
                            ? NetworkImage(_profileImageUrl!)
                            : const AssetImage('assets/images/default_avatar.png')) as ImageProvider,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: InkWell(
                      onTap: _pickImage,
                      child: Container(
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          shape: BoxShape.circle,
                        ),
                        padding: const EdgeInsets.all(8),
                        child: const Icon(Icons.edit, color: Colors.white, size: 20),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: ElevatedButton.icon(
                onPressed: _uploading ? null : _uploadProfilePicture,
                icon: _uploading
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.upload),
                label: const Text('Upload Profile Picture'),
                style: ElevatedButton.styleFrom(minimumSize: const Size(200, 40)),
              ),
            ),
            const Divider(height: 40),
            Text('Change Password', style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.primary)),
            const SizedBox(height: 10),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _oldPasswordController,
                    obscureText: true,
                    style: TextStyle(color: theme.colorScheme.onSurface),
                    decoration: InputDecoration(
                      labelText: 'Current Password',
                      labelStyle: TextStyle(color: theme.colorScheme.primary),
                      border: const OutlineInputBorder(),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: theme.colorScheme.primary.withOpacity(0.6)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
                      ),
                      suffixIcon: const Icon(Icons.lock, color: Color(0xFF39D353)),
                    ),
                    validator: (val) => val == null || val.isEmpty ? 'Enter your current password' : null,
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _newPasswordController,
                    obscureText: !_showNewPassword,
                    style: TextStyle(color: theme.colorScheme.onSurface),
                    decoration: InputDecoration(
                      labelText: 'New Password',
                      labelStyle: TextStyle(color: theme.colorScheme.primary),
                      border: const OutlineInputBorder(),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: theme.colorScheme.primary.withOpacity(0.6)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(_showNewPassword ? Icons.visibility : Icons.visibility_off, color: theme.colorScheme.primary),
                        onPressed: () {
                          setState(() {
                            _showNewPassword = !_showNewPassword;
                          });
                        },
                      ),
                    ),
                    validator: (val) => val == null || val.length < 6 ? 'Password must be at least 6 characters' : null,
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: theme.colorScheme.onPrimary,
                        textStyle: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      onPressed: _updatingPassword ? null : _updatePassword,
                      child: _updatingPassword
                          ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                          : const Text('Update Password'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
