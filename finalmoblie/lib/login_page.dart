import 'package:flutter/material.dart';
import 'pocketbase_service.dart';
import 'home_page.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final pbService = PocketBaseService();
  bool loading = false;

  Future<void> login() async {
    setState(() => loading = true);
    try {
      await pbService.login(emailController.text, passwordController.text);
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomePage()));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Login failed: $e')));
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(controller: emailController, decoration: const InputDecoration(labelText: 'Email')),
            TextField(controller: passwordController, obscureText: true, decoration: const InputDecoration(labelText: 'Password')),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: loading ? null : login, child: const Text('Login')),
            TextButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => RegisterPage())),
              child: const Text('Create account'),
            )
          ],
        ),
      ),
    );
  }
}
