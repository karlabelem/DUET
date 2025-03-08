import 'package:flutter/material.dart';

class ProfileCreationStep1 extends StatefulWidget {
  const ProfileCreationStep1({super.key, required this.nextStep});
  final Function nextStep;

  @override
  State<ProfileCreationStep1> createState() => _ProfileCreationStep1State();
}

class _ProfileCreationStep1State extends State<ProfileCreationStep1> {
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();

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
                "What's Your Name?",
                style: TextStyle(
                  fontSize: 20.0,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8.0),
              Text(
                "Step 1 of 4",
                style: TextStyle(
                  fontSize: 16.0,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 16.0),
              TextField(
                style: TextStyle(color: Colors.black),
                decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    hintText: "First Name"),
                controller: firstNameController,
                onChanged: (value) => setState(() {}),
              ),
              const SizedBox(height: 16.0),
              TextField(
                style: TextStyle(color: Colors.black),
                decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    hintText: "Last Name"),
                controller: lastNameController,
                onChanged: (value) => setState(() {}),
              ),
              const SizedBox(height: 24.0),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isValidName() ? Colors.purple : Colors.grey,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24.0),
                  ),
                  minimumSize: Size(double.infinity, 48.0),
                ),
                onPressed: isValidName()
                    ? () {
                        widget.nextStep(
                          {
                            'firstName': firstNameController.text,
                            'lastName': lastNameController.text,
                          },
                        );
                      }
                    : null,
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

  bool isValidName() {
    return firstNameController.text.isNotEmpty &&
        lastNameController.text.isNotEmpty;
  }
}
