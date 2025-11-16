import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProductFormScreen extends StatefulWidget {
  const ProductFormScreen({super.key});

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final nameCtrl = TextEditingController();
  final descCtrl = TextEditingController();
  final priceCtrl = TextEditingController();

  Future<void> saveProduct() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final negocioQuery = await FirebaseFirestore.instance
        .collection('negocios')
        .where('propietario', isEqualTo: uid)
        .limit(1)
        .get();

    if (negocioQuery.docs.isEmpty) return;

    final negocioId = negocioQuery.docs.first.id;

    await FirebaseFirestore.instance.collection('productos').add({
      'nombre': nameCtrl.text.trim(),
      'descripcion': descCtrl.text.trim(),
      'precio': double.tryParse(priceCtrl.text.trim()) ?? 0.0,
      'negocioId': negocioId,
      'fechaRegistro': DateTime.now(),
    });

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Agregar producto")),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(
                labelText: "Nombre del producto",
              ),
            ),
            TextField(
              controller: descCtrl,
              decoration: const InputDecoration(labelText: "Descripción"),
            ),
            TextField(
              controller: priceCtrl,
              decoration: const InputDecoration(labelText: "Precio"),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: saveProduct,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text("Guardar producto"),
            ),
          ],
        ),
      ),
    );
  }
}
