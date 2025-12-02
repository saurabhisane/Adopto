import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/pet_service.dart';
import '../providers/auth_provider.dart';

class AddPetScreen extends StatefulWidget {
  const AddPetScreen({super.key});

  @override
  State<AddPetScreen> createState() => _AddPetScreenState();
}

class _AddPetScreenState extends State<AddPetScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtl = TextEditingController();
  final _breedCtl = TextEditingController();
  final _categoryCtl = TextEditingController();
  final _ageCtl = TextEditingController();
  final _imageCtl = TextEditingController();
  String _gender = 'male';
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _nameCtl.dispose();
    _breedCtl.dispose();
    _categoryCtl.dispose();
    _ageCtl.dispose();
    _imageCtl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _submitting = true;
      _error = null;
    });

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final token = auth.token;

    final payload = {
      'name': _nameCtl.text.trim(),
      'breed': _breedCtl.text.trim(),
      'category': _categoryCtl.text.trim(),
      'age': _ageCtl.text.trim(),
      'gender': _gender,
      'image': _imageCtl.text.trim(),
    };

    final ok = await PetService.createPet(payload, token: token);
    if (ok) {
      if (mounted) Navigator.of(context).pop(true);
      return;
    }

    setState(() {
      _error = 'Failed to add pet';
      _submitting = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Add Pet for Adoption',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Form Title
                const Text(
                  'Pet Information',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),

                const SizedBox(height: 24),

                // Name Field
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Name',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: TextFormField(
                        controller: _nameCtl,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          hintText: 'Enter pet name',
                          hintStyle: TextStyle(color: Colors.grey),
                        ),
                        validator: (v) =>
                            (v == null || v.trim().isEmpty) ? 'Required' : null,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Breed Field
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Breed',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: TextFormField(
                        controller: _breedCtl,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          hintText: 'Enter breed',
                          hintStyle: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Category Field
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    const Text(
                      'Category (e.g., Cats, Dogs)',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: DropdownButtonFormField<String>(
                          value: _categoryCtl.text.isEmpty
                              ? null
                              : _categoryCtl.text,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                          ),
                          hint: const Text('Select category'),
                          items: const [
                            DropdownMenuItem(
                              value: 'Dogs',
                              child: Text('Dogs'),
                            ),
                            DropdownMenuItem(
                              value: 'Cats',
                              child: Text('Cats'),
                            ),
                            DropdownMenuItem(
                              value: 'Birds',
                              child: Text('Birds'),
                            ),
                            DropdownMenuItem(
                              value: 'Rabbits',
                              child: Text('Rabbits'),
                            ),
                            DropdownMenuItem(
                              value: 'Hamsters',
                              child: Text('Hamsters'),
                            ),
                          ],
                          validator: (v) =>
                              (v == null || v.isEmpty) ? 'Required' : null,
                          onChanged: (v) {
                            if (v == null) return;
                            setState(() => _categoryCtl.text = v);
                          },
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Age Field
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Age (e.g., 2 years)',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: TextFormField(
                        controller: _ageCtl,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          hintText: 'Enter age',
                          hintStyle: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Gender Field
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Gender',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: DropdownButtonFormField<String>(
                          value: _gender,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'male',
                              child: Text('Male'),
                            ),
                            DropdownMenuItem(
                              value: 'female',
                              child: Text('Female'),
                            ),
                          ],
                          onChanged: (v) {
                            if (v == null) return;
                            setState(() => _gender = v);
                          },
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Image URL Field
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Image URL (optional)',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: TextFormField(
                        controller: _imageCtl,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          hintText: 'Enter image URL',
                          hintStyle: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // Divider (matching the image)
                const Divider(color: Colors.grey, height: 1),

                const SizedBox(height: 24),

                // Error Message
                if (_error != null)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red[100]!),
                    ),
                    child: Text(
                      _error!,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  ),

                if (_error != null) const SizedBox(height: 16),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _submitting ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromRGBO(244, 103, 52, 1),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    child: _submitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : const Text(
                            'Add Pet',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
