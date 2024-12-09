import 'package:flutter/material.dart';

import '../services/auth/auth_service.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {

  final authService= AuthService();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool is_legal_age = false;

  void signUp() async{
    final email = _emailController.text;
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    try {
      if(password != confirmPassword){
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Passwords do not match")));
      } else if(!is_legal_age){
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("You must be of legal age to sign up")));
      }
      else{
        await authService.signUpWithEmailPassword(email, password, {"is_legal_age": is_legal_age});
        Navigator.pushNamed(context, '/login');
      }
    } catch (e) {
      if(mounted){
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Sign Up'),
        ),
        body: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 100),
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'Password',

              ),
              obscureText: true,
            ),

            const SizedBox(height: 16),

            TextField(
              controller: _confirmPasswordController,
              decoration: const InputDecoration(
                labelText: 'Confirm Password',

              ),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('I am of legal age'),
                Checkbox(value: is_legal_age, onChanged: (bool? value){
                  setState(() {
                    is_legal_age = value!;
                  });
                }),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: signUp,
              child: const Text('Sign Up'),
            ),

          ],
        )
    );
  }

}
