import 'package:bina_dokter/view/mainmenudr.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:bina_dokter/service/api_service.dart';

class AddPrescriptionPage extends StatefulWidget {
  final Patient patient;

  const AddPrescriptionPage({Key? key, required this.patient}) : super(key: key);

  @override
  _AddPrescriptionPageState createState() => _AddPrescriptionPageState();
}

class _AddPrescriptionPageState extends State<AddPrescriptionPage> {
  final ApiService _apiService = ApiService();
  List<Map<String, String>> medications = [];
  final _formKey = GlobalKey<FormState>();

  void _addMedication() {
    setState(() {
      medications.add({
        'name': '',
        'dosage': '',
        'frequency': '',
      });
    });
  }

  void _removeMedication(int index) {
    setState(() {
      medications.removeAt(index);
    });
  }

  void _submitPrescription() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      try {
        final result = await _apiService.prescribe(widget.patient.patientId.toString(), medications);
        if (result['status_code'] == 201) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Prescription added successfully')),
          );
          Navigator.pop(context);
        } else {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to add prescription: ${result['error']}')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('an error occurred: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('Add Prescription for ${widget.patient.fullname}'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'List of Medications',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                ...medications.asMap().entries.map((entry) {
                  int index = entry.key;
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          TextFormField(
                            decoration: const InputDecoration(labelText: 'Medication Name'),
                            onSaved: (value) => medications[index]['name'] = value!,
                            validator: (value) => value!.isEmpty ? 'Medication name must be filled' : null,
                          ),
                          TextFormField(
                            decoration: const InputDecoration(labelText: 'Dosage'),
                            onSaved: (value) => medications[index]['dosage'] = value!,
                            validator: (value) => value!.isEmpty ? 'Dosage must be filled' : null,
                          ),
                          TextFormField(
                            decoration: const InputDecoration(labelText: 'Frequency'),
                            onSaved: (value) => medications[index]['frequency'] = value!,
                            validator: (value) => value!.isEmpty ? 'Frequency must be filled' : null,
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => _removeMedication(index),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
                const SizedBox(height: 16),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightBlue,
                  ),
                  onPressed: _addMedication,
                  child: Text('Add Medication', style: GoogleFonts.poppins(fontWeight: FontWeight.bold,color: Colors.white)),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightBlue,
                  ),
                  onPressed: _submitPrescription,
                  child: Text('Save Prescription', style: GoogleFonts.poppins(fontWeight: FontWeight.bold,color: Colors.white)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}