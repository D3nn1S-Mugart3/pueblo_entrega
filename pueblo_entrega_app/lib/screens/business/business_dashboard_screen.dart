import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pueblo_entrega_app/screens/business/business_form_screen.dart';
import 'package:pueblo_entrega_app/screens/business/product_form_screen.dart';
import 'package:pueblo_entrega_app/screens/utils/snackbar.dart';

class BusinessDashboardScreen extends StatelessWidget {
  const BusinessDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Gestión de mi negocio"),
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

          final negocioDoc = negocios.first;
          final negocioId = negocioDoc.id;
          final negocio = negocioDoc.data();

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    negocio['nombre'] ?? '',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(negocio['descripcion'] ?? ''),
                  trailing: IconButton(
                    icon: const Icon(Icons.edit),
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
                const SizedBox(height: 10),
                const Text(
                  "Productos del negocio",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                          child: Text(
                            "Aún no hay productos registrados",
                            style: TextStyle(color: Colors.grey),
                          ),
                        );
                      }

                      return ListView.builder(
                        itemCount: productos.length,
                        itemBuilder: (context, i) {
                          final doc = productos[i];
                          final p = doc.data();
                          return Card(
                            child: ListTile(
                              title: Text(p['nombre'] ?? ''),
                              subtitle: Text(p['descripcion'] ?? ''),
                              trailing: PopupMenuButton<String>(
                                onSelected: (value) async {
                                  if (value == 'edit') {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => ProductFormScreen(
                                          productoId: doc.id,
                                          productoData: p,
                                        ),
                                      ),
                                    );
                                  } else if (value == 'delete') {
                                    final confirm = await showDialog<bool>(
                                      context: context,
                                      builder: (_) => AlertDialog(
                                        title: const Text(
                                          "¿Eliminar producto?",
                                        ),
                                        content: Text(
                                          "¿Seguro que deseas eliminar \"${p['nombre']}\"?\n"
                                          "Esta acción no se puede deshacer.",
                                        ),
                                        actions: [
                                          TextButton(
                                            child: const Text("Cancelar"),
                                            onPressed: () =>
                                                Navigator.pop(context, false),
                                          ),
                                          TextButton(
                                            child: const Text(
                                              "Eliminar",
                                              style: TextStyle(
                                                color: Colors.red,
                                              ),
                                            ),
                                            onPressed: () =>
                                                Navigator.pop(context, true),
                                          ),
                                        ],
                                      ),
                                    );

                                    if (confirm == true) {
                                      await FirebaseFirestore.instance
                                          .collection('productos')
                                          .doc(doc.id)
                                          .delete();

                                      showErrorSnackBar(
                                        context,
                                        "Producto eliminado con éxito",
                                      );
                                    }
                                  }
                                },
                                itemBuilder: (context) => const [
                                  PopupMenuItem(
                                    value: 'edit',
                                    child: Text("Editar"),
                                  ),
                                  PopupMenuItem(
                                    value: 'delete',
                                    child: Text(
                                      "Eliminar",
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ),
                                ],
                              ),
                              onTap: () async {
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ProductFormScreen(
                                      productoId: doc.id,
                                      productoData: p,
                                    ),
                                  ),
                                );
                                if (result == true) {
                                  showUpdatedSnackBar(
                                    context,
                                    "Producto actualizado correctamente",
                                  );
                                }
                              },
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),

      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text("Agregar producto"),
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ProductFormScreen()),
          );

          if (result == true) {
            showSuccessSnackBar(context, "Producto guardado exitosamente");
          }
        },
      ),
    );
  }
}
