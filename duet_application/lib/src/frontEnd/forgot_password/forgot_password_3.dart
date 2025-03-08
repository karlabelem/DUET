import 'package:flutter/material.dart';

class FPStep3 extends StatelessWidget {
  FPStep3({super.key, required this.nextStep});
  final newPassword = TextEditingController();
  final confirmedPassword = TextEditingController();
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
                      text: 'Reset password\n',
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
                          'Please type something you’ll remember.',
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
              controller: newPassword,
              decoration: InputDecoration(hintText: "New password"),
            ),
            TextField(
              controller: confirmedPassword,
              decoration: InputDecoration(hintText: "Confirm new password"),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                print(newPassword.text.compareTo(confirmedPassword.text) == 0);
                nextStep();
              },
              style: ButtonStyle(
                backgroundColor: WidgetStatePropertyAll<Color>(Color(0xFF5C469C))
              ),
              child: Center(
                child: Text(
                  "Reset password"
                )
              )
            )
          ],
        ),
      ),
    ));
  }
}
