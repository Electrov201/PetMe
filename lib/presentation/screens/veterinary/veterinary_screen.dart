import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/veterinary_model.dart';
import '../../../core/services/veterinary_service.dart';

class VeterinaryScreen extends ConsumerStatefulWidget {
  const VeterinaryScreen({super.key});

  @override
  ConsumerState<VeterinaryScreen> createState() => _VeterinaryScreenState();
}

class _VeterinaryScreenState extends ConsumerState<VeterinaryScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _showEmergencyOnly = false;
  bool _showVerifiedOnly = false;
  final VeterinaryService _vetService = VeterinaryService();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<VeterinaryModel> _filterVeterinaries(
      List<VeterinaryModel> veterinaries) {
    return veterinaries.where((vet) {
      final matchesSearch = _searchController.text.isEmpty ||
          vet.name
              .toLowerCase()
              .contains(_searchController.text.toLowerCase()) ||
          vet.address
              .toLowerCase()
              .contains(_searchController.text.toLowerCase());

      final matchesEmergency = !_showEmergencyOnly || vet.isEmergency;
      final matchesVerified = !_showVerifiedOnly || vet.isVerified;

      return matchesSearch && matchesEmergency && matchesVerified;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Veterinaries'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterDialog(context),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search veterinaries...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<VeterinaryModel>>(
              future: _vetService.getVeterinaries(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final filteredVeterinaries =
                    _filterVeterinaries(snapshot.data!);

                if (filteredVeterinaries.isEmpty) {
                  return const Center(child: Text('No veterinaries found'));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredVeterinaries.length,
                  itemBuilder: (context, index) {
                    final vet = filteredVeterinaries[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      elevation: 2,
                      child: InkWell(
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            '/veterinary-details',
                            arguments: vet,
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.medical_services),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      vet.name,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium,
                                    ),
                                  ),
                                  if (vet.isEmergency)
                                    const Padding(
                                      padding: EdgeInsets.only(left: 8),
                                      child: Icon(Icons.emergency,
                                          color: Colors.red),
                                    ),
                                  if (vet.isVerified)
                                    const Padding(
                                      padding: EdgeInsets.only(left: 8),
                                      child: Icon(Icons.verified,
                                          color: Colors.blue),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(Icons.location_on, size: 16),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      vet.address,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(Icons.phone, size: 16),
                                  const SizedBox(width: 4),
                                  Text(
                                    vet.phone,
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                  ),
                                ],
                              ),
                              if (vet.specialties.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Wrap(
                                  spacing: 8,
                                  children: vet.specialties.map((specialty) {
                                    return Chip(
                                      label: Text(
                                        specialty,
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                      padding: EdgeInsets.zero,
                                    );
                                  }).toList(),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/add-veterinary');
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Veterinaries'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CheckboxListTile(
              title: const Text('Emergency Services Only'),
              value: _showEmergencyOnly,
              onChanged: (value) {
                setState(() => _showEmergencyOnly = value ?? false);
                Navigator.pop(context);
              },
            ),
            CheckboxListTile(
              title: const Text('Verified Only'),
              value: _showVerifiedOnly,
              onChanged: (value) {
                setState(() => _showVerifiedOnly = value ?? false);
                Navigator.pop(context);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _showEmergencyOnly = false;
                _showVerifiedOnly = false;
              });
              Navigator.pop(context);
            },
            child: const Text('Reset'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
