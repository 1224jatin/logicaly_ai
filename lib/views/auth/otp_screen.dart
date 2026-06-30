import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:logicaly_ai_project/views/auth/auth_gate.dart';
import 'package:logicaly_ai_project/views/auth/login_screen.dart';
import 'package:logicaly_ai_project/views/auth/password_reset_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../services/auth_services.dart';

class OtpScreen extends StatefulWidget {
  final String sentOtp;
  final String? userName;
  final String? email;
  final String? password;
  final bool isPasswordReset;

  const OtpScreen({
    super.key,
    required this.sentOtp,
    this.userName,
    this.email,
    this.password,
    this.isPasswordReset = false,
  });

  @override
  State<StatefulWidget> createState() => _OtpScreen();
}

class _OtpScreen extends State<OtpScreen> {
  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _focusNodes;
  bool _isLoading = false;

  late String _currentOtp;
  Timer? _timer;
  int _remainingSeconds = 240; // 4 minutes

  @override
  void initState() {
    super.initState();
    final pinLength = widget.isPasswordReset ? 6 : 4;
    _controllers = List.generate(
      pinLength,
      (_) => TextEditingController(),
    );
    _focusNodes = List.generate(pinLength, (_) => FocusNode());
    _currentOtp = widget.sentOtp;
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _remainingSeconds = 240);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() => _remainingSeconds--);
      } else {
        _timer?.cancel();
      }
    });
  }

  String get _formattedTime {
    final minutes = (_remainingSeconds / 60).floor();
    final seconds = _remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final controller in _controllers) {
      controller.dispose();
    }
    for (final focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 28),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      onPressed: () => Navigator.maybePop(context),
                      icon: const Icon(Icons.arrow_back_ios_new_rounded),
                    ),
                  ),

                  const SizedBox(height: 18),

                  Center(
                    child: Image.asset(
                      "assets/images/logo/logicaly_icon_logo_.png",
                      height: 150,
                    ),
                  ),

                  const SizedBox(height: 28),

                  const Text(
                    "Verify Your Email",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),

                  const SizedBox(height: 10),

                   RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      text: widget.isPasswordReset
                          ? "We sent a 6-digit code to "
                          : "We sent a 4-digit OTP to ",
                      style: const TextStyle(color: Colors.grey, fontSize: 14),
                      children: [
                        TextSpan(
                          text: _maskedEmail,
                          style: const TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  const Text(
                    "Enter OTP",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),

                  const SizedBox(height: 15),

                  LayoutBuilder(
                    builder: (context, constraints) {
                      final pinLength = widget.isPasswordReset ? 6 : 4;
                      // Calculate total gap between fields
                      final totalGap = (pinLength - 1) * 8;
                      final fieldWidth = ((constraints.maxWidth - totalGap) / pinLength)
                          .clamp(40.0, 64.0);

                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          _controllers.length,
                          (index) => Padding(
                            padding: EdgeInsets.only(
                              right: index == _controllers.length - 1 ? 0 : 8,
                            ),
                            child: _OtpDigitField(
                              width: fieldWidth,
                              controller: _controllers[index],
                              focusNode: _focusNodes[index],
                              onChanged: (value) =>
                                  _handleDigitChange(value, index),
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 15),

                  const Text(
                    "We'll send a one-time password to verify",
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),

                  const SizedBox(height: 35),

                  SizedBox(
                    height: 58,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _verifyOtp,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3563E9),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        _isLoading ? "Verifying..." : "Verify OTP",
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  Text(
                    "Resend OTP in $_formattedTime",
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 13, color: Colors.black87),
                  ),

                  const SizedBox(height: 8),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Didn't receive the OTP? ",
                        style: TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                      InkWell(
                        onTap: _remainingSeconds == 0 ? _resendOtp : null,
                        child: Text(
                          "Resend",
                          style: TextStyle(
                            color: _remainingSeconds == 0
                                ? Colors.blue
                                : Colors.grey,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _handleDigitChange(String value, int index) {
    if (value.isNotEmpty && index < _focusNodes.length - 1) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
  }

  Future<void> _resendOtp() async {
    if (widget.email == null) return;

    setState(() => _isLoading = true);

    final otpService = OtpServices();
    final newOtp = otpService.generateOtp(length: widget.isPasswordReset ? 6 : 4);
    final success = await otpService.sendOtp(widget.email!, newOtp);

    setState(() => _isLoading = false);

    if (success) {
      setState(() => _currentOtp = newOtp);
      _startTimer();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.isPasswordReset
                  ? "A new reset code has been sent."
                  : "A new OTP has been sent.",
            ),
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to resend OTP. Try again.")),
        );
      }
    }
  }

  Future<void> _verifyOtp() async {
    final enteredOtp = _controllers.map((controller) => controller.text).join();

    final isVerified = OtpServices().verifyOtp(_currentOtp, enteredOtp);

    if (!isVerified && _currentOtp.isNotEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Invalid OTP")));
      return;
    }

    if (widget.isPasswordReset) {
      FocusScope.of(context).unfocus();
      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const PasswordResetScreen(),
        ),
      );
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() => _isLoading = true);

    try {
      if (widget.email != null &&
          widget.password != null &&
          widget.userName != null) {
        await AuthService().signUp(
          userName: widget.userName!,
          email: widget.email!,
          password: widget.password!,
        );

        // Explicitly sign out to stay on the login/auth flow as requested
        await AuthService().signOut();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("User registered successfully. Please log in."),
              backgroundColor: Colors.green,
            ),
          );
          // Go back to the initial AuthGate which will show the LoginScreen
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const AuthGate()),
            (route) => false,
          );
        }
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(_authErrorMessage(error))));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String get _maskedEmail {
    final email = widget.email;
    if (email == null || email.isEmpty || !email.contains("@")) {
      return "your email";
    }

    final parts = email.split("@");
    final name = parts.first;
    final domain = parts.last;
    final visible = name.length <= 2 ? name : name.substring(0, 2);
    return "$visible***@$domain";
  }

  String _authErrorMessage(Object error) {
    debugPrint("Signup error details (full): $error");
    final errorStr = error.toString().toLowerCase();

    // Specific Supabase error codes for better matching
    if (error is AuthException) {
      if (error.statusCode == '422' || error.message.contains('already registered')) {
        return "This email is already registered. Please log in instead.";
      }
    }

    if (errorStr.contains("socketexception") ||
        errorStr.contains("failed host lookup") ||
        errorStr.contains("handshake_exception") ||
        errorStr.contains("connection timed out")) {
      return "Network error. Supabase might be unreachable. Please try again.";
    }

    if (error is AuthException) {
      final message = error.message.toLowerCase();
      if (message.contains("invalid email")) {
        return "Please enter a valid email address.";
      }
      if (message.contains("weak-password") || (message.contains("password") && message.contains("short"))) {
        return "Password is too weak. Use at least 6 characters.";
      }
      return error.message;
    }
    return "Account creation failed. Please check your internet and try again.";
  }
}

class _OtpDigitField extends StatelessWidget {
  final double width;
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;

  const _OtpDigitField({
    required this.width,
    required this.controller,
    required this.focusNode,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: 58,
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        decoration: InputDecoration(
          counterText: "",
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.zero,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFF3563E9), width: 1.4),
          ),
        ),
        onChanged: onChanged,
      ),
    );
  }
}
