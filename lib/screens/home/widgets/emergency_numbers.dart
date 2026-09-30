import 'package:flutter/material.dart';
import '../../../services/emergency_service.dart';
import '../../../theme/app_theme.dart';

class EmergencyNumbersWidget extends StatelessWidget {
  const EmergencyNumbersWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final numbers = [
      {'label': 'Universal', 'number': '112', 'icon': Icons.local_hospital},
      {'label': 'Police', 'number': '911', 'icon': Icons.local_police},
      {'label': 'Ambulance', 'number': '100', 'icon': Icons.medical_services},
      {'label': 'Fire', 'number': '999', 'icon': Icons.local_fire_department},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Local Emergency Direct Services',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 10),
        Row(
          children: numbers.map((item) {
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: InkWell(
                  onTap: () {
                    EmergencyService.launchDirectCall(item['number'] as String);
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: AppTheme.darkCardBg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.surfaceGlass),
                    ),
                    child: Column(
                      children: [
                        Icon(item['icon'] as IconData, color: AppTheme.emergencyRed, size: 24),
                        const SizedBox(height: 4),
                        Text(
                          item['number'] as String,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        Text(
                          item['label'] as String,
                          style: const TextStyle(fontSize: 10, color: AppTheme.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
