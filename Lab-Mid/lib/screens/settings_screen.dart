import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/library_provider.dart';
import '../providers/theme_provider.dart';
import '../services/storage_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final libraryProvider = Provider.of<LibraryProvider>(context);
    final theme = Theme.of(context);

    final totalDocs = libraryProvider.documents.length;
    final totalBytes = libraryProvider.documents.fold<int>(0, (sum, doc) => sum + doc.fileSize);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings & About', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: ListView(
        children: [
          // Developer Credit Header Banner
          Card(
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            color: theme.colorScheme.primaryContainer.withOpacity(0.6),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: theme.colorScheme.primary,
                    child: const Icon(Icons.person, color: Colors.white, size: 36),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'PDFly — DocuVerse PDF',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Developer: Ali Asad',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onPrimaryContainer,
                          ),
                        ),
                        Text(
                          'Username: @iali_asad',
                          style: TextStyle(
                            fontSize: 13,
                            color: theme.colorScheme.onPrimaryContainer.withOpacity(0.8),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'Version 1.0.0 (Lab Mid)',
                            style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Theme Settings Section
          ListTile(
            title: Text('Appearance', style: theme.textTheme.titleSmall?.copyWith(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
          ),
          RadioListTile<ThemeMode>(
            title: const Text('System Default'),
            subtitle: const Text('Follow system light/dark theme settings'),
            value: ThemeMode.system,
            groupValue: themeProvider.themeMode,
            onChanged: (mode) => themeProvider.setThemeMode(mode!),
          ),
          RadioListTile<ThemeMode>(
            title: const Text('Light Theme'),
            subtitle: const Text('Clean light interface for daylight reading'),
            value: ThemeMode.light,
            groupValue: themeProvider.themeMode,
            onChanged: (mode) => themeProvider.setThemeMode(mode!),
          ),
          RadioListTile<ThemeMode>(
            title: const Text('Dark Theme'),
            subtitle: const Text('Dark color palette for low light conditions'),
            value: ThemeMode.dark,
            groupValue: themeProvider.themeMode,
            onChanged: (mode) => themeProvider.setThemeMode(mode!),
          ),

          const Divider(height: 24),

          // Database & Storage Stats
          ListTile(
            title: Text('Library Statistics', style: theme.textTheme.titleSmall?.copyWith(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
          ),
          ListTile(
            leading: const Icon(Icons.folder_outlined),
            title: const Text('Total Managed Documents'),
            trailing: Text('$totalDocs files', style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          ListTile(
            leading: const Icon(Icons.storage_outlined),
            title: const Text('Total Storage Used'),
            trailing: Text(StorageService.formatBytes(totalBytes), style: const TextStyle(fontWeight: FontWeight.bold)),
          ),

          const Divider(height: 24),

          // App Actions & Legal
          ListTile(
            title: Text('App Information', style: theme.textTheme.titleSmall?.copyWith(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('About DocuVerse PDF'),
            subtitle: const Text('Project specifications and features'),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: 'DocuVerse PDF (PDFly)',
                applicationVersion: '1.0.0',
                applicationIcon: Icon(Icons.picture_as_pdf, color: theme.colorScheme.primary, size: 40),
                children: const [
                  SizedBox(height: 12),
                  Text('Developed by Ali Asad (@iali_asad) for Mobile Application Development Lab Mid.'),
                  SizedBox(height: 8),
                  Text('Features: PDF Reader, Document Scanner, Bookmarking, Reading Progress, Offline SQLite Storage, Material 3 UI.'),
                ],
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: const Text('Privacy & Local Storage'),
            subtitle: const Text('All files & data remain stored 100% locally on device'),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Privacy Policy'),
                  content: const Text(
                    'DocuVerse PDF respects your privacy. All PDF documents, bookmarks, reading history, and scanned images are stored exclusively on your device in a local SQLite database and secure directory. No data is transmitted to external servers.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('OK'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
