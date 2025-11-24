import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pueblo_entrega_app/screens/business_register_screen.dart';
import 'package:pueblo_entrega_app/screens/customer/home_screen.dart';
import 'package:pueblo_entrega_app/screens/utils/snackbar.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  bool isBusiness = false;

  bool loading = false;

  Future<void> register() async {
    if (nameCtrl.text.isEmpty ||
        emailCtrl.text.isEmpty ||
        passCtrl.text.isEmpty) {
      showAppSnackBar(
        context,
        message: "Todos los campos son obligatorios.",
        type: SnackType.error,
      );
      return;
    }

    setState(() => loading = true);

    try {
      UserCredential user = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: emailCtrl.text.trim(),
            password: passCtrl.text.trim(),
          );

      final uid = user.user!.uid;

      // Guarda la información adicional en Firestore
      await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(user.user!.uid)
          .set({
            'nombre': nameCtrl.text.trim(),
            'correo': emailCtrl.text.trim(),
            'esNegocio': isBusiness,
          });

      // Redirigir según el tipo de usuario
      if (isBusiness) {
        // Pantalla de registro de negocio
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const BusinessRegisterScreen()),
        );
      } else {
        // Pantalla principal para usuarios regulares
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    } catch (e) {
      showAppSnackBar(
        context,
        message: "Error: ${e.toString().replaceAll("Exception", "")}",
        type: SnackType.error,
      );
    } finally {
      setState(() => loading = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black87),
        title: Text(
          "Crear cuenta",
          style: TextStyle(
            color: Colors.green[800],
            fontSize: 24,
            fontWeight: FontWeight.bold,
            fontFamily: "Poppins",
          ),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: RichText(
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
              ),
              const SizedBox(height: 30),
              TextField(
                controller: nameCtrl,
                decoration: InputDecoration(
                  labelText: "Nombre completo",
                  prefixIcon: Icon(Icons.person_2_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              TextField(
                controller: emailCtrl,
                decoration: InputDecoration(
                  labelText: "Correo electrónico",
                  prefixIcon: Icon(Icons.email_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              TextField(
                controller: passCtrl,
                decoration: InputDecoration(
                  labelText: "Contraseña",
                  prefixIcon: Icon(Icons.lock_outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Checkbox(
                    value: isBusiness,
                    activeColor: Colors.green[800],
                    onChanged: (v) => setState(() => isBusiness = v!),
                  ),
                  const Text(
                    "Soy dueño de un negocio",
                    style: TextStyle(fontSize: 15),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: loading ? null : register,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[800],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: loading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          "Crear cuenta",
                          style: TextStyle(fontSize: 16, color: Colors.white),
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
