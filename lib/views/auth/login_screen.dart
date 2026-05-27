import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:logicaly_ai_project/views/auth/otp_screen.dart';
import 'package:logicaly_ai_project/views/auth/sign_up_screen.dart';

class LoginScreen extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => _LoginScreenState();
}
class _LoginScreenState extends State<LoginScreen>{
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),
      body: SafeArea(
        child: SingleChildScrollView(
          child:  Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const SizedBox(height: 30),

            // Robot Logo
            Center(
                child: Image.asset("assets/images/logo/logicaly_icon_logo_.png",
                  height: 160,)
            ),

            const SizedBox(height: 1),

            // Welcome Text
            Container(
              child: Column(
                children: [
                  const Text(
                    "Welcome Back",
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),

                  const SizedBox(height: 10),

                  const Text(
                    "Login to continue your learning journey",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            //-----------Emaill----------
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Email",
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ),

            const SizedBox(height: 10),

            Container(
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                children: [
                  Container(
                    width: 1,
                    height: 30,
                    color: Colors.grey.shade300,
                  ),
                  //Email Controller
                  Expanded(
                    child: TextField(
                      controller: emailController,
                      keyboardType: TextInputType.phone,

                      decoration: const InputDecoration(
                        hintText: "abcdfg@gmail.com",
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 15,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            //-----------passworddd----------

            // Phone Number Label
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Password",
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ),

            // Phone Number Field
            Container(
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                children: [
                  //Password Controller
                  Expanded(
                    child: TextField(
                      controller: passwordController,
                      keyboardType: TextInputType.phone,

                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 15,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Small Text
            Align(
                alignment: Alignment.centerLeft,
                child: Row(
                  children: [
                    const Text("Not have an account?" , style: TextStyle(
                      color: Colors.black,
                    ),),
                    InkWell(
                      // for signup
                      child:  Text(
                        " Sign up",
                        style: TextStyle(
                          color: Colors.blueAccent,
                          fontSize: 12,
                        ),
                      ),
                      onTap: (){
                        Navigator.push(context, MaterialPageRoute(builder: (context)=> SignUpScreen()));
                      },

                    )

                  ],
                )
            ),

            const SizedBox(height: 35),

            // Send OTP Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  // ON press action here
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>OtpScreen( sentOtp: '',)));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3563E9),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "Log in",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                  ),
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

}