import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DoctorPrescriptionManagementScreen extends StatefulWidget {
  final String appointmentId;

  DoctorPrescriptionManagementScreen({required this.appointmentId});

  @override
  _DoctorPrescriptionManagementScreenState createState() =>
      _DoctorPrescriptionManagementScreenState();
}

class _DoctorPrescriptionManagementScreenState
    extends State<DoctorPrescriptionManagementScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Map<String, TextEditingController>> _prescriptionsControllers = [];

  @override
  void initState() {
    super.initState();
    _addPrescriptionEntry();
  }

  void _addPrescriptionEntry() {
    setState(() {
      _prescriptionsControllers.add({
        'medication': TextEditingController(),
        'dosage': TextEditingController(),
        'advice': TextEditingController(),
      });
    });
  }

  void _removePrescriptionEntry(int index) {
    setState(() {
      _prescriptionsControllers[index]['medication']!.dispose();
      _prescriptionsControllers[index]['dosage']!.dispose();
      _prescriptionsControllers[index]['advice']!.dispose();
      _prescriptionsControllers.removeAt(index);
    });
  }

  Future<void> _submitPrescriptions() async {
    for (var controllers in _prescriptionsControllers) {
      final medication = controllers['medication']!.text.trim();
      final dosage = controllers['dosage']!.text.trim();
      final advice = controllers['advice']!.text.trim();

      if (medication.isNotEmpty) {
        await _firestore.collection('prescriptions').add({
          'appointmentId': widget.appointmentId,
          'medication': medication,
          'dosage': dosage,
          'advice': advice,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
    }
    await _firestore
        .collection('appointments')
        .doc(widget.appointmentId)
        .update({'status': 'completed'});

    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    for (var controllers in _prescriptionsControllers) {
      controllers['medication']!.dispose();
      controllers['dosage']!.dispose();
      controllers['advice']!.dispose();
    }
    super.dispose();
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.teal),
        borderRadius: BorderRadius.circular(12),
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Prescriptions'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: _prescriptionsControllers.length,
                itemBuilder: (context, index) {
                  final controllers = _prescriptionsControllers[index];
                  return Container(
                    margin: EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.shade100,
                          blurRadius: 6,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          TextField(
                            controller: controllers['medication'],
                            decoration: _inputDecoration('Medication'),
                          ),
                          SizedBox(height: 12),
                          TextField(
                            controller: controllers['dosage'],
                            decoration: _inputDecoration('Dosage'),
                          ),
                          SizedBox(height: 12),
                          TextField(
                            controller: controllers['advice'],
                            decoration: _inputDecoration('Advice'),
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: IconButton(
                              icon: Icon(
                                Icons.remove_circle,
                                color: Colors.red,
                              ),
                              onPressed: () {
                                if (_prescriptionsControllers.length > 1) {
                                  _removePrescriptionEntry(index);
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _addPrescriptionEntry,
                    icon: Icon(Icons.add),
                    label: Text('Add Medicine'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _submitPrescriptions,
                    child: Text('Submit Prescriptions'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
