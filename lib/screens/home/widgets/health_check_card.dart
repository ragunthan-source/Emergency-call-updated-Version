import 'package:flutter/material.dart';
import '../../../providers/app_state.dart';
import '../../../services/permission_service.dart';
import '../../../theme/app_theme.dart';

class HealthCheckCard extends StatelessWidget {
  final AppState appState;

  const HealthCheckCard({super.key, required this.appState});

  @override
  Widget build(BuildContext context) {
    final report = appState.permissionReport;
    if (report == null || report.isFullyConfigured) {
      return const SizedBox.shrink(); // All good!
    }

    return Card(
      color: AppTheme.amberWarning.withOpacity(0.15),
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: AppTheme.amberWarning, width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: AppTheme.amberWarning, size: 30),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Permission Health Alert',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.amberWarning),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'One or more emergency permissions (GPS/SMS/Phone) are revoked.',
                    style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: () async {
                await PermissionService.requestAllPermissions();
                await appState.refreshPermissions();
              },
              child: const Text('FIX', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.amberWarning)),
            ),
          ],
        ),
      ),
    );
  }
}
