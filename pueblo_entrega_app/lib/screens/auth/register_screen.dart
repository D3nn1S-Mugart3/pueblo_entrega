import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pueblo_entrega_app/screens/business_register_screen.dart';
import 'package:pueblo_entrega_app/screens/customer/home_screen.dart';

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

  Future<void> register() async {
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: ${e.toString()}")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Crear cuenta")),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: "Nombre"),
            ),
            TextField(
              controller: emailCtrl,
              decoration: const InputDecoration(labelText: "Correo"),
            ),
            TextField(
              controller: passCtrl,
              decoration: const InputDecoration(labelText: "Contraseña"),
              obscureText: true,
            ),
            Row(
              children: [
                Checkbox(
                  value: isBusiness,
                  onChanged: (v) => setState(() => isBusiness = v!),
                ),
                const Text("Soy dueño de un negocio"),
              ],
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: register,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text("Registrar"),
            ),
          ],
        ),
      ),
    );
  }
}
