import 'package:flutter/material.dart';
import 'package:whisky_hikes/config/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:whisky_hikes/UI/auth/signup/sign_up_page_view_model.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key, required this.viewModel});

  final SignUpPageViewModel viewModel;

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool isLegalAge = false;

  void signUp() async {
    final email = _emailController.text;
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    try {
      if (password != confirmPassword) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(AppLocalizations.of(context)!.passwordNotMatch)));
      } else if (!isLegalAge) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(AppLocalizations.of(context)!.legalAgeInfo)));
      } else {
        await widget.viewModel.signUpWithEmailPassword(
            email, password, {"is_legal_age": isLegalAge});
      }
    } catch (e) {
      if (mounted) {
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
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.password,
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _confirmPasswordController,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.passwordConfirm,
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(AppLocalizations.of(context)!.iAmLegalAge),
                Checkbox(
                    value: isLegalAge,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                    onChanged: (bool? value) {
                      setState(() {
                        isLegalAge = value!;
                      });
                    }),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: signUp,
              child: Text(AppLocalizations.of(context)!.signup),
            ),
            const SizedBox(
              height: 16,
            ),
            TextButton(
                onPressed: () => context.go('/login'),
                child: Text(AppLocalizations.of(context)!.login))
          ],
        ));
  }
}
