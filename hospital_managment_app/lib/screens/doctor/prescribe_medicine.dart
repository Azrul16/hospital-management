import 'package:flutter/material.dart';
import '../../models/medicine.dart';
import '../../models/prescription.dart';
import '../../services/prescription_service.dart';
import '../../widgets/custom_text_form_field.dart';
import '../../widgets/custom_button.dart';

class PrescribeMedicine extends StatefulWidget {
  final String appointmentId;
  final String patientId;
  final String patientName;
  final String doctorId;

  const PrescribeMedicine({
    Key? key,
    required this.appointmentId,
    required this.patientId,
    required this.patientName,
    required this.doctorId,
  }) : super(key: key);

  @override
  _PrescribeMedicineState createState() => _PrescribeMedicineState();
}

class _PrescribeMedicineState extends State<PrescribeMedicine> {
  final PrescriptionService _prescriptionService = PrescriptionService();
  final List<MedicineEntry> _medicines = [];
  final TextEditingController _instructionsController = TextEditingController();
  final TextEditingController _followUpDateController = TextEditingController();
  final TextEditingController _diagnosisController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _addNewMedicine();
  }

  void _addNewMedicine() {
    setState(() {
      _medicines.add(MedicineEntry());
    });
  }

  void _removeMedicine(int index) {
    setState(() {
      _medicines.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Write Prescription'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPatientInfo(),
            const SizedBox(height: 24),
            _buildMedicinesList(),
            const SizedBox(height: 16),
            CustomButton(
              text: 'Add Medicine',
              onPressed: _addNewMedicine,
              isOutlined: true,
            ),
            const SizedBox(height: 24),
            _buildDiagnosis(),
            const SizedBox(height: 24),
            _buildInstructions(),
            const SizedBox(height: 24),
            _buildFollowUp(),
            const SizedBox(height: 32),
            CustomButton(
              text: 'Save Prescription',
              onPressed: _savePrescription,
              isLoading: _isLoading,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPatientInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: Theme.of(context).primaryColor,
            child: Text(
              widget.patientName[0],
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.patientName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Appointment ID: ${widget.appointmentId}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicinesList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Medicines',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _medicines.length,
          itemBuilder: (context, index) {
            return _buildMedicineCard(index);
          },
        ),
      ],
    );
  }

  Widget _buildMedicineCard(int index) {
    final medicine = _medicines[index];
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Medicine ${index + 1}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => _removeMedicine(index),
                  color: Colors.red,
                ),
              ],
            ),
            const SizedBox(height: 16),
            CustomTextFormField(
              controller: medicine.nameController,
              hintText: 'Medicine Name',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter medicine name';
                }
                return null;
              },
            ),
            CustomTextFormField(
              controller: medicine.dosageController,
              hintText: 'Dosage (e.g., 1 tablet)',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter dosage';
                }
                return null;
              },
            ),
            CustomTextFormField(
              controller: medicine.frequencyController,
              hintText: 'Frequency (e.g., Twice daily)',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter frequency';
                }
                return null;
              },
            ),
            CustomTextFormField(
              controller: medicine.durationController,
              hintText: 'Duration (e.g., 7 days)',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter duration';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDiagnosis() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Diagnosis',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        CustomTextFormField(
          controller: _diagnosisController,
          hintText: 'Enter diagnosis',
          maxLines: 3,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter diagnosis';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildInstructions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Special Instructions',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        CustomTextFormField(
          controller: _instructionsController,
          hintText: 'Add any special instructions',
          maxLines: 4,
        ),
      ],
    );
  }

  Widget _buildFollowUp() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Follow-up Date',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        CustomTextFormField(
          controller: _followUpDateController,
          hintText: 'Select follow-up date',
          suffixIcon: IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: DateTime.now().add(const Duration(days: 7)),
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );
              if (date != null) {
                _followUpDateController.text =
                    '${date.day}/${date.month}/${date.year}';
              }
            },
          ),
        ),
      ],
    );
  }

  void _savePrescription() async {
    if (_medicines.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one medicine')),
      );
      return;
    }

    if (_diagnosisController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter diagnosis')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final medicines = _medicines.map((entry) => Medicine(
            id: DateTime.now().toIso8601String(),
            name: entry.nameController.text,
            dosage: entry.dosageController.text,
            frequency: entry.frequencyController.text,
            duration: entry.durationController.text,
            instructions: entry.nameController.text,
          )).toList();

      final prescription = Prescription(
        id: _prescriptionService.generatePrescriptionId(),
        appointmentId: widget.appointmentId,
        patientId: widget.patientId,
        doctorId: widget.doctorId,
        medicines: medicines,
        diagnosis: _diagnosisController.text,
        notes: _instructionsController.text,
        createdAt: DateTime.now(),
      );

      await _prescriptionService.createPrescription(prescription);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Prescription saved successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save prescription')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _instructionsController.dispose();
    _followUpDateController.dispose();
    _diagnosisController.dispose();
    for (var medicine in _medicines) {
      medicine.dispose();
    }
    super.dispose();
  }
}

class MedicineEntry {
  final nameController = TextEditingController();
  final dosageController = TextEditingController();
  final frequencyController = TextEditingController();
  final durationController = TextEditingController();

  void dispose() {
    nameController.dispose();
    dosageController.dispose();
    frequencyController.dispose();
    durationController.dispose();
  }
}
