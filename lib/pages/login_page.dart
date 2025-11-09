import 'package:afghan_bazar/pages/home.dart';
import 'package:afghan_bazar/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool isLogin = true;
  final _formKey = GlobalKey<FormState>();

  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  final confirmCtrl = TextEditingController();

  bool loading = false;

  void toggle() {
    setState(() => isLogin = !isLogin);
  }

  Future<void> submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => loading = true);

    final apiEndpoint = AuthService.baseUrl;

    final url = isLogin
        ? Uri.parse("$apiEndpoint/login")
        : Uri.parse("$apiEndpoint/register");

    final body = isLogin
        ? {"email": emailCtrl.text, "password": passCtrl.text}
        : {
            "name": nameCtrl.text,
            "email": emailCtrl.text,
            "password": passCtrl.text,
            "password_confirmation": confirmCtrl.text,
          };

    try {
      final res = await http.post(
        url,
        body: body,
        headers: {"Accept": "application/json"},
      );

      if (res.statusCode == 200 || res.statusCode == 201) {
        final data = json.decode(res.body);

        // store token
        if (data["access_token"] != null) {
          final prefs = await SharedPreferences.getInstance();
          AuthService.saveTokens(data["access_token"], data["refresh_token"]);

          final user = data["user"];

          await prefs.setInt("user_id", user["id"]);
          await prefs.setString("user_name", user["name"]);
          await prefs.setString("user_email", user["email"]);
          await prefs.setString('user_info', json.encode(data['user']));
        }

        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(
        //     content: Text(isLogin ? "Login successful" : "Account created"),
        //   ),
        // );

        // ✅ Navigate to home/dashboard page
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomePage()),
        );
      } else {
        final err = json.decode(res.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(err["message"] ?? "Something went wrong")),
        );
      }
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Image.asset('assets/images/splash.png', scale: 3),
                const SizedBox(height: 16),
                Text(
                  isLogin ? "Sign-In" : "Create Account",
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 28),
                if (!isLogin)
                  _buildInputField(
                    controller: nameCtrl,
                    hint: "Your name",
                    validator: (v) =>
                        v == null || v.isEmpty ? "Enter your name" : null,
                  ),
                if (!isLogin) const SizedBox(height: 16),
                _buildInputField(
                  controller: emailCtrl,
                  hint: "Email address",
                  validator: (v) {
                    if (v == null || v.isEmpty) {
                      return "Enter your email ";
                    }
                    if (!v.contains("@") && v.length < 10) {
                      return "Enter valid email ";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _buildInputField(
                  controller: passCtrl,
                  hint: "Password",
                  isPassword: true,
                  validator: (v) {
                    if (v == null || v.isEmpty) return "Enter password";
                    if (v.length < 6) return "At least 6 characters";
                    return null;
                  },
                ),
                if (!isLogin) const SizedBox(height: 16),
                if (!isLogin)
                  _buildInputField(
                    controller: confirmCtrl,
                    hint: "Re-enter password",
                    isPassword: true,
                    validator: (v) {
                      if (v == null || v.isEmpty) return "Confirm password";
                      if (v != passCtrl.text) return "Passwords do not match";
                      return null;
                    },
                  ),
                const SizedBox(height: 28),
                loading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF9900),
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                          minimumSize: const Size(double.infinity, 48),
                        ),
                        onPressed: submit,
                        child: Text(
                          isLogin ? "Sign-In" : "Create account",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: toggle,
                  child: Text(
                    isLogin
                        ? "New to Afghan Bazaar? Create account"
                        : "Already have an account? Sign-In",
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                const Divider(),
                const SizedBox(height: 20),
                const Text(
                  "By continuing, you agree to Afghan Bazaar's Conditions of Use\nand Privacy Notice.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String hint,
    required TextEditingController controller,
    bool isPassword = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.black54),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: Colors.black26),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: Color(0xFFFF9900), width: 2),
        ),
      ),
    );
  }
}
