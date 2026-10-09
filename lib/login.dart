import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:payment/config.dart' as Config;

import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'config.dart';
import 'home.dart';

import 'package:http/http.dart' as http;

import 'app_locale.dart';
import 'l10n/app_localizations.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloudflare_turnstile/cloudflare_turnstile.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  String? _turnstileToken;
  final String _turnstileSiteKey =
      Config.TURNSTILE_SITE_KEY; // Use the site key from config.dart
  final String _appBaseUrl =
      Config.TURNSTILE_BASE_URL; // Use the base URL from config.dart

  String get baseUrl => API_URL;
  Uri get apiUrl => Uri.parse('$baseUrl/auth/login');

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Future<void> _handleLogin(email, password) async {
  //   if (_formKey.currentState!.validate()) {
  //     setState(() {
  //       _isLoading = true;
  //     });

  //     try {
  //       final response = await http.post(
  //         apiUrl,
  //         headers: <String, String>{
  //           'Content-Type': 'application/json; charset=UTF-8',
  //           'Accept': 'application/json',
  //         },
  //         body: jsonEncode(<String, dynamic>{
  //           'email': email,
  //           'password': password,
  //         }),
  //       );

  //       if (response.statusCode == 200) {
  //         final Map<String, dynamic> responseData = jsonDecode(response.body);
  //         final String token = responseData['token'];

  //         // 2. Save token to SharedPreferences (Works on Android, iOS, and Web)
  //         final SharedPreferences prefs = await SharedPreferences.getInstance();
  //         await prefs.setString('jwt_token', token);

  //         if (!mounted) return;

  //         setState(() {
  //           _isLoading = false;
  //         });

  //         // Navigate to MyHomePage and remove LoginScreen from backstack
  //         Navigator.of(context).pushReplacement(
  //           MaterialPageRoute(
  //             builder: (context) =>
  //                 const MyHomePage(title: 'Payment Approval System'),
  //           ),
  //         );
  //       } else {
  //         if (!mounted) return;

  //         setState(() {
  //           _isLoading = false;
  //         });

  //         await FirebaseCrashlytics.instance.recordError(
  //           'Login failed: ${response.reasonPhrase}',
  //           StackTrace.current,
  //           reason: 'Login API call failed with status code ${response.statusCode}',
  //         );

  //         ScaffoldMessenger.of(context).showSnackBar(
  //           SnackBar(
  //             content: Text('Login failed: ${response.reasonPhrase}'),
  //             backgroundColor: Colors.red,
  //           ),
  //         );
  //       }
  //     } catch (e) {
  //       if (!mounted) return;

  //       setState(() {
  //         _isLoading = false;
  //       });

  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Text('Network error occurred: $e'),
  //           backgroundColor: Colors.red,
  //         ),
  //       );
  //     }
  //   }
  // }

  Future<void> _handleLogin(email, password) async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Authenticate using Firebase Auth
        UserCredential userCredential = await FirebaseAuth.instance
            .signInWithEmailAndPassword(
              email: email.trim(),
              password: password,
            );

        if (!mounted) return;

        setState(() {
          _isLoading = false;
        });

        // Navigate to home screen on success
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) =>
                const MyHomePage(title: 'Payment Approval System'),
          ),
        );
      } on FirebaseAuthException catch (e) {
        if (!mounted) return;

        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Login failed: ${e.message}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handleGoogleSignIn() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // 1. Get the singleton instance and initialize it
      final googleSignIn = GoogleSignIn.instance;
      await googleSignIn.initialize();

      // 2. Trigger the account picker / authentication sheet
      final GoogleSignInAccount googleUser = await googleSignIn.authenticate();

      // 3. Request authorization scopes to get the access token
      final clientAuth = await googleUser.authorizationClient.authorizeScopes([
        'email',
        'profile',
      ]);

      // 4. Create Firebase credential using v7 token structure
      final credential = GoogleAuthProvider.credential(
        idToken: googleUser.authentication.idToken,
        accessToken: clientAuth.accessToken,
      );

      // 5. Sign in to Firebase
      await FirebaseAuth.instance.signInWithCredential(credential);

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      // Navigate to Home screen upon success
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) =>
              const MyHomePage(title: 'Payment Approval System'),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Google Sign-In failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: DropdownButton<Locale>(
                      value: appLocale.value,
                      items: AppLocalizations.supportedLocales.map((locale) {
                        return DropdownMenuItem<Locale>(
                          value: locale,
                          child: Text(
                            locale.languageCode == 'en'
                                ? 'English'
                                : locale.scriptCode == 'Hans'
                                ? '簡體中文'
                                : '繁體中文',
                          ),
                        );
                      }).toList(),
                      onChanged: (Locale? locale) {
                        if (locale != null) {
                          appLocale.value = locale;
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    AppLocalizations.of(context)!.welcomeMessage,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 18),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Email Address',
                      prefixIcon: Icon(Icons.email_outlined),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                          .hasMatch(value.trim())) {
                        return 'Please enter a valid email address';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: !_isPasswordVisible,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _handleLogin(
                      _emailController.text,
                      _passwordController.text,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock_outlined),
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordVisible
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters long';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _isLoading
                        ? null
                        : () => _handleLogin(
                            _emailController.text,
                            _passwordController.text,
                          ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            AppLocalizations.of(context)!.login,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.headlineMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: _isLoading ? null : _handleGoogleSignIn,
                    label: Text(
                      "google Sign-In",
                      style: Theme.of(context).textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black87,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: const BorderSide(color: Colors.grey),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 90,
                    width: double.infinity,
                    child: CloudflareTurnstile(
                      siteKey: _turnstileSiteKey,
                      baseUrl: _appBaseUrl,
                      options: TurnstileOptions(
                        size: TurnstileSize.flexible,
                      ),
                      onTokenReceived: (token) {
                        setState(() {
                          _turnstileToken = token;
                        });
                      },
                      onError: (error) {
                        setState(() {
                          _turnstileToken = null;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
