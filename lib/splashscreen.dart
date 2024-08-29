import 'package:bina_dokter/Signin/Signup/signin.dart';
import 'package:bina_dokter/Signin/Signup/signup_doctor.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Splashscreen extends StatefulWidget {
  const Splashscreen({super.key});
  @override
  State<Splashscreen> createState() => _SplashscreenState();
}

class _SplashscreenState extends State<Splashscreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/images/animasi.png', width: 250),
            const SizedBox(height: 20),
            Text(
              "Choose Your Role",
              style: GoogleFonts.poppins(
                  color: Colors.black,
                  fontSize: 24,
                  fontWeight: FontWeight.bold),
            ),
            ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text("About Application", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                      content: Text(
                        "Bina Dokter adalah aplikasi inovatif yang menghubungkan pasien dengan dokter untuk konsultasi kesehatan online. Fitur utama adalah memberikan arahan pengobatan yang tepat dan personal. Dokter dapat meresepkan obat secara digital, dan pasien dapat menerima petunjuk penggunaan obat yang jelas. Dengan dukungan tenaga medis profesional, kami memastikan setiap pengguna mendapatkan panduan pengobatan yang aman dan efektif sesuai dengan kondisi kesehatannya.",
                        style: GoogleFonts.poppins(),
                      ),
                      actions: <Widget>[
                        TextButton(
                          child: Text("Close", style: GoogleFonts.poppins()),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    );
                  },
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightBlue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                "About Application",
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            SizedBox(
              width: 250,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const SignupDoctor()));
                },
                style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.lightBlue,
                    backgroundColor: Colors.white,
                    side: const BorderSide(color: Colors.lightBlue),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10))),
                child: Text("Are your a doctor?",
                    style: GoogleFonts.poppins(
                        color: Colors.lightBlue,
                        fontSize: 16,
                        fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            SizedBox(
              width: 250,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const Signin()));
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightBlue,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5))),
                child: Text("Are your a patient?",
                    style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
