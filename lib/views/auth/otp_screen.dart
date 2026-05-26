import 'package:flutter/material.dart';
import 'package:logicaly_ai_project/views/navigation_Bar.dart';

import '../../services/auth_services.dart';
import '../chat/chat_bot.dart';

class OtpScreen extends StatefulWidget{
  late  String sentOtp;
  OtpScreen({super.key , required this.sentOtp});


  @override
  State<StatefulWidget> createState() =>_OtpScreen();

}
class _OtpScreen extends State<OtpScreen>{
  late String _otp ;

  TextEditingController firstAlphabet = TextEditingController();
  TextEditingController secondAlphabet = TextEditingController();
  TextEditingController thirdAlphabet = TextEditingController();
  TextEditingController fourthAlphabet = TextEditingController();
  TextEditingController fifthAlphabet = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 70),

              // Robot Image
              Center(
                child: Image.asset("assets/images/logo/logicaly_icon_logo_.png" ,
                height: 160,)
              ),

              const SizedBox(height: 30),

              // Title
              Text(
                "Verify your ${""} Email",
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),

              const SizedBox(height: 10),

              // Subtitle
              RichText(
                textAlign: TextAlign.center,
                text: const TextSpan(
                  text: "We sent a 4-digit OTP to ",
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                  children: [
                    TextSpan(
                      text: "ab***12@gmail.com",
                      style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // Enter OTP Label
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Enter OTP",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              const SizedBox(height: 15),

              // OTP Boxes
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // First
                TextField(
                  controller: firstAlphabet,
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                maxLength: 1,
                decoration: InputDecoration(
                  counterText: "",
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: EdgeInsets.zero,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: Colors.grey.shade300,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: Colors.grey.shade300,
                    ),
                  ),
                ),
               ),
                  // Second
                  TextField(
                    controller: secondAlphabet,
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    maxLength: 1,
                    decoration: InputDecoration(
                      counterText: "",
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: EdgeInsets.zero,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color: Colors.grey.shade300,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color: Colors.grey.shade300,
                        ),
                      ),
                    ),
                  ),
                // third letter

                  TextField(
                    controller: thirdAlphabet,
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    maxLength: 1,
                    decoration: InputDecoration(
                      counterText: "",
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: EdgeInsets.zero,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color: Colors.grey.shade300,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color: Colors.grey.shade300,
                        ),
                      ),
                    ),
                  ),
                  //forth

                  TextField(
                    controller: fourthAlphabet,
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    maxLength: 1,
                    decoration: InputDecoration(
                      counterText: "",
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: EdgeInsets.zero,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color: Colors.grey.shade300,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color: Colors.grey.shade300,
                        ),
                      ),
                    ),
                  ),
                  //fifth
                  TextField(
                    controller: firstAlphabet,
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    maxLength: 1,
                    decoration: InputDecoration(
                      counterText: "",
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: EdgeInsets.zero,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color: Colors.grey.shade300,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color: Colors.grey.shade300,
                        ),
                      ),
                    ),
                  ),
                ]
              ),

              const SizedBox(height: 15),

              // Small Text
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "We'll send a one-time password to verify",
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ),

              const SizedBox(height: 35),

              // Verify Button
              SizedBox(
                width: double.infinity,
                height: 58,
                child: ElevatedButton(
                  onPressed: () {
                    final _otp = firstAlphabet.text + secondAlphabet.text +
                        thirdAlphabet.text + fourthAlphabet.text +
                        fifthAlphabet.text;
                    OtpServices().verifyOtp(_otp, OtpServices().generateOtp());
                    // onpressed logic
                   // Navigator.push(context, MaterialPageRoute(builder: (context)=>NavigationBarScreen()));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3563E9),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Verify OTP",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 25),

              // Resend Timer
              const Text(
                "Resend OTP in 04:35",
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.black87,
                ),
              ),

              const SizedBox(height: 8),

              // Resend Text
              RichText(
                text: const TextSpan(
                  text: "Didn't receive the OTP? ",
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 13,
                  ),
                  children: [
                    TextSpan(
                      text: "Resend",
                      style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}