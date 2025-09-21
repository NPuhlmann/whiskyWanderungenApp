import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../../data/providers/route_management_provider.dart';
import '../../../../config/l10n/app_localizations.dart';

/// Dialog für das Erstellen oder Bearbeiten einer Route
class RouteFormDialog extends StatefulWidget {
  final Map<String, dynamic>? route;

  const RouteFormDialog({super.key, this.route});

  bool get isEdit => route != null;

  @override
  State<RouteFormDialog> createState() => _RouteFormDialogState();
}

class _RouteFormDialogState extends State<RouteFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _distanceController = TextEditingController();
  final _durationController = TextEditingController();
  final _priceController = TextEditingController();
  final _maxParticipantsController = TextEditingController();

  String _selectedDifficulty = 'moderate';
  bool _isActive = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.isEdit) {
      _populateFields();
    }
  }

  void _populateFields() {
    final route = widget.route!;
    _nameController.text = route['name'] ?? '';
    _descriptionController.text = route['description'] ?? '';
    _distanceController.text = (route['distance'] ?? 0.0).toString();
    _durationController.text = (route['duration'] ?? 0).toString();
    _priceController.text = (route['price'] ?? 0.0).toString();
    _maxParticipantsController.text = (route['max_participants'] ?? 0).toString();
    _selectedDifficulty = route['difficulty'] ?? 'moderate';
    _isActive = route['is_active'] ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _distanceController.dispose();
    _durationController.dispose();
    _priceController.dispose();
    _maxParticipantsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 600,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            Flexible(child: _buildForm()),
            const SizedBox(height: 24),
            _buildActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Icon(
          widget.isEdit ? Icons.edit : Icons.add,
          color: Colors.amber[800],
        ),
        const SizedBox(width: 12),
        Text(
          widget.isEdit ? 'Route bearbeiten' : 'Neue Route erstellen',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const Spacer(),
        IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.close),
        ),
      ],
    );
  }

  Widget _buildForm() {
    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            // Grundinformationen
            _buildSectionHeader('Grundinformationen'),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Name *',
                      hintText: 'z.B. Highland Whisky Trail',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Name ist erforderlich';
                      }
                      if (value.trim().length < 3) {
                        return 'Name muss mindestens 3 Zeichen lang sein';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedDifficulty,
                    decoration: const InputDecoration(
                      labelText: 'Schwierigkeit *',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'easy', child: Text('Leicht')),
                      DropdownMenuItem(value: 'moderate', child: Text('Mittel')),
                      DropdownMenuItem(value: 'hard', child: Text('Schwer')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedDifficulty = value!;
                      });
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Beschreibung',
                hintText: 'Beschreiben Sie die Route...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              validator: (value) {
                if (value != null && value.length > 1000) {
                  return 'Beschreibung darf maximal 1000 Zeichen lang sein';
                }
                return null;
              },
            ),

            const SizedBox(height: 24),

            // Route-Details
            _buildSectionHeader('Route-Details'),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _distanceController,
                    decoration: const InputDecoration(
                      labelText: 'Distanz (km) *',
                      hintText: '12.5',
                      border: OutlineInputBorder(),
                      suffixText: 'km',
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                    ],
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Distanz ist erforderlich';
                      }
                      final distance = double.tryParse(value);
                      if (distance == null || distance <= 0) {
                        return 'Ungültige Distanz';
                      }
                      if (distance > 100) {
                        return 'Distanz darf maximal 100 km betragen';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _durationController,
                    decoration: const InputDecoration(
                      labelText: 'Dauer (Minuten) *',
                      hintText: '240',
                      border: OutlineInputBorder(),
                      suffixText: 'min',
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Dauer ist erforderlich';
                      }
                      final duration = int.tryParse(value);
                      if (duration == null || duration <= 0) {
                        return 'Ungültige Dauer';
                      }
                      if (duration > 1440) { // 24 Stunden
                        return 'Dauer darf maximal 24 Stunden betragen';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _priceController,
                    decoration: const InputDecoration(
                      labelText: 'Preis (€) *',
                      hintText: '89.99',
                      border: OutlineInputBorder(),
                      suffixText: '€',
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                    ],
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Preis ist erforderlich';
                      }
                      final price = double.tryParse(value);
                      if (price == null || price < 0) {
                        return 'Ungültiger Preis';
                      }
                      if (price > 999.99) {
                        return 'Preis darf maximal 999,99 € betragen';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _maxParticipantsController,
                    decoration: const InputDecoration(
                      labelText: 'Max. Teilnehmer',
                      hintText: '12',
                      border: OutlineInputBorder(),
                      suffixText: 'Pers.',
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    validator: (value) {
                      if (value != null && value.isNotEmpty) {
                        final participants = int.tryParse(value);
                        if (participants == null || participants <= 0) {
                          return 'Ungültige Anzahl';
                        }
                        if (participants > 50) {
                          return 'Maximal 50 Teilnehmer';
                        }
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Status
            _buildSectionHeader('Status'),
            const SizedBox(height: 16),

            SwitchListTile(
              title: const Text('Route ist aktiv'),
              subtitle: const Text('Aktive Routen können von Kunden gebucht werden'),
              value: _isActive,
              onChanged: (value) {
                setState(() {
                  _isActive = value;
                });
              },
              activeColor: Colors.amber[800],
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: Colors.amber[800],
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.amber[800],
          ),
        ),
      ],
    );
  }

  Widget _buildActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Abbrechen'),
        ),
        const SizedBox(width: 16),
        FilledButton.icon(
          onPressed: _isLoading ? null : _saveRoute,
          icon: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Icon(widget.isEdit ? Icons.save : Icons.add),
          label: Text(widget.isEdit ? 'Speichern' : 'Erstellen'),
          style: FilledButton.styleFrom(
            backgroundColor: Colors.amber[800],
          ),
        ),
      ],
    );
  }

  void _saveRoute() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final routeData = {
        'name': _nameController.text.trim(),
        'description': _descriptionController.text.trim(),
        'difficulty': _selectedDifficulty,
        'distance': double.parse(_distanceController.text),
        'duration': int.parse(_durationController.text),
        'price': double.parse(_priceController.text),
        'max_participants': _maxParticipantsController.text.isNotEmpty
            ? int.parse(_maxParticipantsController.text)
            : null,
        'is_active': _isActive,
      };

      final provider = context.read<RouteManagementProvider>();

      if (widget.isEdit) {
        await provider.updateRoute(widget.route!['id'], routeData);
      } else {
        await provider.createRoute(routeData);
      }

      if (mounted) {
        if (provider.errorMessage == null) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                widget.isEdit
                    ? 'Route erfolgreich aktualisiert'
                    : 'Route erfolgreich erstellt',
              ),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(provider.errorMessage!),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Fehler: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}