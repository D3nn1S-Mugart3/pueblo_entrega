import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class BusinessFormScreen extends StatefulWidget {
  final String? negocioId;
  final Map<String, dynamic>? negocioData;

  const BusinessFormScreen({super.key, this.negocioId, this.negocioData});

  @override
  State<BusinessFormScreen> createState() => _BusinessFormScreenState();
}

class _BusinessFormScreenState extends State<BusinessFormScreen> {
  final nameCtrl = TextEditingController();
  final descCtrl = TextEditingController();
  final addressCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.negocioData != null) {
      nameCtrl.text = widget.negocioData!['nombre'] ?? '';
      descCtrl.text = widget.negocioData!['descripcion'] ?? '';
      addressCtrl.text = widget.negocioData!['direccion'] ?? '';
      phoneCtrl.text = widget.negocioData!['telefono'] ?? '';
    }
  }

  Future<void> saveBusiness() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final data = {
      'nombre': nameCtrl.text.trim(),
      'descripcion': descCtrl.text.trim(),
      'direccion': addressCtrl.text.trim(),
      'telefono': phoneCtrl.text.trim(),
      'propietario': uid,
      'fechaRegistro': DateTime.now(),
    };

    if (widget.negocioId == null) {
      await FirebaseFirestore.instance.collection('negocios').add(data);
    } else {
      await FirebaseFirestore.instance
          .collection('negocios')
          .doc(widget.negocioId)
          .update(data);
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Datos del negoecio")),
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
              controller: descCtrl,
              decoration: const InputDecoration(labelText: "Descripción"),
            ),
            TextField(
              controller: addressCtrl,
              decoration: const InputDecoration(labelText: "Dirección"),
            ),
            TextField(
              controller: phoneCtrl,
              decoration: const InputDecoration(labelText: "Telefono"),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: saveBusiness,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text("Guardar"),
            ),
          ],
        ),
      ),
    );
  }
}
