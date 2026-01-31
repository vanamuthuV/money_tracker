import 'package:flutter/material.dart';
import '../categories/category_screen.dart';
import '../settings/settings_screen.dart';
import '../history/history_screen.dart';
import '../../core/constants/spacing.dart';
import '../../core/constants/colors.dart';
import '../../core/services/app_data_service.dart';
import '../../core/services/expense_service.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:file_selector/file_selector.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: AppColors.card,
        padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(Spacing.md),
              child: Text(
                'Menu',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.category),
              title: Text('Manage Categories'),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushNamed(CategoryScreen.route);
              },
            ),
            ListTile(
              leading: Icon(Icons.monetization_on),
              title: Text('Set Currency'),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushNamed(SettingsScreen.route);
              },
            ),
            ListTile(
              leading: Icon(Icons.history),
              title: Text('History'),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushNamed(HistoryScreen.route);
              },
            ),
            ListTile(
              leading: Icon(Icons.file_upload),
              title: Text('Export Data'),
              onTap: () async {
                Navigator.of(context).pop();

                // Request storage permission at runtime (do NOT request MANAGE_EXTERNAL_STORAGE)
                PermissionStatus status;
                try {
                  status = await Permission.storage.request();
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Export failed: Unable to request permissions',
                      ),
                    ),
                  );
                  return;
                }

                if (status.isGranted) {
                  try {
                    final res = await AppDataService.instance
                        .exportToDownloads();
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text('Exported: $res')));
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Export failed: ${e.toString()}')),
                    );
                  }
                } else if (status.isPermanentlyDenied) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Export failed: storage permission permanently denied. Open app settings to grant permission.',
                      ),
                      action: SnackBarAction(
                        label: 'Settings',
                        onPressed: () => openAppSettings(),
                        textColor: Colors.white,
                      ),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Export failed: storage permission denied. Grant permission to export to Downloads/Money Tracker.',
                      ),
                    ),
                  );
                }
              },
            ),
            ListTile(
              leading: Icon(Icons.file_download),
              title: Text('Import Data'),
              onTap: () async {
                Navigator.of(context).pop();
                try {
                  final files = AppDataService.instance.listImportFiles();

                  final choice = await showDialog<File?>(
                    context: context,
                    builder: (ctx) => SimpleDialog(
                      title: Text('Select file to import'),
                      children: [
                        // Existing files from export folder
                        if (files.isNotEmpty)
                          ...files.map(
                            (f) => SimpleDialogOption(
                              child: Text(f.uri.pathSegments.last),
                              onPressed: () => Navigator.of(ctx).pop(f),
                            ),
                          ),
                        SimpleDialogOption(
                          child: Text('Browse device...'),
                          onPressed: () => Navigator.of(ctx).pop(null),
                        ),
                      ],
                    ),
                  );

                  // If user chose a file from export folder
                  if (choice != null) {
                    await AppDataService.instance.importFromPath(choice.path);
                    final count = ExpenseService.instance.expenses.value.length;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Imported ${count} expenses from ${choice.path}',
                        ),
                      ),
                    );
                    return;
                  }

                  // Otherwise allow browsing the device using the system file picker (no storage permission required)
                  final XFile? picked = await openFile(
                    acceptedTypeGroups: [
                      XTypeGroup(label: 'JSON', extensions: ['json']),
                    ],
                  );

                  if (picked == null) return;
                  final path = picked.path;
                  if (path == null) return;

                  // If file is outside the app export folder, ask for confirmation and allow explicit override
                  final folder = AppDataService.instance.getExportFolder();
                  final outside = !path.startsWith(folder.path);
                  if (outside) {
                    final confirm = await showDialog<bool?>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: Text('Import from external file'),
                        content: Text(
                          'The selected file is outside the app export folder. Importing it will overwrite your current app data. Are you sure you want to proceed?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(ctx).pop(false),
                            child: Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(ctx).pop(true),
                            child: Text('Import'),
                          ),
                        ],
                      ),
                    );
                    if (confirm != true) return;
                  }

                  try {
                    await AppDataService.instance.importFromPath(
                      path,
                      allowOutside: outside,
                    );
                    final count = ExpenseService.instance.expenses.value.length;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Imported ${count} expenses from $path'),
                      ),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Import failed: ${e.toString()}')),
                    );
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Import failed: ${e.toString()}')),
                  );
                }
              },
            ),
            Spacer(),
            Padding(
              padding: const EdgeInsets.all(Spacing.md),
              child: Text(
                'Version 1.0',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
