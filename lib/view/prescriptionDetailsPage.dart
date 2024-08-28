import 'package:bina_dokter/service/api_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PrescriptionDetailsPage extends StatefulWidget {
  final String prescriptionId;

  const PrescriptionDetailsPage({Key? key, required this.prescriptionId})
      : super(key: key);

  @override
  State<PrescriptionDetailsPage> createState() =>
      _PrescriptionDetailsPageState();
}

class _PrescriptionDetailsPageState extends State<PrescriptionDetailsPage> {
  final ApiService _apiService = ApiService();
  List<Map<String, dynamic>> medications = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _fetchPrescriptionDetails();
  }

  Future<void> _fetchPrescriptionDetails() async {
    try {
      final result =
          await _apiService.getPrescriptionDetails(widget.prescriptionId);
      setState(() {
        if (result['status_code'] == 200) {
          medications = List<Map<String, dynamic>>.from(result['medications']);
        } else {
          error = result['error'];
        }
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = 'Terjadi kesalahan saat mengambil detail resep';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('Prescription Details', style: GoogleFonts.poppins()),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(child: Text(error!, style: GoogleFonts.poppins()))
              : ListView.builder(
                  itemCount: medications.length,
                  itemBuilder: (context, index) {
                    final medication = medications[index];
                    return Card(
                      color: Colors.lightBlue,
                      margin: const EdgeInsets.all(8.0),
                      child: ListTile(
                        title: Text(medication['name'],
                            style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Dosis: ${medication['dosage']}',
                                style: GoogleFonts.poppins(color: Colors.white)),
                            Text('Frekuensi: ${medication['frequency']}',
                                style: GoogleFonts.poppins(color: Colors.white)),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
