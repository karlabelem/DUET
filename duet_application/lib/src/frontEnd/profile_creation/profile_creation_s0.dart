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
  final emailFocusNode = FocusNode();
  String emailError = '';

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
                    borderSide: BorderSide(
                      color: emailError.isEmpty ? Colors.grey : Colors.red,
                    ),
                  ),
                  hintText: "Email",
                  errorText: emailError.isEmpty ? null : emailError,
                ),
                controller: emailController,
                focusNode: emailFocusNode,
                onChanged: (value) => setState(() {
                  emailError =
                      isValidEmail(value) ? '' : 'Invalid email address';
                }),
                style: TextStyle(color: Colors.black),
              ),
              const SizedBox(height: 16.0),
              TextField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  hintText: "Password",
                ),
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
                  hintText: "Confirm Password",
                ),
                controller: confirmPasswordController,
                obscureText: true,
                onChanged: (value) => setState(() {}),
                style: TextStyle(color: Colors.black),
              ),
              const SizedBox(height: 24.0),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isValidForm() ? Colors.purple : Colors.grey,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24.0),
                  ),
                  minimumSize: Size(double.infinity, 48.0),
                ),
                onPressed: () {
                  if (isValidForm()) {
                    widget.nextStep(
                      {
                        'email': emailController.text,
                        'password': passwordController.text,
                      },
                    );
                  } else {
                    if (!isValidEmail(emailController.text)) {
                      setState(() {
                        emailError = 'Invalid email address';
                      });
                      emailFocusNode.requestFocus();
                    } else if (passwordController.text !=
                        confirmPasswordController.text) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Passwords do not match'),
                        ),
                      );
                    }
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

  bool isValidForm() {
    return isValidEmail(emailController.text) &&
        passwordController.text.isNotEmpty &&
        confirmPasswordController.text.isNotEmpty &&
        passwordController.text == confirmPasswordController.text;
  }

  bool isValidEmail(String email) {
    final emailRegex = RegExp(
        r"[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?");
    return emailRegex.hasMatch(email);
  }
}
