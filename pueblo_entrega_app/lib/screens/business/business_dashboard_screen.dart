import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pueblo_entrega_app/screens/business/business_form_screen.dart';
import 'package:pueblo_entrega_app/screens/business/product_form_screen.dart';

class BusinessDashboardScreen extends StatelessWidget {
  const BusinessDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Mi negocio"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => FirebaseAuth.instance.signOut(),
          ),
        ],
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('negocios')
            .where('propietario', isEqualTo: uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final negocios = snapshot.data!.docs;

          if (negocios.isEmpty) {
            return Center(
              child: ElevatedButton.icon(
                icon: Icon(Icons.store),
                label: Text("Registrar mi negocio"),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const BusinessFormScreen(),
                    ),
                  );
                },
              ),
            );
          }

          final negocio = negocios.first.data();
          final negocioId = snapshot.data!.docs.first.id;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                title: Text(negocio['nombre'] ?? ''),
                subtitle: Text(negocio['descripcion'] ?? ''),
                trailing: IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BusinessFormScreen(
                          negocioId: negocioId,
                          negocioData: negocio,
                        ),
                      ),
                    );
                  },
                ),
              ),
              const Padding(
                padding: EdgeInsetsGeometry.all(16),
                child: Text(
                  "Productos",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                child: StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('productos')
                      .where('negocioId', isEqualTo: negocioId)
                      .snapshots(),
                  builder: (context, prodSnapshot) {
                    if (!prodSnapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final productos = prodSnapshot.data!.docs;

                    if (productos.isEmpty) {
                      return const Center(
                        child: Text("Aún no hay productos registrados"),
                      );
                    }

                    return ListView.builder(
                      itemCount: productos.length,
                      itemBuilder: (context, i) {
                        final p = productos[i].data();
                        return Card(
                          child: ListTile(
                            title: Text(p['nombre']),
                            subtitle: Text("\$${p['precio']}"),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text("Agregar producto"),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ProductFormScreen()),
          );
        },
      ),
    );
  }
}
