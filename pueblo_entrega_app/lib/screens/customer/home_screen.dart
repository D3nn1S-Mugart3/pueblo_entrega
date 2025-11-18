import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pueblo_entrega_app/screens/business/business_dashboard_screen.dart';
// import '../business_register_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Negocios locales"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => FirebaseAuth.instance.signOut(),
          ),
        ],
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('negocios').snapshots(),
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          var negocios = snap.data!.docs;
          return ListView.builder(
            itemCount: negocios.length,
            itemBuilder: (context, i) {
              var negocio = negocios[i].data();
              return Card(
                child: ListTile(
                  title: Text(negocio['nombre'] ?? ''),
                  subtitle: Text(negocio['direccion'] ?? ''),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FutureBuilder(
        future: FirebaseFirestore.instance
            .collection('usuarios')
            .doc(user.uid)
            .get(),
        builder: (context, snap) {
          if (!snap.hasData) return SizedBox();

          // Validacion obligatoria si existe o no algun negocio
          if (!snap.data!.exists) return const SizedBox();

          final data = snap.data!.data();

          // Evitar crasheo si el campo no existe
          final bool esNegocio = data?['esNegocio'] ?? false;

          // Ocultar para clientes normales
          if (!esNegocio) return SizedBox();

          return FloatingActionButton.extended(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const BusinessDashboardScreen(),
                ),
              );
            },
            label: const Text("Registrar negocio"),
            icon: const Icon(Icons.store),
          );
        },
      ),
    );
  }
}
