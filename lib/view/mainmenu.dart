import 'package:bina_dokter/Signin/Signup/signin.dart';
import 'package:bina_dokter/service/api_service.dart';
import 'package:bina_dokter/view/articledetail.dart';
import 'package:bina_dokter/view/pharmacypage.dart';
import 'package:bina_dokter/view/prescriptionDetailsPage.dart';
import 'package:bina_dokter/view/chatwithdoctor.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fl_chart/fl_chart.dart';

class Mainmenu extends StatefulWidget {
  const Mainmenu({super.key});
  @override
  State<Mainmenu> createState() => _MainmenuState();
}

class _MainmenuState extends State<Mainmenu> {
  int _selectedIndex = 0;
  String? fullname;
  final ApiService _apiService = ApiService();
  List<Map<String, dynamic>> prescriptions = [];
  bool isLoading = true;
  String? doctorId;
  List<Article> articles = [];

  @override
  void initState() {
    super.initState();
    fetchfullname();
    fetchPrescriptions();
    fetchArticles();
  }

  Future<void> fetchPrescriptions() async {
    try {
      final response = await _apiService.getPrescriptionsId();
      if (response['prescriptions'] != null) {
        setState(() {
          prescriptions = List<Map<String, dynamic>>.from(response['prescriptions']);
          isLoading = false;
          
          if (prescriptions.isNotEmpty && prescriptions[0]['doctor_id'] != null) {
            doctorId = prescriptions[0]['doctor_id'].toString();
          }
        });
      }
    } catch (e) {
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
  }

  void _navigateToChatWithDoctor() {
    if (doctorId != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatWithDoctor(doctorId: doctorId!),
        ),
      );
    } else {
      // Tampilkan pesan error jika doctorId tidak tersedia
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Doctor ID not available')),
      );
    }
  }

  Future<void> fetchArticles() async {
    final response = await http.get(Uri.parse('https://newsapi.org/v2/top-headlines?country=id&category=health&apiKey=6f2612131a394c3aa62df46b3075a398'));
    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      setState(() {
        articles = (jsonData['articles'] as List).map((article) => Article.fromJson(article)).toList();
      });
    } else {
      throw Exception('Failed to load articles');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: IndexedStack(
          index: _selectedIndex,
          children: [
            _buildHomeScreen(),
            _buildArticleScreen(),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.article_outlined),
            label: 'Articles',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.lightBlue,
        onTap: _onItemTapped,
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _buildHomeScreen() {
    return SingleChildScrollView(
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
              ? const CircularProgressIndicator()
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
                        }),
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
    );
  }

  Widget _buildArticleScreen() {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 20),
          Text(
            'Health Articles',
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: articles.length,
            itemBuilder: (context, index) {
              return Column(
                children: [
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    title: Text(articles[index].title),
                    subtitle: Text(articles[index].description),
                    onTap: () {
                      // Navigasi ke halaman detail artikel
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ArticleDetailPage(
                            title: articles[index].title,
                            description: articles[index].description,
                          ),
                        ),
                      );
                    },
                  ),
                  const Divider(), // Garis pemisah
                ],
              );
            },
          ),
        ],
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

class Article {
  final String title;
  final String description;

  Article({required this.title, required this.description}); 

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      title: json['title'] ?? '',
      description: json['description'] ?? '',
    );
  }
}
