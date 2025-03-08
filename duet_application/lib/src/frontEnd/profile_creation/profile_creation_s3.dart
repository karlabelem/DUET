import 'package:flutter/material.dart';

class ProfileCreationStep3 extends StatefulWidget {
  const ProfileCreationStep3({super.key, required this.nextStep});
  final Function nextStep;

  @override
  State<ProfileCreationStep3> createState() => _ProfileCreationStep3State();
}

class _ProfileCreationStep3State extends State<ProfileCreationStep3> {
  final cityController = TextEditingController();

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
                "Where do you live?",
                style: TextStyle(
                  fontSize: 20.0,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8.0),
              Text(
                "Step 3 of 4",
                style: TextStyle(
                  fontSize: 16.0,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 16.0),
              TextField(
                onChanged: (value) => setState(() {}),
                style: TextStyle(color: Colors.black),
                decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    hintText: "Enter your city"),
                controller: cityController,
              ),
              const SizedBox(height: 24.0),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isValidCity() ? Colors.purple : Colors.grey,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24.0),
                  ),
                  minimumSize: Size(double.infinity, 48.0),
                ),
                onPressed: () {
                  if (isValidCity()) {
                    widget.nextStep(
                      {
                        'location': cityController.text,
                      },
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please enter a valid city'),
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

  bool isValidCity() {
    return cityController.text.isNotEmpty;
  }
}
