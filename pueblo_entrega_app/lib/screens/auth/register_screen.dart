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
  final confirmPassCtrl = TextEditingController();

  bool isBusiness = false;
  bool loading = false;
  bool obscurePassword = true;
  bool obscureConfirmPassword = true;

  bool passwordValid = false;
  bool passwordsMatch = false;

  bool hasUppercase = false;
  bool hasLowercase = false;
  bool hasNumber = false;
  bool hasMinLength = false;
  bool hasSpecialChar = false;
  double passwordStrength = 0.0;
  String strengthLabel = "Débil";
  Color strengthColor = Colors.red;

  bool emailValid = false;

  bool isValidEmail(String email) {
    final emailRegex = RegExp(
      r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$",
    );
    return emailRegex.hasMatch(email);
  }

  // Validación de Email
  void validateEmail() {
    final email = emailCtrl.text.trim();

    setState(() {
      emailValid = isValidEmail(email);
    });
  }

  // Validación de contraseña
  void validatePassword() {
    final pass = passCtrl.text;
    final confirm = confirmPassCtrl.text;

    // Validación avanzada para la creación de contraseña
    setState(() {
      hasUppercase = pass.contains(RegExp(r'[A-Z]'));
      hasLowercase = pass.contains(RegExp(r'[a-z]'));
      hasNumber = pass.contains(RegExp(r'[0-9]'));
      hasMinLength = pass.length >= 8;
      hasSpecialChar = pass.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));

      passwordValid = hasUppercase && hasLowercase && hasNumber && hasMinLength;
      passwordsMatch = pass == confirm;

      // Calculo de fortaleza
      passwordStrength = 0;
      if (hasMinLength) passwordStrength += 0.25;
      if (hasUppercase) passwordStrength += 0.25;
      if (hasNumber) passwordStrength += 0.25;
      if (hasSpecialChar) passwordStrength += 0.25;

      if (passwordStrength <= 0.25) {
        strengthLabel = "Débil";
        strengthColor = Colors.red;
      } else if (passwordStrength <= 0.75) {
        strengthLabel = "Media";
        strengthColor = Colors.orange;
      } else {
        strengthLabel = "Fuerte";
        strengthColor = Colors.green;
      }
    });
  }

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

    if (!emailValid) {
      showAppSnackBar(
        context,
        message: "Ingresa un correo válido",
        type: SnackType.error,
      );
      return;
    }

    if (!passwordValid) {
      showAppSnackBar(
        context,
        message: "La contraseña no cumple los requisitos",
        type: SnackType.error,
      );
      return;
    }

    if (passCtrl.text != confirmPassCtrl.text) {
      showAppSnackBar(
        context,
        message: "Las contraseñas no coinciden",
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
      setState(() => loading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    passCtrl.addListener(validatePassword);
    confirmPassCtrl.addListener(validatePassword);
    emailCtrl.addListener(validateEmail);
  }

  @override
  void dispose() {
    passCtrl.dispose();
    confirmPassCtrl.dispose();
    nameCtrl.dispose();
    emailCtrl.dispose();
    super.dispose();
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
              const SizedBox(height: 4),
              if (emailCtrl.text.isNotEmpty)
                Row(
                  children: [
                    const SizedBox(width: 8),
                    Icon(
                      emailValid ? Icons.check_circle_sharp : Icons.error_sharp,
                      color: emailValid ? Colors.green : Colors.red,
                      size: 18,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      emailValid
                          ? "Correo válido"
                          : "Correo electrónico inválido",
                      style: TextStyle(
                        fontSize: 13,
                        color: emailValid ? Colors.green : Colors.red,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 18),
              TextField(
                controller: passCtrl,
                obscureText: obscurePassword,
                decoration: InputDecoration(
                  labelText: "Contraseña",
                  prefixIcon: Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      obscurePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                    ),
                    onPressed: () {
                      setState(() {
                        obscurePassword = !obscurePassword;
                      });
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Text(
                    "Fortaleza:",
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(width: 6),
                  Tooltip(
                    message:
                        "Usa mayúsculas, minúsculas, números y opcionalmente un carácter especial.",
                    child: Icon(
                      Icons.info_outline,
                      size: 16,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    strengthLabel,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: strengthColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadiusGeometry.circular(10),
                child: LinearProgressIndicator(
                  value: passwordStrength,
                  minHeight: 8,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(strengthColor),
                ),
              ),
              const SizedBox(height: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildRequirement("Mínimo 8 caracteres", hasMinLength),
                  _buildRequirement("Una letra mayúscula", hasUppercase),
                  _buildRequirement("Una letra minúscula", hasLowercase),
                  _buildRequirement("Un número", hasNumber),
                  _buildRequirement("Carácter especial", hasSpecialChar),
                ],
              ),
              const SizedBox(height: 18),
              TextField(
                controller: confirmPassCtrl,
                obscureText: obscureConfirmPassword,
                decoration: InputDecoration(
                  labelText: "Confirmar contraseña",
                  prefixIcon: Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      obscureConfirmPassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                    ),
                    onPressed: () {
                      setState(() {
                        obscureConfirmPassword = !obscureConfirmPassword;
                      });
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              if (confirmPassCtrl.text.isNotEmpty)
                Row(
                  children: [
                    SizedBox(width: 8),
                    Icon(
                      passwordsMatch
                          ? Icons.check_circle_sharp
                          : Icons.error_sharp,
                      color: passwordsMatch ? Colors.green : Colors.red,
                      size: 18,
                    ),
                    SizedBox(width: 6),
                    Text(
                      passwordsMatch
                          ? "Las contraseñas coinciden"
                          : "Las contraseñas no coinciden",
                      style: TextStyle(
                        fontSize: 13,
                        color: passwordsMatch ? Colors.green : Colors.red,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
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

Widget _buildRequirement(String text, bool valid) {
  return Row(
    children: [
      const SizedBox(width: 8),
      Icon(
        valid ? Icons.check_circle_sharp : Icons.cancel_sharp,
        color: valid ? Colors.green : Colors.red,
        size: 18,
      ),
      const SizedBox(width: 6),
      Text(
        text,
        style: TextStyle(
          color: valid ? Colors.green : Colors.red,
          fontSize: 13,
        ),
      ),
    ],
  );
}
