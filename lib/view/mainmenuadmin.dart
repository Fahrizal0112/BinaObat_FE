import 'package:bina_dokter/Signin/Signup/signin.dart';
import 'package:bina_dokter/service/api_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart'; 

class Mainmenuadmin extends StatefulWidget {
  const Mainmenuadmin({super.key});
  @override
  State<Mainmenuadmin> createState() => _MainmenuadminState();
}

class _MainmenuadminState extends State<Mainmenuadmin> {
  String? fullname;
  String? doctorToken;
  final ApiService _apiService = ApiService(); 

  @override
  @override
  void initState() {
    super.initState();
    fetchfullname();
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
                leading: const  Icon(Icons.logout),
                title: const Text('Sign Out'),
                onTap: () {
                  Navigator.of(context).pop(); 
                  signOut(); 
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
        Navigator.pushReplacement(context,MaterialPageRoute(builder: (context) => const Signin()));
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

  void _generateDoctorToken() async {
    try {
      final response = await _apiService.createDoctorToken();
      if (response['message'] == 'Token signup dokter berhasil dibuat') {
        setState(() {
          doctorToken = response['token'];
        });
        _showTokenDialog();
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal membuat token: ${response['error']}')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan: $e')),
      );
    }
  }

  void _showTokenDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text('Token Docter', style: GoogleFonts.poppins(color: Colors.black,fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Token has been successfully created:', style: GoogleFonts.poppins(color: Colors.black)),
              const SizedBox(height: 10),
              Text(doctorToken ?? '', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightBlue,
                ),
                onPressed: () {
                  if (doctorToken != null) {
                    Clipboard.setData(ClipboardData(text: doctorToken!));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Token has been copied to clipboard', style: GoogleFonts.poppins(color: Colors.black,fontWeight: FontWeight.bold))),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Token not available', style: GoogleFonts.poppins(color: Colors.black,fontWeight: FontWeight.bold))),
                    );
                  }
                },
                child: Text('Salin Token', style: GoogleFonts.poppins(color: Colors.white)),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text('Close', style: GoogleFonts.poppins(color: Colors.black)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
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
                    onPressed: () {_showSettingsDialog();
                    },
                  )
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(width: 20,),
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
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: _generateDoctorToken,
                child: Text(
                  'Generate Token For Doctor',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
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
}
