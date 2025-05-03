import 'package:flutter/material.dart';
import 'package:pmu_parking/utils/theme.dart';
import 'package:provider/provider.dart';
import '../models/app_state.dart';
import '../models/user.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _plateController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final user = Provider.of<AppState>(context, listen: false).currentUser;
    _nameController = TextEditingController(text: user?.name ?? '');
    _phoneController = TextEditingController(text: user?.phoneNumber ?? '');
    _plateController = TextEditingController(text: user?.carPlateNumber ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _plateController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final success = await Provider.of<AppState>(
      context,
      listen: false,
    ).updateUserProfile(
      name: _nameController.text.trim(),
      phoneNumber:
          _phoneController.text.trim().isEmpty
              ? null
              : _phoneController.text.trim(),
      carPlateNumber:
          _plateController.text.trim().isEmpty
              ? null
              : _plateController.text.trim(),
    );

    setState(() {
      _isLoading = false;
    });

    if (success) {
      if (mounted) {
        // Force refresh of user data after updating profile
        await Provider.of<AppState>(
          context,
          listen: false,
        ).refreshCurrentUser();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(
          context,
          true,
        ); // Pass back true to indicate successful update
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to update profile'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AppState>(context).currentUser;
    if (user == null) {
      return const Scaffold(body: Center(child: Text('User not logged in')));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveProfile,
            child:
                _isLoading
                    ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                    : const Text(
                      'SAVE',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Image Section
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Theme.of(
                        context,
                      ).primaryColor.withOpacity(0.1),
                      child: Text(
                        _getUserTypeIcon(user.userType),
                        style: const TextStyle(fontSize: 40),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      user.userTypeToString,
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Form Fields
              const Text(
                'Personal Information',
                style: AppTheme.subheadingStyle,
              ),
              const SizedBox(height: 16),

              // Name Field
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Email Field (disabled, can't be changed)
              TextFormField(
                initialValue: user.email,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email_outlined),
                  helperText: 'Email cannot be changed',
                ),
                enabled: false,
              ),
              const SizedBox(height: 16),

              // Phone Field
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone_outlined),
                  hintText: 'e.g. +966 50 123 4567',
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),

              // Car Plate Field
              TextFormField(
                controller: _plateController,
                decoration: const InputDecoration(
                  labelText: 'Vehicle Plate Number',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.directions_car_outlined),
                  hintText: 'e.g. PMU 1234',
                ),
                textCapitalization: TextCapitalization.characters,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getUserTypeIcon(UserType userType) {
    switch (userType) {
      case UserType.student:
        return '🎓';
      case UserType.faculty:
        return '👨‍🏫';
      case UserType.staff:
        return '👩‍💼';
      case UserType.security:
        return '👮';
      case UserType.visitor:
        return '👋';
      default:
        return '👤';
    }
  }
}
