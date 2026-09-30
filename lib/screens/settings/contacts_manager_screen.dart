import 'package:flutter/material.dart';

import '../../models/emergency_contact.dart';
import '../../providers/app_state.dart';
import '../../theme/app_theme.dart';

class ContactsManagerScreen extends StatefulWidget {
  final AppState appState;

  const ContactsManagerScreen({super.key, required this.appState});

  @override
  State<ContactsManagerScreen> createState() => _ContactsManagerScreenState();
}

class _ContactsManagerScreenState extends State<ContactsManagerScreen> {
  late List<EmergencyContact> _contacts;

  @override
  void initState() {
    super.initState();
    _contacts = List.from(widget.appState.contacts);
  }

  void _save() {
    widget.appState.saveContacts(_contacts);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Contacts order and settings saved!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        title: const Text('Priority Emergency Contacts'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddDialog,
          ),
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _save,
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            color: AppTheme.darkCardBg,
            child: const Row(
              children: [
                Icon(Icons.info_outline, color: AppTheme.amberWarning, size: 18),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Drag handles to reorder priority. Top contact is called first.',
                    style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ReorderableListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _contacts.length,
              onReorder: (oldIndex, newIndex) {
                setState(() {
                  if (newIndex > oldIndex) newIndex--;
                  final item = _contacts.removeAt(oldIndex);
                  _contacts.insert(newIndex, item);
                  for (int i = 0; i < _contacts.length; i++) {
                    _contacts[i] = _contacts[i].copyWith(priority: i + 1);
                  }
                });
                _save();
              },
              itemBuilder: (context, index) {
                final contact = _contacts[index];
                return Card(
                  key: ValueKey(contact.id),
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppTheme.emergencyRed,
                      child: Text(
                        '#${index + 1}',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                    title: Text(contact.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('${contact.phoneNumber} (${contact.relationship})'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(
                            contact.callEnabled ? Icons.phone_in_talk : Icons.phone_disabled,
                            color: contact.callEnabled ? AppTheme.armedGreen : Colors.grey,
                          ),
                          onPressed: () {
                            setState(() {
                              _contacts[index] = contact.copyWith(callEnabled: !contact.callEnabled);
                            });
                            _save();
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                          onPressed: () {
                            setState(() {
                              _contacts.removeAt(index);
                            });
                            _save();
                          },
                        ),
                        const Icon(Icons.drag_handle),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showAddDialog() {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final relationCtrl = TextEditingController(text: 'Family');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Contact'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Name *')),
            TextField(controller: phoneCtrl, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'Phone Number *')),
            TextField(controller: relationCtrl, decoration: const InputDecoration(labelText: 'Relationship')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (nameCtrl.text.trim().isNotEmpty && phoneCtrl.text.trim().isNotEmpty) {
                setState(() {
                  _contacts.add(
                    EmergencyContact(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      name: nameCtrl.text.trim(),
                      phoneNumber: phoneCtrl.text.trim(),
                      relationship: relationCtrl.text.trim(),
                      priority: _contacts.length + 1,
                    ),
                  );
                });
                _save();
                Navigator.pop(ctx);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}
