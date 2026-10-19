import 'package:flutter/material.dart';
import '../models/patient.dart';
import '../theme/app_theme.dart';
import '../utils/file_helper.dart';
import 'status_badge.dart';

class PatientCard extends StatelessWidget {
  final Patient patient;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const PatientCard({
    super.key,
    required this.patient,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final hasPhoto = FileHelper.hasValidImage(patient.photoPath);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Avatar
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryLight,
                      borderRadius: BorderRadius.circular(14),
                      image: hasPhoto
                          ? DecorationImage(
                              image: FileHelper.getImageProvider(patient.photoPath!),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    alignment: Alignment.center,
                    child: !hasPhoto
                        ? Text(
                            patient.name.isNotEmpty
                                ? patient.name
                                    .trim()
                                    .split(' ')
                                    .map((e) => e[0])
                                    .take(2)
                                    .join()
                                    .toUpperCase()
                                : 'P',
                            style: const TextStyle(
                              color: AppTheme.primaryDark,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 12),
                  // Name and Meta
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                patient.name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textPrimary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppTheme.surfaceMuted,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: AppTheme.border),
                              ),
                              child: Text(
                                patient.bloodGroup,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primaryDark,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${patient.age} yrs • ${patient.gender} • ${patient.phone}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  // Actions Menu
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert_rounded, color: AppTheme.textMuted, size: 20),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    onSelected: (value) {
                      if (value == 'edit') {
                        onEdit();
                      } else if (value == 'delete') {
                        onDelete();
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit_outlined, size: 18, color: AppTheme.primaryTeal),
                            SizedBox(width: 10),
                            Text('Edit Patient'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete_outline, size: 18, color: AppTheme.statusCritical),
                            SizedBox(width: 10),
                            Text('Delete', style: TextStyle(color: AppTheme.statusCritical)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Divider(height: 1, color: AppTheme.border),
              const SizedBox(height: 10),
              // Diagnosis & Status
              Row(
                children: [
                  const Icon(Icons.healing_outlined, size: 15, color: AppTheme.textMuted),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      patient.diagnosis.isNotEmpty ? patient.diagnosis : 'No diagnosis specified',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  StatusBadge(status: patient.status, isSmall: true),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
