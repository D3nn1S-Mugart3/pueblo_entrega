import 'package:flutter/material.dart';
import 'package:pueblo_entrega_app/main.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    // _fadeAnimation = Tween<double>(
    //   begin: 0,
    //   end: 1,
    // ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutQuad,
    );

    // _scaleAnimation = Tween<double>(
    //   begin: 0.7,
    //   end: 1,
    // ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );

    _controller.forward();

    Future.delayed(const Duration(seconds: 4), () {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AuthWrapperScreen()),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/images/pueblo_entrega.png',
                  width: 180,
                  height: 180,
                ),
                SizedBox(height: 25),
                RichText(
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      fontFamily: "Poppins",
                    ),
                    children: [
                      TextSpan(
                        text: "Pueblo ",
                        style: TextStyle(color: Colors.green[800]),
                      ),
                      TextSpan(
                        text: "Entrega",
                        style: TextStyle(color: Colors.orange[700]),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 10),
                Text(
                  'Tu mercado local a un click',
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 16,
                    fontFamily: "Poppins",
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 40),
                CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation(Colors.green),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
