import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../database/db_helper.dart';
import '../models/patient.dart';
import '../models/patient_document.dart';
import '../theme/app_theme.dart';
import '../utils/file_helper.dart';
import '../widgets/document_tile.dart';
import '../widgets/status_badge.dart';
import 'add_edit_patient_screen.dart';
import 'document_viewer_screen.dart';

class PatientDetailsScreen extends StatefulWidget {
  final int patientId;

  const PatientDetailsScreen({super.key, required this.patientId});

  @override
  State<PatientDetailsScreen> createState() => _PatientDetailsScreenState();
}

class _PatientDetailsScreenState extends State<PatientDetailsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Patient? _patient;
  List<PatientDocument> _documents = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadPatientData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadPatientData() async {
    setState(() => _isLoading = true);
    try {
      final patient = await DatabaseHelper.instance.getPatientById(widget.patientId);
      final docs = await DatabaseHelper.instance.getDocumentsForPatient(widget.patientId);
      if (mounted) {
        setState(() {
          _patient = patient;
          _documents = docs;
        });
      }
    } catch (e) {
      debugPrint('Error loading patient details: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _deletePatient() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Patient Record?'),
        content: Text(
          'Are you sure you want to delete ${_patient?.name}? All associated medical documents and records will be permanently removed.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.statusCritical),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await DatabaseHelper.instance.deletePatient(widget.patientId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Patient record deleted successfully'),
            backgroundColor: AppTheme.textPrimary,
          ),
        );
        Navigator.pop(context, true);
      }
    }
  }

  Future<void> _uploadDocumentModal() async {
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
                'Upload Medical Document or Image',
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
                title: const Text('Capture with Camera'),
                subtitle: const Text('X-Ray, physical prescription, lab sheet'),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImageAndSave(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: AppTheme.primaryLight,
                  child: Icon(Icons.photo_library_outlined, color: AppTheme.primaryDark),
                ),
                title: const Text('Choose Image from Gallery'),
                subtitle: const Text('Photos, scans, charts'),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImageAndSave(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: AppTheme.primaryLight,
                  child: Icon(Icons.upload_file_rounded, color: AppTheme.primaryDark),
                ),
                title: const Text('Pick PDF or Document File'),
                subtitle: const Text('PDF lab reports, discharge summaries'),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickDocumentFile();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickImageAndSave(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(source: source);
      if (picked != null) {
        final title = await _promptDocumentTitle(defaultTitle: 'Medical Image');
        if (title != null && title.trim().isNotEmpty) {
          final fileSize = await picked.length();
          final savedPath = await FileHelper.saveFileLocally(picked.path);

          final doc = PatientDocument(
            patientId: widget.patientId,
            title: title.trim(),
            filePath: savedPath,
            fileType: 'image',
            fileSize: fileSize,
          );

          await DatabaseHelper.instance.insertDocument(doc);
          _loadPatientData();

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Document uploaded successfully!'),
                backgroundColor: AppTheme.statusActive,
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error uploading document: $e'),
            backgroundColor: AppTheme.statusCritical,
          ),
        );
      }
    }
  }

  Future<void> _pickDocumentFile() async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'txt', 'png', 'jpg', 'jpeg'],
      );

      if (result.isNotEmpty && result.first.path != null) {
        final filePath = result.first.path!;
        final originalName = result.first.name;
        final fileSize = await File(filePath).length().catchError((_) => 0);

        final title = await _promptDocumentTitle(
          defaultTitle: originalName.replaceAll(RegExp(r'\.[^.]+$'), ''),
        );

        if (title != null && title.trim().isNotEmpty) {
          final savedPath = await FileHelper.saveFileLocally(filePath);
          final fileType = FileHelper.getFileType(savedPath);

          final doc = PatientDocument(
            patientId: widget.patientId,
            title: title.trim(),
            filePath: savedPath,
            fileType: fileType,
            fileSize: fileSize,
          );

          await DatabaseHelper.instance.insertDocument(doc);
          _loadPatientData();

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Document uploaded successfully!'),
                backgroundColor: AppTheme.statusActive,
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking file: $e'),
            backgroundColor: AppTheme.statusCritical,
          ),
        );
      }
    }
  }

  Future<String?> _promptDocumentTitle({required String defaultTitle}) async {
    final controller = TextEditingController(text: defaultTitle);
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Document Title'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter a descriptive title for this document:',
              style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              autofocus: true,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                hintText: 'e.g., Blood Test Report, MRI Scan',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, null),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, controller.text),
            child: const Text('Save Document'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteDocument(PatientDocument doc) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Document?'),
        content: Text('Are you sure you want to delete "${doc.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.statusCritical),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && doc.id != null) {
      await DatabaseHelper.instance.deleteDocument(doc.id!);
      _loadPatientData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Document deleted'),
            backgroundColor: AppTheme.textPrimary,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppTheme.primaryTeal),
        ),
      );
    }

    final p = _patient;
    if (p == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Patient Not Found')),
        body: const Center(child: Text('Patient record does not exist.')),
      );
    }

    final hasPhoto = FileHelper.hasValidImage(p.photoPath);
    final createdDateStr = DateFormat('MMMM d, yyyy').format(p.createdAt);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Patient Overview'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit Patient',
            onPressed: () async {
              final updated = await Navigator.push<bool>(
                context,
                MaterialPageRoute(
                  builder: (context) => AddEditPatientScreen(patient: p),
                ),
              );
              if (updated == true) {
                _loadPatientData();
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppTheme.statusCritical),
            tooltip: 'Delete Patient',
            onPressed: _deletePatient,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
        children: [
          // Header Card
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryLight,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppTheme.primaryTeal.withValues(alpha: 0.3), width: 1.5),
                        image: hasPhoto
                            ? DecorationImage(
                                image: FileHelper.getImageProvider(p.photoPath!),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      alignment: Alignment.center,
                      child: !hasPhoto
                          ? Text(
                              p.name.isNotEmpty
                                  ? p.name.trim().split(' ').map((e) => e[0]).take(2).join().toUpperCase()
                                  : 'P',
                              style: const TextStyle(
                                color: AppTheme.primaryDark,
                                fontWeight: FontWeight.bold,
                                fontSize: 24,
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  p.name,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.textPrimary,
                                  ),
                                ),
                              ),
                              StatusBadge(status: p.status),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Text(
                                '${p.age} years old • ${p.gender}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryLight,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  'Blood: ${p.bloodGroup}',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.primaryDark,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.phone_outlined, size: 14, color: AppTheme.textMuted),
                              const SizedBox(width: 4),
                              Text(
                                p.phone,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                              if (p.email.isNotEmpty) ...[
                                const SizedBox(width: 12),
                                const Icon(Icons.email_outlined, size: 14, color: AppTheme.textMuted),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    p.email,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppTheme.textSecondary,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Tabs
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: AppTheme.primaryTeal,
              unselectedLabelColor: AppTheme.textSecondary,
              indicatorColor: AppTheme.primaryTeal,
              indicatorWeight: 3,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              tabs: [
                const Tab(
                  icon: Icon(Icons.medical_information_outlined, size: 18),
                  text: 'Medical Records',
                ),
                Tab(
                  icon: const Icon(Icons.attach_file_rounded, size: 18),
                  text: 'Documents (${_documents.length})',
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppTheme.border),

          // Tab Views
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Medical Records Tab
                ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _buildInfoCard(
                      icon: Icons.healing_outlined,
                      title: 'Diagnosis & Condition',
                      content: p.diagnosis.isNotEmpty ? p.diagnosis : 'No diagnosis specified.',
                      isPrimary: true,
                    ),
                    const SizedBox(height: 12),
                    _buildInfoCard(
                      icon: Icons.medication_outlined,
                      title: 'Prescribed Medication',
                      content: p.prescription.isNotEmpty ? p.prescription : 'No medications currently prescribed.',
                    ),
                    const SizedBox(height: 12),
                    _buildInfoCard(
                      icon: Icons.note_alt_outlined,
                      title: 'Clinical Observations & Notes',
                      content: p.notes.isNotEmpty ? p.notes : 'No clinical notes recorded.',
                    ),
                    const SizedBox(height: 12),
                    _buildInfoCard(
                      icon: Icons.calendar_today_outlined,
                      title: 'Registration Info',
                      content: 'Patient record created on $createdDateStr\nRecord ID: #${p.id}',
                    ),
                  ],
                ),

                // Documents Tab
                _documents.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: const BoxDecoration(
                                  color: AppTheme.primaryLight,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.file_upload_outlined,
                                  size: 48,
                                  color: AppTheme.primaryDark,
                                ),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'No Medical Documents Yet',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Attach medical test reports, prescriptions, X-rays, or scans for this patient.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 20),
                              ElevatedButton.icon(
                                onPressed: _uploadDocumentModal,
                                icon: const Icon(Icons.add),
                                label: const Text('Upload Document / Image'),
                              ),
                            ],
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _documents.length,
                        itemBuilder: (context, index) {
                          final doc = _documents[index];
                          return DocumentTile(
                            document: doc,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DocumentViewerScreen(document: doc),
                                ),
                              );
                            },
                            onDelete: () => _deleteDocument(doc),
                          );
                        },
                      ),
              ],
            ),
          ),
        ],
      ),
    ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _uploadDocumentModal,
        icon: const Icon(Icons.upload_file_rounded),
        label: const Text('Upload Document'),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String content,
    bool isPrimary = false,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  size: 18,
                  color: isPrimary ? AppTheme.primaryTeal : AppTheme.secondaryNavy,
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isPrimary ? AppTheme.primaryDark : AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              content,
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.textPrimary,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
