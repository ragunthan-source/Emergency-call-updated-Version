import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/incident_log.dart';
import '../../providers/app_state.dart';
import '../../theme/app_theme.dart';

class IncidentHistoryScreen extends StatelessWidget {
  final AppState appState;

  const IncidentHistoryScreen({super.key, required this.appState});

  @override
  Widget build(BuildContext context) {
    final logs = appState.incidentLogs;

    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        title: const Text('Incident History Log'),
        actions: [
          if (logs.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              onPressed: () {
                _confirmClearHistory(context);
              },
            ),
        ],
      ),
      body: logs.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history_toggle_off, size: 64, color: AppTheme.surfaceGlass),
                  SizedBox(height: 12),
                  Text('No emergency incidents recorded yet.',
                      style: TextStyle(color: AppTheme.textSecondary)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: logs.length,
              itemBuilder: (context, index) {
                final log = logs[index];
                return _buildIncidentCard(context, log);
              },
            ),
    );
  }

  Widget _buildIncidentCard(BuildContext context, IncidentLog log) {
    final isTest = log.triggerType.contains('Test');
    final timeStr = log.timestamp.toString().substring(0, 16);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isTest
              ? AppTheme.armedGreen
              : log.status.contains('Completed')
                  ? AppTheme.emergencyRed
                  : AppTheme.amberWarning,
          child: Icon(
            isTest ? Icons.science : Icons.warning_amber,
            color: Colors.white,
          ),
        ),
        title: Text(
          log.triggerType,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '$timeStr\nContacts: ${log.contactsNotifiedCount} | Status: ${log.status}',
          style: const TextStyle(fontSize: 12),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          _showLogDetails(context, log);
        },
      ),
    );
  }

  void _showLogDetails(BuildContext context, IncidentLog log) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.darkCardBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        height: MediaQuery.of(ctx).size.height * 0.7,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  log.triggerType,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Chip(
                  label: Text(log.status),
                  backgroundColor: AppTheme.surfaceGlass,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('Time: ${log.timestamp.toString().substring(0, 19)}'),
            if (log.mapsLink != null) ...[
              const SizedBox(height: 8),
              InkWell(
                onTap: () async {
                  final uri = Uri.parse(log.mapsLink!);
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri);
                  }
                },
                child: Row(
                  children: const [
                    Icon(Icons.location_on, color: AppTheme.emergencyRed, size: 18),
                    SizedBox(width: 4),
                    Text('View Location on Google Maps',
                        style: TextStyle(color: AppTheme.emergencyRed, decoration: TextDecoration.underline)),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),
            const Text('Event Log Details:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListView.builder(
                  itemCount: log.eventTimeline.length,
                  itemBuilder: (ctx, i) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Text(
                      log.eventTimeline[i],
                      style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmClearHistory(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear Incident History?'),
        content: const Text('Are you sure you want to delete all past emergency logs?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              appState.clearLogs();
              Navigator.pop(ctx);
            },
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }
}
