import 'package:bina_dokter/Signin/Signup/signin.dart';
import 'package:bina_dokter/service/api_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';


class Mainmenuadmin extends StatefulWidget {
  const Mainmenuadmin({super.key});
  @override
  State<Mainmenuadmin> createState() => _MainmenuadminState();
}

class _MainmenuadminState extends State<Mainmenuadmin> {
  String? fullname;
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
