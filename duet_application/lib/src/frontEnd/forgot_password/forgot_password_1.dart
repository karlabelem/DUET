import 'package:flutter/material.dart';

class FPStep1 extends StatelessWidget {
  FPStep1({super.key, required this.nextStep});

  final typed = TextEditingController();
  final Function nextStep;

  @override
  Widget build(BuildContext context) {
    return Material(
    child: Center(
      child: SizedBox(
        width: 512,
        height: 512,
        child: Column(
          children: <Widget>[
            SizedBox(
              width: 505,
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: 'Forgot password?\n',
                      style: TextStyle(
                        color: Color(0xFF333333),
                        fontSize: 24,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.none
                      ),
                    ),
                    TextSpan(
                      text: '\n',
                      style: TextStyle(
                        color: Color(0xFF333333),
                        fontSize: 24,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w500,
                        decoration: TextDecoration.none
                      ),
                    ),
                    TextSpan(
                      text:
                          'Don’t worry! It happens. Please enter the email associated with your account.',
                      style: TextStyle(
                        color: Color(0xFF333333),
                        fontSize: 15,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w500,
                        decoration: TextDecoration.none
                      ),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
            ),
            TextField(
              controller: typed,
              decoration: InputDecoration(hintText: "Input email"),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                nextStep();
              },
              style: ButtonStyle(
                backgroundColor: WidgetStatePropertyAll<Color>(Color(0xFF5C469C))
              ),
              child: Center(
                child: Text(
                  "Send code"
                )
              )
            )
          ],
        ),
      ),
    ));
  }
}
