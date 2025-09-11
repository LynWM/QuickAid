import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class IntroPage extends StatelessWidget {
  const IntroPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF890000),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0),

          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,

            children: [

              //LOGO
               Image.asset(
                'lib/images/logo2.png',
                height: MediaQuery.of(context).size.height * 0.30,
                ),
              
              //const SizedBox(height: 10),

              //TITLE
              const Text(
                'QUICK AID',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 40,
                ),
              ),

              const SizedBox(height: 15),

              //SUBTITLE
              const Text(
                'Your Emergency First Aid Help',
                style: TextStyle(color: Colors.white,
                fontSize: 18),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 40),

              //BUTTON => GetStarted
              GestureDetector(
                onTap: () async {
                  SharedPreferences prefs = await SharedPreferences.getInstance();
                  await prefs.setBool('hasLaunched', true);

                  Navigator.pushReplacementNamed( context, '/auth'
                  );
                },

                child: SizedBox(
                  width: double.infinity,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: const Center(
                      child: Text(
                        'Get Started',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
