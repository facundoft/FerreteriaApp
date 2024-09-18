import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:myapp/Pages/create_product.dart';
import 'package:myapp/Pages/sign_in.dart';
import 'package:myapp/Services/Database.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:myapp/Pages/home.dart';
import 'package:myapp/Pages/home_admin.dart';

import '../main.dart';

class AuthSignIn extends StatefulWidget {
  const AuthSignIn({Key? key}) : super(key: key);

  @override
  _AuthSignInState createState() => _AuthSignInState();
}

class _AuthSignInState extends State<AuthSignIn> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;


  SupabaseClient get _client => Supabase.instance.client;

  ProductsRepository get _repository => ProductsRepository(_client);

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error de inicio de sesión'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('Aceptar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> signIn() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _client.auth.signInWithPassword(
        password: _passwordController.text.trim(),
        email: _emailController.text.trim(),
      );

      if (!mounted) return;

      if (response.user == null) {
        _showErrorDialog('No se encontró una cuenta con ese correo.');
        return;
      }

      final email = _emailController.text.trim();

      final emailDomain = email.split('@').last;

      if (emailDomain == 'admin') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ListProductsAdminScreen()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ListProductsScreen()),
        );
      }
    } on AuthException catch (e) {
      _showErrorDialog('Correo o contraseña incorrectos. Por favor, verifica tus datos.');
    } catch (e) {
      _showErrorDialog('Ocurrió un error inesperado. Inténtalo nuevamente más tarde.');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/background.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color.fromARGB(255, 37, 37, 37).withOpacity(0.7),
                    Colors.black.withOpacity(0.7),
                  ],
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Ferreteria',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 50,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 32),
                  _buildInputField('Email', _emailController),
                  const SizedBox(height: 20),
                  _buildInputField('Password', _passwordController, isPassword: true),
                  const SizedBox(height: 32),
                  _isLoading
                      ? CircularProgressIndicator()
                      : _buildSignInButton(),
                  const SizedBox(height: 24),
                  _buildSignUpText(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(String label, TextEditingController controller, {bool isPassword = false}) {
    return TextField(
      controller: controller,
      obscureText: isPassword, // True si es un campo de contraseña
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey), // Estilo para la etiqueta del campo
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.blue),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      style: TextStyle(color: Colors.black),
      cursorColor: Colors.black,  // Color del cursor en el campo
    );
  }

  Widget _buildSignInButton() {
    return GestureDetector(
      onTap: signIn,
      child: Container(
        width: double.infinity,
        height: 50,
        decoration: BoxDecoration(
          color: const Color(0xFF0ACF83),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Center(
          child: Text(
            'Iniciar Sesión',
            style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Widget _buildSignUpText(BuildContext context) {
    return Text.rich(
      TextSpan(
        children: [
          const TextSpan(
            text: 'No tienes cuenta? ',
            style: TextStyle(color: Colors.white, fontSize: 14),
          ),
          TextSpan(
            text: 'Regístrate aquí',
            style: const TextStyle(
              color: Color(0xFF0ACF83),
              fontSize: 14,
              fontWeight: FontWeight.bold,
              decoration: TextDecoration.underline,
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Sign_in()),
                );
              },
          ),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
