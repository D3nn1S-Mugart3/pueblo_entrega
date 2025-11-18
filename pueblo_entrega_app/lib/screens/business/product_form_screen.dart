import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

class ProductFormScreen extends StatefulWidget {
  final String? productoId;
  final Map<String, dynamic>? productoData;

  const ProductFormScreen({super.key, this.productoId, this.productoData});

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final nameCtrl = TextEditingController();
  final descCtrl = TextEditingController();
  final priceCtrl = TextEditingController();

  // Detectar si el usuario ha hecho cambios
  bool hasChanges = false;

  @override
  void initState() {
    super.initState();
    if (widget.productoData != null) {
      nameCtrl.text = widget.productoData!['nombre'] ?? '';
      descCtrl.text = widget.productoData!['descripcion'] ?? '';
      priceCtrl.text = widget.productoData!['precio'].toString();
    }

    // Detectar cambios
    nameCtrl.addListener(() => setState(() => hasChanges = true));
    descCtrl.addListener(() => setState(() => hasChanges = true));
    priceCtrl.addListener(() => setState(() => hasChanges = true));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      hasChanges = false;
    });
  }

  Future<bool> _onWillPop() async {
    if (!hasChanges) return true;

    final salir = await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("¿Salir sin guardar?"),
        content: const Text(
          "Tienes cambios sin guardar, Si sales, se perderán.",
        ),
        actions: [
          TextButton(
            child: const Text("Cancelar"),
            onPressed: () => Navigator.pop(context, false),
          ),
          TextButton(
            child: const Text("Salir", style: TextStyle(color: Colors.red)),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );

    return salir ?? false;
  }

  Future<void> saveProduct() async {
    if (nameCtrl.text.isEmpty || priceCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Nombre y precio son obligatorios")),
      );
      return;
    }

    final uid = FirebaseAuth.instance.currentUser!.uid;
    final negocioQuery = await FirebaseFirestore.instance
        .collection('negocios')
        .where('propietario', isEqualTo: uid)
        .limit(1)
        .get();

    if (negocioQuery.docs.isEmpty) return;

    final negocioId = negocioQuery.docs.first.id;

    final data = {
      'nombre': nameCtrl.text.trim(),
      'descripcion': descCtrl.text.trim(),
      'precio': double.tryParse(priceCtrl.text.trim()) ?? 0.0,
      'negocioId': negocioId,
      'fechaActualizacion': DateTime.now(),
    };

    if (widget.productoId == null) {
      await FirebaseFirestore.instance.collection('productos').add(data);
    } else {
      await FirebaseFirestore.instance
          .collection('productos')
          .doc(widget.productoId)
          .update(data);
    }

    // ScaffoldMessenger.of(context).showSnackBar(
    //   const SnackBar(content: Text("Producto guardado correctamente")),
    // );
    hasChanges = false;
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.productoId == null ? "Agregar producto" : "Editar producto",
          ),
          leading: IconButton(
            onPressed: () async {
              if (await _onWillPop()) {
                Navigator.pop(context, false);
              }
            },
            icon: const Icon(Icons.arrow_back),
          ),
        ),
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
      ),
    );
  }
}
