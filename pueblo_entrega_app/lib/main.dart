import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pueblo_entrega_app/screens/utils/app_loader.dart';
import 'package:pueblo_entrega_app/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:pueblo_entrega_app/screens/business/business_dashboard_screen.dart';
import 'package:pueblo_entrega_app/screens/auth/login_screen.dart';
import 'package:pueblo_entrega_app/screens/customer/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    debugPrint("✅ Firebase innitialized successflully");
  } catch (e) {
    debugPrint(
      "⚠️  No se encontró firebase_options.dart o falló la carga, inicializando Firebase manualmente...",
    );
    await Firebase.initializeApp();
  }
  runApp(const PuebloEntregaApp());
}

class PuebloEntregaApp extends StatelessWidget {
  const PuebloEntregaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mi Pueblo App',
      theme: ThemeData(
        colorSchemeSeed: Colors.green,
        useMaterial3: true,
        textTheme: Theme.of(context).textTheme.apply(fontFamily: 'Poppins'),
      ),
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}

class AuthWrapperScreen extends StatelessWidget {
  const AuthWrapperScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError) {
          return const Scaffold(
            body: Center(
              child: Text(
                'Ocurrió un error al auntenticarse con Firebase. 😥',
                style: TextStyle(color: Colors.red),
              ),
            ),
          );
        }

        if (snapshot.hasData) {
          return FutureBuilder(
            future: FirebaseFirestore.instance
                .collection('usuarios')
                .doc(snapshot.data!.uid)
                .get(),
            builder: (context, userSnapshot) {
              if (!userSnapshot.hasData) {
                return Scaffold(body: appLoaderWidget(text: "Cargando..."));
              }
              final data = userSnapshot.data!.data();
              final esNegocio = data?['esNegocio'] ?? false;

              if (esNegocio) {
                return const BusinessDashboardScreen();
              } else {
                return const HomeScreen();
              }
            },
          );
        }

        return const LoginScreen();
      },
    );
  }
}
