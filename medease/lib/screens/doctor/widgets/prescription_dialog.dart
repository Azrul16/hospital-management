import 'package:flutter/material.dart';

class PrescriptionDialog extends StatefulWidget {
  final Function(String medication, String dosage, String advice) onSubmit;

  PrescriptionDialog({required this.onSubmit});

  @override
  _PrescriptionDialogState createState() => _PrescriptionDialogState();
}

class _PrescriptionDialogState extends State<PrescriptionDialog> {
  TextEditingController medicationController = TextEditingController();
  TextEditingController dosageController = TextEditingController();
  TextEditingController adviceController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Write Prescription'),
      content: SingleChildScrollView(
        child: Column(
          children: [
            TextField(
              controller: medicationController,
              decoration: InputDecoration(labelText: 'Medication'),
            ),
            TextField(
              controller: dosageController,
              decoration: InputDecoration(labelText: 'Dosage'),
            ),
            TextField(
              controller: adviceController,
              decoration: InputDecoration(labelText: 'Advice'),
              maxLines: 3,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            widget.onSubmit(
              medicationController.text,
              dosageController.text,
              adviceController.text,
            );
            Navigator.pop(context);
          },
          child: Text('Submit'),
        ),
      ],
    );
  }
}
