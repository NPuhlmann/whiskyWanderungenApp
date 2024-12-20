import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../../services/auth/auth_service.dart';

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
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.passwordNotMatch)));
      } else if(!is_legal_age){
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.legalAgeInfo)));
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
          title: Text(AppLocalizations.of(context)!.signup),
        ),
        body: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 100),
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.email,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.password,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
              ),
              obscureText: true,
            ),

            const SizedBox(height: 16),

            TextField(
              controller: _confirmPasswordController,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.passwordConfirm,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(AppLocalizations.of(context)!.iAmLegalAge),
                Checkbox(value: is_legal_age, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),onChanged: (bool? value){
                  setState(() {
                    is_legal_age = value!;
                  });
                }),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: signUp,
              child: Text(AppLocalizations.of(context)!.signup),
            ),

          ],
        )
    );
  }

}
