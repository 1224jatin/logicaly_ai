import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:logicaly_ai_project/views/auth/sign_up_screen.dart';
import 'package:logicaly_ai_project/views/auth/otp_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../services/auth_services.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<StatefulWidget> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isResettingPassword = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 30),

                // Robot Logo
                Center(
                  child: Image.asset(
                    "assets/images/logo/logicaly_icon_logo_.png",
                    height: 160,
                  ),
                ),

                const SizedBox(height: 1),

                // Welcome Text
                const Column(
                  children: [
                    Text(
                      "Welcome Back",
                      style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),

                    SizedBox(height: 10),

                    Text(
                      "Login to continue your learning journey",
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),

                const SizedBox(height: 40),

                _buildFieldLabel("Email"),
                const SizedBox(height: 10),
                _buildTextField(
                  controller: emailController,
                  hintText: "abcdfg@gmail.com",
                  keyboardType: TextInputType.emailAddress,
                ),

                const SizedBox(height: 20),

                _buildFieldLabel("Password"),
                const SizedBox(height: 10),
                _buildTextField(
                  controller: passwordController,
                  obscureText: _obscurePassword,
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() => _obscurePassword = !_obscurePassword);
                    },
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Small Text
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          const Flexible(
                            child: Text(
                              "Don't have an account?",
                              style: TextStyle(color: Colors.black),
                            ),
                          ),
                          InkWell(
                            child: const Text(
                              " Sign up",
                              style: TextStyle(
                                color: Colors.blueAccent,
                                fontSize: 12,
                              ),
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const SignUpScreen(),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed:
                          _isResettingPassword ? null : _showForgotPassword,
                      child: Text(
                        _isResettingPassword
                            ? "Sending..."
                            : "Forgot password?",
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 35),

                // Send OTP Button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3563E9),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      _isLoading ? "Logging in..." : "Log in",
                      style: const TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _login() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showSnackBar("Please enter email and password");
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() => _isLoading = true);

    try {
      await AuthService().signIn(email: email, password: password);
      // No manual navigation here. AuthGate handles it.
    } catch (error) {
      if (mounted) {
        _showSnackBar(_authErrorMessage(error));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _showForgotPassword() async {
    final resetEmailController = TextEditingController(
      text: emailController.text.trim(),
    );

    final email = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Reset password"),
          content: TextField(
            controller: resetEmailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: "Email",
              hintText: "abcdfg@gmail.com",
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, resetEmailController.text.trim());
              },
              child: const Text("Send link"),
            ),
          ],
        );
      },
    );

    // Dispose the local controller after the dialog is closed
    resetEmailController.dispose();

    if (!mounted || email == null || email.isEmpty) {
      return;
    }

    setState(() => _isResettingPassword = true);
    try {
      await AuthService().sendPasswordResetEmail(email: email);
      if (!mounted) return;
      _showSnackBar("Reset link sent to your email.");
    } catch (error) {
      if (mounted) {
        _showSnackBar(_resetPasswordErrorMessage(error));
      }
    } finally {
      if (mounted) {
        setState(() => _isResettingPassword = false);
      }
    }
  }

  Widget _buildFieldLabel(String label) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    String? hintText,
    bool obscureText = false,
    TextInputType? keyboardType,
    Widget? suffixIcon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        style: const TextStyle(fontSize: 15),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          suffixIcon: suffixIcon,
        ),
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  String _authErrorMessage(Object error) {
    debugPrint("Login error details: $error");
    final errorStr = error.toString().toLowerCase();

    if (errorStr.contains("socketexception") ||
        errorStr.contains("failed host lookup") ||
        errorStr.contains("connection timed out")) {
      return "Network error. Please check your data or Wi-Fi.";
    }

    if (error is AuthException) {
      final message = error.message.toLowerCase();
      if (message.contains("invalid login credentials") ||
          message.contains("invalid_credentials") ||
          message.contains("wrong-password")) {
        return "Incorrect email or password. Please try again.";
      }
      if (message.contains("user not found") || message.contains("invalid-email")) {
        return "No account found with this email. Please sign up.";
      }
      if (message.contains("email not confirmed")) {
        return "Please verify your email address before logging in.";
      }
      return error.message;
    }

    return "Login failed. Please check your connection and try again.";
  }

  String _resetPasswordErrorMessage(Object error) {
    debugPrint("Reset error details: $error");
    final errorStr = error.toString().toLowerCase();

    if (errorStr.contains("socketexception") ||
        errorStr.contains("failed host lookup")) {
      return "No internet connection.";
    }

    if (error is AuthException) {
      final message = error.message.toLowerCase();
      if (message.contains("user not found")) {
        return "No account found with this email.";
      }
      if (message.contains("invalid email")) {
        return "Please enter a valid email address.";
      }
      return error.message;
    }

    return "Could not send reset link. Please try again.";
  }
}
