import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../database/db_helper.dart';
import '../models/patient.dart';
import '../theme/app_theme.dart';
import '../utils/file_helper.dart';

class AddEditPatientScreen extends StatefulWidget {
  final Patient? patient;

  const AddEditPatientScreen({super.key, this.patient});

  @override
  State<AddEditPatientScreen> createState() => _AddEditPatientScreenState();
}

class _AddEditPatientScreenState extends State<AddEditPatientScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _ageController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _diagnosisController;
  late TextEditingController _prescriptionController;
  late TextEditingController _notesController;

  late String _selectedGender;
  late String _selectedBloodGroup;
  late String _selectedStatus;
  String? _photoPath;
  bool _isSaving = false;

  final List<String> _bloodGroups = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];
  final List<String> _statuses = ['Active', 'Under Observation', 'Critical', 'Recovered'];

  @override
  void initState() {
    super.initState();
    final p = widget.patient;
    _nameController = TextEditingController(text: p?.name ?? '');
    _ageController = TextEditingController(text: p != null ? p.age.toString() : '');
    _phoneController = TextEditingController(text: p?.phone ?? '');
    _emailController = TextEditingController(text: p?.email ?? '');
    _diagnosisController = TextEditingController(text: p?.diagnosis ?? '');
    _prescriptionController = TextEditingController(text: p?.prescription ?? '');
    _notesController = TextEditingController(text: p?.notes ?? '');

    _selectedGender = p?.gender ?? 'Male';
    _selectedBloodGroup = p?.bloodGroup ?? 'O+';
    _selectedStatus = p?.status ?? 'Active';
    _photoPath = p?.photoPath;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _diagnosisController.dispose();
    _prescriptionController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(source: source, imageQuality: 85);
      if (picked != null) {
        final savedPath = await FileHelper.saveFileLocally(
          picked.path,
          subDir: 'patient_avatars',
        );
        setState(() {
          _photoPath = savedPath;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick image: $e'),
            backgroundColor: AppTheme.statusCritical,
          ),
        );
      }
    }
  }

  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Patient Profile Photo',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: AppTheme.primaryLight,
                  child: Icon(Icons.camera_alt_outlined, color: AppTheme.primaryDark),
                ),
                title: const Text('Take Photo with Camera'),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: AppTheme.primaryLight,
                  child: Icon(Icons.photo_library_outlined, color: AppTheme.primaryDark),
                ),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage(ImageSource.gallery);
                },
              ),
              if (_photoPath != null)
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppTheme.statusCritical.withValues(alpha: 0.1),
                    child: const Icon(Icons.delete_outline, color: AppTheme.statusCritical),
                  ),
                  title: const Text(
                    'Remove Photo',
                    style: TextStyle(color: AppTheme.statusCritical),
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    setState(() {
                      _photoPath = null;
                    });
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _savePatient() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSaving = true);

    try {
      final patient = Patient(
        id: widget.patient?.id,
        name: _nameController.text.trim(),
        age: int.tryParse(_ageController.text.trim()) ?? 0,
        gender: _selectedGender,
        phone: _phoneController.text.trim(),
        email: _emailController.text.trim(),
        bloodGroup: _selectedBloodGroup,
        diagnosis: _diagnosisController.text.trim(),
        prescription: _prescriptionController.text.trim(),
        notes: _notesController.text.trim(),
        photoPath: _photoPath,
        status: _selectedStatus,
        createdAt: widget.patient?.createdAt ?? DateTime.now(),
      );

      if (widget.patient == null) {
        await DatabaseHelper.instance.insertPatient(patient);
      } else {
        await DatabaseHelper.instance.updatePatient(patient);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.patient == null
                  ? 'Patient profile registered successfully!'
                  : 'Patient profile updated successfully!',
            ),
            backgroundColor: AppTheme.statusActive,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save patient: $e'),
            backgroundColor: AppTheme.statusCritical,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.patient != null;
    final hasPhoto = FileHelper.hasValidImage(_photoPath);

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Patient Record' : 'Register New Patient'),
        actions: [
          TextButton.icon(
            onPressed: _isSaving ? null : _savePatient,
            icon: _isSaving
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primaryTeal),
                  )
                : const Icon(Icons.check, color: AppTheme.primaryTeal),
            label: Text(
              isEditing ? 'Update' : 'Save',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryTeal,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Avatar picker card
            Center(
              child: Stack(
                children: [
                  GestureDetector(
                    onTap: _showImagePickerOptions,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryLight,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: AppTheme.primaryTeal, width: 2),
                        image: hasPhoto
                            ? DecorationImage(
                                image: FileHelper.getImageProvider(_photoPath!),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      alignment: Alignment.center,
                      child: !hasPhoto
                          ? const Icon(
                              Icons.person_add_alt_1_rounded,
                              size: 40,
                              color: AppTheme.primaryDark,
                            )
                          : null,
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: _showImagePickerOptions,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryTeal,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                hasPhoto ? 'Tap to change photo' : 'Add Patient Photo (Optional)',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Section: Personal Information
            _buildSectionCard(
              title: 'Personal Information',
              icon: Icons.person_outline_rounded,
              children: [
                TextFormField(
                  controller: _nameController,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Full Name *',
                    hintText: 'e.g., John Doe',
                    prefixIcon: Icon(Icons.badge_outlined, size: 20),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Please enter patient name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: TextFormField(
                        controller: _ageController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Age *',
                          hintText: 'e.g., 34',
                          prefixIcon: Icon(Icons.cake_outlined, size: 20),
                        ),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'Enter age';
                          }
                          final parsed = int.tryParse(val.trim());
                          if (parsed == null || parsed <= 0 || parsed > 130) {
                            return 'Valid age';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 1,
                      child: DropdownButtonFormField<String>(
                        initialValue: _selectedBloodGroup,
                        decoration: const InputDecoration(
                          labelText: 'Blood Group',
                          prefixIcon: Icon(Icons.bloodtype_outlined, size: 20),
                        ),
                        items: _bloodGroups
                            .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedBloodGroup = val);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                // Gender segmented selector
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Gender',
                      style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
                    ),
                    const SizedBox(height: 6),
                    SizedBox(
                      width: double.infinity,
                      child: SegmentedButton<String>(
                        segments: const [
                          ButtonSegment(value: 'Male', label: Text('Male'), icon: Icon(Icons.male)),
                          ButtonSegment(value: 'Female', label: Text('Female'), icon: Icon(Icons.female)),
                          ButtonSegment(value: 'Other', label: Text('Other'), icon: Icon(Icons.transgender)),
                        ],
                        selected: {_selectedGender},
                        onSelectionChanged: (val) {
                          setState(() => _selectedGender = val.first);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Contact Phone *',
                    hintText: 'e.g., +1 (555) 000-0000',
                    prefixIcon: Icon(Icons.phone_outlined, size: 20),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Please enter phone number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email Address (Optional)',
                    hintText: 'e.g., patient@example.com',
                    prefixIcon: Icon(Icons.mail_outline, size: 20),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Section: Medical Status & Clinical Info
            _buildSectionCard(
              title: 'Medical Diagnosis & Care',
              icon: Icons.medical_services_outlined,
              children: [
                DropdownButtonFormField<String>(
                  initialValue: _selectedStatus,
                  decoration: const InputDecoration(
                    labelText: 'Current Status',
                    prefixIcon: Icon(Icons.health_and_safety_outlined, size: 20),
                  ),
                  items: _statuses
                      .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedStatus = val);
                  },
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _diagnosisController,
                  textCapitalization: TextCapitalization.sentences,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Diagnosis / Condition *',
                    hintText: 'e.g., Acute Bronchitis, Hypertension...',
                    prefixIcon: Icon(Icons.healing_outlined, size: 20),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Please specify diagnosis or reason for visit';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _prescriptionController,
                  textCapitalization: TextCapitalization.sentences,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Prescription & Dosages',
                    hintText: 'e.g., Amoxicillin 500mg tid for 7 days...',
                    prefixIcon: Icon(Icons.medication_outlined, size: 20),
                  ),
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _notesController,
                  textCapitalization: TextCapitalization.sentences,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Doctor Clinical Notes & Observations',
                    hintText: 'e.g., Vitals stable, schedule follow-up next Tuesday...',
                    prefixIcon: Icon(Icons.note_alt_outlined, size: 20),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _isSaving ? null : _savePatient,
                icon: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.save_outlined),
                label: Text(
                  _isSaving
                      ? 'Saving Record...'
                      : (isEditing ? 'Update Patient Record' : 'Register Patient Record'),
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    ),
  );
}

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: AppTheme.primaryTeal),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            ...children,
          ],
        ),
      ),
    );
  }
}
