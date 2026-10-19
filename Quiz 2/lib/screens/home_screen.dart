import 'package:flutter/material.dart';
import '../database/db_helper.dart';
import '../models/patient.dart';
import '../theme/app_theme.dart';
import '../widgets/patient_card.dart';
import '../widgets/stat_card.dart';
import 'add_edit_patient_screen.dart';
import 'patient_details_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Patient> _patients = [];
  Map<String, int> _stats = {
    'total': 0,
    'active': 0,
    'observation': 0,
    'critical': 0,
    'recovered': 0,
    'docs': 0,
  };
  bool _isLoading = true;
  String _selectedStatus = 'All';
  String _selectedSort = 'newest';

  final List<String> _statusFilters = [
    'All',
    'Active',
    'Under Observation',
    'Critical',
    'Recovered',
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final stats = await DatabaseHelper.instance.getStats();
      final patients = await DatabaseHelper.instance.getPatients(
        query: _searchController.text,
        statusFilter: _selectedStatus == 'All' ? null : _selectedStatus,
        sortBy: _selectedSort,
      );

      if (mounted) {
        setState(() {
          _stats = stats;
          _patients = patients;
        });
      }
    } catch (e) {
      debugPrint('Error loading patient data: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _deletePatient(Patient patient) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Patient Record?'),
        content: Text(
          'Are you sure you want to delete ${patient.name}? All medical records and documents will be permanently deleted.',
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

    if (confirmed == true && patient.id != null) {
      await DatabaseHelper.instance.deletePatient(patient.id!);
      _loadData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${patient.name}\'s record deleted'),
            backgroundColor: AppTheme.textPrimary,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primaryLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.medical_services_rounded, color: AppTheme.primaryDark, size: 20),
            ),
            const SizedBox(width: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'MedPulse Doctor Portal',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                ),
                Text(
                  'Dr. Alex Carter • Clinic Management',
                  style: TextStyle(fontSize: 11, color: AppTheme.textSecondary, fontWeight: FontWeight.normal),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh data',
            onPressed: _loadData,
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
        onRefresh: _loadData,
        color: AppTheme.primaryTeal,
        child: CustomScrollView(
          slivers: [
            // Top Stats Overview
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Overview & Statistics',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: StatCard(
                            title: 'Total Patients',
                            count: '${_stats['total']}',
                            icon: Icons.people_outline_rounded,
                            color: AppTheme.primaryTeal,
                            isSelected: _selectedStatus == 'All',
                            onTap: () {
                              setState(() => _selectedStatus = 'All');
                              _loadData();
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: StatCard(
                            title: 'Active Cases',
                            count: '${_stats['active']}',
                            icon: Icons.favorite_outline_rounded,
                            color: AppTheme.statusActive,
                            isSelected: _selectedStatus == 'Active',
                            onTap: () {
                              setState(() => _selectedStatus = 'Active');
                              _loadData();
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: StatCard(
                            title: 'Observation',
                            count: '${_stats['observation']}',
                            icon: Icons.visibility_outlined,
                            color: AppTheme.statusObservation,
                            isSelected: _selectedStatus == 'Under Observation',
                            onTap: () {
                              setState(() => _selectedStatus = 'Under Observation');
                              _loadData();
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: StatCard(
                            title: 'Critical',
                            count: '${_stats['critical']}',
                            icon: Icons.warning_amber_rounded,
                            color: AppTheme.statusCritical,
                            isSelected: _selectedStatus == 'Critical',
                            onTap: () {
                              setState(() => _selectedStatus = 'Critical');
                              _loadData();
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Search Bar & Sort Menu
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        onChanged: (_) => _loadData(),
                        decoration: InputDecoration(
                          hintText: 'Search by patient name, diagnosis...',
                          prefixIcon: const Icon(Icons.search, size: 20),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear, size: 18),
                                  onPressed: () {
                                    _searchController.clear();
                                    _loadData();
                                  },
                                )
                              : null,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    PopupMenuButton<String>(
                      icon: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppTheme.border),
                        ),
                        child: const Icon(Icons.sort_rounded, color: AppTheme.primaryTeal, size: 22),
                      ),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      onSelected: (val) {
                        setState(() => _selectedSort = val);
                        _loadData();
                      },
                      itemBuilder: (ctx) => [
                        const PopupMenuItem(
                          value: 'newest',
                          child: Text('Newest First'),
                        ),
                        const PopupMenuItem(
                          value: 'oldest',
                          child: Text('Oldest First'),
                        ),
                        const PopupMenuItem(
                          value: 'name_asc',
                          child: Text('Name (A - Z)'),
                        ),
                        const PopupMenuItem(
                          value: 'age_desc',
                          child: Text('Age (Highest)'),
                        ),
                        const PopupMenuItem(
                          value: 'age_asc',
                          child: Text('Age (Lowest)'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Status Filter Chips
            SliverToBoxAdapter(
              child: SizedBox(
                height: 44,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
                  itemCount: _statusFilters.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemBuilder: (context, i) {
                    final filter = _statusFilters[i];
                    final isSelected = _selectedStatus == filter;
                    return FilterChip(
                      selected: isSelected,
                      label: Text(filter),
                      labelStyle: TextStyle(
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        color: isSelected ? Colors.white : AppTheme.textSecondary,
                      ),
                      backgroundColor: Colors.white,
                      selectedColor: AppTheme.primaryTeal,
                      checkmarkColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: isSelected ? AppTheme.primaryTeal : AppTheme.border,
                        ),
                      ),
                      onSelected: (selected) {
                        setState(() {
                          _selectedStatus = filter;
                        });
                        _loadData();
                      },
                    );
                  },
                ),
              ),
            ),

            // Patient List Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Patient Records (${_patients.length})',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    if (_selectedStatus != 'All' || _searchController.text.isNotEmpty)
                      TextButton(
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _selectedStatus = 'All');
                          _loadData();
                        },
                        child: const Text('Reset filters', style: TextStyle(fontSize: 12)),
                      ),
                  ],
                ),
              ),
            ),

            // Patient Records Content
            _isLoading
                ? const SliverFillRemaining(
                    child: Center(
                      child: CircularProgressIndicator(color: AppTheme.primaryTeal),
                    ),
                  )
                : _patients.isEmpty
                    ? SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(
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
                                    Icons.person_search_outlined,
                                    size: 48,
                                    color: AppTheme.primaryDark,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'No Patient Records Found',
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  _searchController.text.isNotEmpty
                                      ? 'No matching patient records for "${_searchController.text}"'
                                      : 'Add your first patient to begin tracking records.',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton.icon(
                                  icon: const Icon(Icons.person_add_alt_1),
                                  label: const Text('Register New Patient'),
                                  onPressed: () async {
                                    final added = await Navigator.push<bool>(
                                      context,
                                      MaterialPageRoute(
                                        builder: (ctx) => const AddEditPatientScreen(),
                                      ),
                                    );
                                    if (added == true) _loadData();
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    : SliverPadding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final p = _patients[index];
                              return PatientCard(
                                patient: p,
                                onTap: () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (ctx) => PatientDetailsScreen(patientId: p.id!),
                                    ),
                                  );
                                  _loadData();
                                },
                                onEdit: () async {
                                  final updated = await Navigator.push<bool>(
                                    context,
                                    MaterialPageRoute(
                                      builder: (ctx) => AddEditPatientScreen(patient: p),
                                    ),
                                  );
                                  if (updated == true) _loadData();
                                },
                                onDelete: () => _deletePatient(p),
                              );
                            },
                            childCount: _patients.length,
                          ),
                        ),
                      ),
          ],
        ),
      ),
    ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final added = await Navigator.push<bool>(
            context,
            MaterialPageRoute(
              builder: (ctx) => const AddEditPatientScreen(),
            ),
          );
          if (added == true) _loadData();
        },
        icon: const Icon(Icons.person_add_alt_1_rounded),
        label: const Text('Add Patient'),
      ),
    );
  }
}
