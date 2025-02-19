import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/auth_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class PredictionHistoryScreen extends ConsumerStatefulWidget {
  const PredictionHistoryScreen({super.key});

  @override
  ConsumerState<PredictionHistoryScreen> createState() =>
      _PredictionHistoryScreenState();
}

class _PredictionHistoryScreenState
    extends ConsumerState<PredictionHistoryScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _searchController = TextEditingController();

  String _selectedPetType = 'all';
  double _minSeverity = 0.0;
  double _maxSeverity = 1.0;
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<QueryDocumentSnapshot> _filterPredictions(
      List<QueryDocumentSnapshot> predictions) {
    return predictions.where((doc) {
      final prediction = doc.data() as Map<String, dynamic>;

      // Filter by search text (pet type, breed, symptoms)
      final searchText = _searchController.text.toLowerCase();
      final matchesSearch = searchText.isEmpty ||
          prediction['petType'].toString().toLowerCase().contains(searchText) ||
          (prediction['breed']?.toString().toLowerCase() ?? '')
              .contains(searchText) ||
          (prediction['symptoms'] as List<dynamic>).any((symptom) =>
              symptom.toString().toLowerCase().contains(searchText));

      // Filter by pet type
      final matchesPetType = _selectedPetType == 'all' ||
          prediction['petType'].toString().toLowerCase() == _selectedPetType;

      // Filter by severity range
      final severity = prediction['severity'] as double;
      final matchesSeverity =
          severity >= _minSeverity && severity <= _maxSeverity;

      // Filter by date range
      final timestamp = (prediction['timestamp'] as Timestamp).toDate();
      final matchesDateRange =
          (_startDate == null || timestamp.isAfter(_startDate!)) &&
              (_endDate == null ||
                  timestamp.isBefore(_endDate!.add(const Duration(days: 1))));

      return matchesSearch &&
          matchesPetType &&
          matchesSeverity &&
          matchesDateRange;
    }).toList();
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
    }
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Filter Predictions'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DropdownButtonFormField<String>(
                  value: _selectedPetType,
                  decoration: const InputDecoration(
                    labelText: 'Pet Type',
                  ),
                  items: const [
                    DropdownMenuItem(value: 'all', child: Text('All')),
                    DropdownMenuItem(value: 'dog', child: Text('Dog')),
                    DropdownMenuItem(value: 'cat', child: Text('Cat')),
                  ],
                  onChanged: (value) {
                    setState(() => _selectedPetType = value!);
                  },
                ),
                const SizedBox(height: 16),
                const Text('Severity Range'),
                RangeSlider(
                  values: RangeValues(_minSeverity, _maxSeverity),
                  min: 0.0,
                  max: 1.0,
                  divisions: 10,
                  labels: RangeLabels(
                    '${(_minSeverity * 100).toInt()}%',
                    '${(_maxSeverity * 100).toInt()}%',
                  ),
                  onChanged: (values) {
                    setState(() {
                      _minSeverity = values.start;
                      _maxSeverity = values.end;
                    });
                  },
                ),
                const SizedBox(height: 16),
                ListTile(
                  title: const Text('Date Range'),
                  subtitle: Text(
                    _startDate != null && _endDate != null
                        ? '${DateFormat('MMM d, y').format(_startDate!)} - ${DateFormat('MMM d, y').format(_endDate!)}'
                        : 'All time',
                  ),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    Navigator.pop(context);
                    await _selectDateRange(context);
                    _showFilterDialog();
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  _selectedPetType = 'all';
                  _minSeverity = 0.0;
                  _maxSeverity = 1.0;
                  _startDate = null;
                  _endDate = null;
                });
              },
              child: const Text('Reset'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Apply'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userId = ref.watch(authProvider).user?.uid;
    if (userId == null) {
      return const Scaffold(
        body: Center(child: Text('Please login to view prediction history')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Prediction History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
            tooltip: 'Filter',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by pet type, breed, or symptoms...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                          });
                        },
                      )
                    : null,
              ),
              onChanged: (value) => setState(() {}),
            ),
          ),
          if (_startDate != null ||
              _selectedPetType != 'all' ||
              _minSeverity > 0 ||
              _maxSeverity < 1)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Wrap(
                spacing: 8,
                children: [
                  if (_selectedPetType != 'all')
                    Chip(
                      label: Text('Pet: ${_selectedPetType.toUpperCase()}'),
                      onDeleted: () => setState(() => _selectedPetType = 'all'),
                    ),
                  if (_startDate != null)
                    Chip(
                      label: Text(
                        'Date: ${DateFormat('MMM d').format(_startDate!)} - ${DateFormat('MMM d').format(_endDate!)}',
                      ),
                      onDeleted: () => setState(() {
                        _startDate = null;
                        _endDate = null;
                      }),
                    ),
                  if (_minSeverity > 0 || _maxSeverity < 1)
                    Chip(
                      label: Text(
                        'Severity: ${(_minSeverity * 100).toInt()}% - ${(_maxSeverity * 100).toInt()}%',
                      ),
                      onDeleted: () => setState(() {
                        _minSeverity = 0.0;
                        _maxSeverity = 1.0;
                      }),
                    ),
                ],
              ),
            ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('health_predictions')
                  .where('userId', isEqualTo: userId)
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final filteredPredictions =
                    _filterPredictions(snapshot.data!.docs);

                if (filteredPredictions.isEmpty) {
                  return const Center(
                      child: Text('No matching predictions found'));
                }

                return ListView.builder(
                  itemCount: filteredPredictions.length,
                  padding: const EdgeInsets.all(16),
                  itemBuilder: (context, index) {
                    final prediction = filteredPredictions[index].data()
                        as Map<String, dynamic>;
                    final timestamp =
                        (prediction['timestamp'] as Timestamp).toDate();
                    final severity = prediction['severity'] as double;
                    final Color severityColor = severity < 0.3
                        ? Colors.green
                        : severity < 0.6
                            ? Colors.orange
                            : Colors.red;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: InkWell(
                        onTap: () => _showPredictionDetails(prediction),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    DateFormat('MMM d, y HH:mm')
                                        .format(timestamp),
                                    style:
                                        Theme.of(context).textTheme.bodySmall,
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: severityColor,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      '${(severity * 100).toInt()}%',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${prediction['petType'].toString().toUpperCase()} • ${prediction['age']} years',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              if (prediction['breed'] != null) ...[
                                const SizedBox(height: 4),
                                Text(
                                  'Breed: ${prediction['breed']}',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                              const SizedBox(height: 8),
                              Text(
                                prediction['prediction'],
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 8),
                              if ((prediction['imageUrls'] as List<dynamic>)
                                  .isNotEmpty) ...[
                                SizedBox(
                                  height: 100,
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: (prediction['imageUrls']
                                            as List<dynamic>)
                                        .length,
                                    itemBuilder: (context, index) {
                                      final imageUrl = prediction['imageUrls']
                                          [index] as String;
                                      return Padding(
                                        padding:
                                            const EdgeInsets.only(right: 8.0),
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          child: Image.network(
                                            imageUrl,
                                            height: 100,
                                            width: 100,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(height: 8),
                              ],
                              Wrap(
                                spacing: 4,
                                runSpacing: 4,
                                children: (prediction['symptoms']
                                        as List<dynamic>)
                                    .map((symptom) => Chip(
                                          label: Text(
                                            symptom,
                                            style:
                                                const TextStyle(fontSize: 12),
                                          ),
                                          padding: EdgeInsets.zero,
                                        ))
                                    .toList(),
                              ),
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
    );
  }

  void _showPredictionDetails(Map<String, dynamic> prediction) {
    final severity = prediction['severity'] as double;
    final Color severityColor = severity < 0.3
        ? Colors.green
        : severity < 0.6
            ? Colors.orange
            : Colors.red;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Prediction Details'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Prediction: ${prediction['prediction']}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    'Severity: ',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: severityColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${(severity * 100).toInt()}%',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Recommendations:',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              ...(prediction['recommendations'] as List<dynamic>).map(
                (recommendation) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('• '),
                      Expanded(child: Text(recommendation.toString())),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
