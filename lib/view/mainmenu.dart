import 'package:bina_dokter/Signin/Signup/signin.dart';
import 'package:bina_dokter/service/api_service.dart';
import 'package:bina_dokter/view/pharmacypage.dart';
import 'package:bina_dokter/view/prescriptionDetailsPage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:bina_dokter/view/chatwithdoctor.dart'; // Tambahkan impor ini

class Mainmenu extends StatefulWidget {
  const Mainmenu({super.key});
  @override
  State<Mainmenu> createState() => _MainmenuState();
}

class _MainmenuState extends State<Mainmenu> {
  String? fullname;
  final ApiService _apiService = ApiService();
  List<Map<String, dynamic>> prescriptions = [];
  bool isLoading = true;
  String? doctorId; // Tambahkan variabel ini untuk menyimpan doctor_id

  @override
  void initState() {
    super.initState();
    fetchfullname();
    fetchPrescriptions();
  }

  Future<void> fetchPrescriptions() async {
    try {
      final response = await _apiService.getPrescriptionsId();
      if (response['prescriptions'] != null) {
        setState(() {
          prescriptions = List<Map<String, dynamic>>.from(response['prescriptions']);
          isLoading = false;
          
          // Ambil doctor_id dari resep pertama (asumsikan semua resep memiliki doctor_id yang sama)
          if (prescriptions.isNotEmpty && prescriptions[0]['doctor_id'] != null) {
            doctorId = prescriptions[0]['doctor_id'].toString();
          }
        });
      }
    } catch (e) {
      print('Error fetching prescriptions: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Settings'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Sign Out'),
                onTap: () {
                  Navigator.of(context).pop(); // Close the dialog
                  signOut(); // Call the sign-out method
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void signOut() async {
    try {
      final response = await _apiService.signout();
      if (!mounted) return;
      if (response['message'] == 'Signed out successfully') {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => const Signin()));
      } else {
        debugPrint('Sign out failed: ${response['error']}');
      }
    } catch (e) {
      debugPrint('Error signing out: $e');
    }
  }

  void fetchfullname() async {
    try {
      final response = await _apiService.getFullName();
      setState(() {
        fullname = response['fullname'];
      });
    } catch (e) {
      debugPrint('Error fetching fullname: $e');
      setState(() {
        fullname = 'Unknown';
      });
    }
  }

  void _navigateToPrescriptionDetails(String prescriptionId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            PrescriptionDetailsPage(prescriptionId: prescriptionId),
      ),
    );
  }

  void _navigateToPharmacy() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const PharmacyPage(),
      ),
    );
    print('Navigating to Pharmacy page');
  }

  void _navigateToChatWithDoctor() {
    if (doctorId != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatWithDoctor(doctorId: doctorId!),
        ),
      );
      print('Navigating to Chat with Doctor page');
    } else {
      // Tampilkan pesan error jika doctorId tidak tersedia
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Doctor ID not available')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.0),
              ),
              Row(
                children: [
                  Image.asset(
                    'assets/images/logo.png',
                    height: 100,
                    width: 100,
                  ),
                  Text(
                    "Bina Dokter",
                    style: GoogleFonts.poppins(
                        color: Colors.black,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                    width: 80,
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.settings_outlined,
                      size: 40,
                    ),
                    onPressed: () {
                      _showSettingsDialog();
                    },
                  )
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(
                    width: 20,
                  ),
                  Text(
                    _getGreeting(DateTime.now().hour),
                    style: GoogleFonts.poppins(
                      color: Colors.black,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    (fullname ?? ''),
                    style: GoogleFonts.poppins(
                        color: Colors.black,
                        fontSize: 14,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              isLoading
                  ? CircularProgressIndicator()
                  : prescriptions.isEmpty
                      ? Text('No Prescriptions', style: GoogleFonts.poppins())
                      : Wrap(
                          spacing: 20,
                          runSpacing: 20,
                          alignment: WrapAlignment.center,
                          children: [
                            ...prescriptions.map((prescription) {
                              return _buildMenuButton(
                                icon: Icons.medical_services,
                                label:
                                    'Prescription #${prescriptions.indexOf(prescription) + 1}',
                                onTap: () => _navigateToPrescriptionDetails(
                                    prescription['prescription_id'].toString()),
                              );
                            }).toList(),
                            _buildMenuButton(
                              icon: Icons.local_pharmacy,
                              label: 'Pharmacy',
                              onTap: _navigateToPharmacy,
                            ),
                            _buildMenuButton(
                              icon: Icons.chat,
                              label: 'Chat with Doctor',
                              onTap: () => doctorId != null ? _navigateToChatWithDoctor() : null,
                            ),
                          ],
                        ),
            ],
          ),
        ),
      ),
    );
  }

  String _getGreeting(int hour) {
    if (hour < 12) {
      return "Good Morning! ";
    } else if (hour < 17) {
      return "Good Afternoon! ";
    } else {
      return "Good Evening! ";
    }
  }

  Widget _buildMenuButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.4, // 40% dari lebar layar
        height: 150,
        decoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 50,
              color: Colors.white,
            ),
            const SizedBox(height: 10),
            Text(
              label,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
