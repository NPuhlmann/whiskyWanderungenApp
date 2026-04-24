import 'package:flutter/material.dart';
import 'package:whisky_hikes/config/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'login_page_view_model.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key, required this.viewModel});

  final LoginPageViewModel viewModel;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  void login() async {
    final email = _emailController.text;
    final password = _passwordController.text;

    try {
      await widget.viewModel.loginWithEmailAndPassword(email, password);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 100),
        children: [
          Image.asset('assets/logo.png', height: 250, width: 250),
          Center(
            child: Text(
              AppLocalizations.of(context)!.appTitle,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _emailController,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              labelText: AppLocalizations.of(context)!.email,
            ),
          ),

          const SizedBox(height: 16),

          TextField(
            controller: _passwordController,

            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              labelText: AppLocalizations.of(context)!.password,
            ),
            obscureText: true,
          ),
          const SizedBox(height: 16),

          ElevatedButton(
            onPressed: login,
            child: Text(AppLocalizations.of(context)!.login),
          ),

          const SizedBox(height: 16),

          Center(
            child: TextButton(
              onPressed: () {
                context.go("/signUp");
              },
              child: Text(AppLocalizations.of(context)!.signup),
            ),
          ),
        ],
      ),
    );
  }
}
