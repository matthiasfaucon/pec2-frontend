import 'dart:developer' as developer;
import 'package:firstflutterapp/components/form/custom_form_field.dart';
import 'package:firstflutterapp/components/form/loading_button.dart';
import 'package:firstflutterapp/config/router.dart';
import 'package:firstflutterapp/notifiers/userNotififers.dart';
import 'package:firstflutterapp/services/api_service.dart';
import 'package:firstflutterapp/services/validators_service.dart';
import 'package:firstflutterapp/theme.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginView extends StatefulWidget {
  @override
  _LoginViewState createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final ApiService _apiService = ApiService();
  bool _isLoading = false;
  bool _isSubmitted = false;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _onSubmit() async {
    setState(() {
      _isLoading = true;
      _isSubmitted = true;
    });

    final userNotifier = context.read<UserNotifier>();
    final email = _emailController.text;
    final password = _passwordController.text;

    // if (!_formKey.currentState!.validate()) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     SnackBar(
    //       backgroundColor: Colors.red,
    //       content: Text('Veuillez renseigner tous les champs'),
    //     ),
    //   );
    //   return;
    // }

    try {
      final response = await _apiService.request(
        method: 'POST',
        endpoint: '/login',
        body: {'email': email, 'password': password},
        withAuth: false,
      );

      final token = response.data['token'];
      developer.log('Mobile login - Token reçu: $token');

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', token);
      userNotifier.onAuthenticationSuccess(response.data);

      if (!mounted) {
        return;
      }
      if (await userNotifier.isAdmin()) {
        context.go(adminDashboard);
      } else {
        context.go(homeRoute);
      }
    } catch (e) {
      setState(() {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(backgroundColor: Colors.red, content: Text('Erreur')),
        );
      });
      developer.log('Erreur login: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            double formWidth = constraints.maxWidth > 800
                ? constraints.maxWidth / 3 // 1/3 de largeur si large écran
                : double.infinity; // plein écran sur mobile

            return Center(
              child: Container(
                width: formWidth,
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Ravis de vous revoir sur",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w500),
                    ),
                    const Text(
                      "OnlyFlick",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 28, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 40),
                    Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          CustomTextField(
                            controller: _emailController,
                            label: 'Email',
                            validators: [RequiredValidator(), EmailValidator()],
                          ),
                          const SizedBox(height: 16),
                          CustomTextField(
                            controller: _passwordController,
                            label: 'Mot de passe',
                            obscure: true,
                            validators: [RequiredValidator()],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              const Text("Pas de compte ?",
                                  style: TextStyle(fontSize: 14)),
                              InkWell(
                                onTap: () => context.go(registerRoute),
                                child: Text(
                                  " (S'inscrire)",
                                  style: TextStyle(
                                    color: AppTheme.darkColor,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          LoadingButton(
                            label: 'Se connecter',
                            isSubmitted: _isSubmitted,
                            onPressed: _onSubmit,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}