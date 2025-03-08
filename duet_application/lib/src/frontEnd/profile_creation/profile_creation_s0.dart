import 'package:flutter/material.dart';

class AccountRegistration extends StatefulWidget {
  const AccountRegistration({super.key, required this.nextStep});
  final Function nextStep;

  @override
  State<AccountRegistration> createState() => _AccountRegistrationState();
}

class _AccountRegistrationState extends State<AccountRegistration> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFE0CFF2), // Replace with the gradient background
      body: Center(
        child: Container(
          width: MediaQuery.of(context).size.width *
              0.5, // Reduce width to make the box smaller
          // height: MediaQuery.of(context).size.width * 0.5,
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10.0,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Create Your Account",
                style: TextStyle(
                  fontSize: 20.0,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16.0),
              TextField(
                decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    hintText: "Email"),
                controller: emailController,
                style: TextStyle(color: Colors.black),
              ),
              const SizedBox(height: 16.0),
              TextField(
                decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    hintText: "Password"),
                controller: passwordController,
                obscureText: true,
                onChanged: (value) => setState(() {}),
                style: TextStyle(color: Colors.black),
              ),
              const SizedBox(height: 16.0),
              TextField(
                decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    hintText: "Confirm Password"),
                controller: confirmPasswordController,
                obscureText: true,
                onChanged: (value) => setState(() {}),
                style: TextStyle(color: Colors.black),
              ),
              const SizedBox(height: 24.0),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      isValidPassword() ? Colors.purple : Colors.grey,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24.0),
                  ),
                  minimumSize: Size(double.infinity, 48.0),
                ),
                onPressed: () {
                  if (isValidPassword()) {
                    widget.nextStep(
                      {
                        'email': emailController.text,
                        'password': passwordController.text,
                      },
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Passwords do not match'),
                      ),
                    );
                  }
                },
                child: Text(
                  "Next",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool isValidPassword() {
    return passwordController.text.isNotEmpty &&
        confirmPasswordController.text.isNotEmpty &&
        passwordController.text == confirmPasswordController.text;
  }
}
