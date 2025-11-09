import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

class ComingSoonPage extends StatelessWidget {
  const ComingSoonPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('')),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 🌄 Background vector or image

          // Semi-transparent overlay for readability
          Container(color: Colors.black.withOpacity(0)),

          // Main content
          SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Lottie animation (fun + energy)
                    Lottie.network(
                      'https://assets9.lottiefiles.com/packages/lf20_gjmecwii.json',
                      width: 220,
                      height: 220,
                      repeat: true,
                    ),
                    const SizedBox(height: 16),

                    // Title
                    Text(
                      " Coming Soon",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 30,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Subtitle
                    Text(
                      "We’re crafting something amazing for you.\nStay tuned for the big reveal!",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        color: Colors.blueGrey,
                        fontSize: 16,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Notify button
                    // ElevatedButton.icon(
                    //   onPressed: () {},
                    //   icon: const Icon(Icons.notifications_active_outlined),
                    //   label: const Text("Notify Me"),
                    //   style: ElevatedButton.styleFrom(
                    //     foregroundColor: Colors.white,
                    //     backgroundColor: Colors.white.withOpacity(0.15),
                    //     elevation: 0,
                    //     padding: const EdgeInsets.symmetric(
                    //       horizontal: 28,
                    //       vertical: 12,
                    //     ),
                    //     shape: RoundedRectangleBorder(
                    //       borderRadius: BorderRadius.circular(30),
                    //       side: const BorderSide(color: Colors.white),
                    //     ),
                    //   ),
                    // ),
                  ],
                ),
              ),
            ),
          ),

          // Footer credit
          // Positioned(
          //   bottom: 24,
          //   left: 0,
          //   right: 0,
          //   child: Center(
          //     child: Text(
          //       "© ${DateTime.now().year} YourCompany — All rights reserved",
          //       style: GoogleFonts.inter(
          //         color: Colors.white.withOpacity(0.7),
          //         fontSize: 12,
          //       ),
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }
}
