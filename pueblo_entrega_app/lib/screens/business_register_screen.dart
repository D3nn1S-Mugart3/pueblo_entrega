import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BusinessRegisterScreen extends StatefulWidget {
  const BusinessRegisterScreen({super.key});

  @override
  State<BusinessRegisterScreen> createState() => _BusinessRegisterScreenState();
}

class _BusinessRegisterScreenState extends State<BusinessRegisterScreen> {
  final nameCtrl = TextEditingController();
  final addressCtrl = TextEditingController();
  final descCtrl = TextEditingController();

  Future<void> saveBusiness() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    await FirebaseFirestore.instance.collection('negocios').add({
      'nombre': nameCtrl.text.trim(),
      'direccion': addressCtrl.text.trim(),
      'descripcion': descCtrl.text.trim(),
      'propietario': uid,
      'fechaRegistro': DateTime.now(),
    });
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Registrar negocio")),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(
                labelText: "Nombre del negocio",
              ),
            ),
            TextField(
              controller: addressCtrl,
              decoration: const InputDecoration(labelText: "Dirección"),
            ),
            TextField(
              controller: descCtrl,
              decoration: const InputDecoration(labelText: "Descripción"),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: saveBusiness,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text("Guardar negocio"),
            ),
          ],
        ),
      ),
    );
  }
}
