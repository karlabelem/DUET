import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ProfileCreationStep2 extends StatefulWidget {
  const ProfileCreationStep2({super.key, required this.nextStep});
  final Function nextStep;

  @override
  State<ProfileCreationStep2> createState() => _ProfileCreationStep2State();
}

class _ProfileCreationStep2State extends State<ProfileCreationStep2> {
  final monthController = TextEditingController();
  final dayController = TextEditingController();
  final yearController = TextEditingController();

  // Add these validation functions
  String? validateMonth(String? value) {
    if (value == null || value.isEmpty) return null;
    final month = int.tryParse(value);
    if (month == null || month < 1 || month > 12) return 'Invalid month';
    return null;
  }

  String? validateDay(String? value) {
    if (value == null || value.isEmpty) return null;
    final day = int.tryParse(value);
    if (day == null || day < 1 || day > 31) return 'Invalid day';
    return null;
  }

  String? validateYear(String? value) {
    if (value == null || value.isEmpty) return null;
    final year = int.tryParse(value);
    final currentYear = DateTime.now().year;
    if (year == null || year > currentYear || year < currentYear - 120) {
      return 'Invalid year';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE0CFF2),
      body: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.5,
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10.0,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "What's Your Date of Birth?",
                style: TextStyle(
                  fontSize: 20.0,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8.0),
              Text(
                "Step 2 of 4",
                style: TextStyle(
                  fontSize: 16.0,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: SizedBox(
                        height: 80,
                        child: TextField(
                          style: TextStyle(color: Colors.black),
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            hintText: "Month",
                            errorText: validateMonth(monthController.text),
                          ),
                          controller: monthController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(2),
                          ],
                          onChanged: (value) {
                            setState(() {});
                          },
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: SizedBox(
                        height: 80,
                        child: TextField(
                          style: TextStyle(color: Colors.black),
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            hintText: "Day",
                            errorText: validateDay(dayController.text),
                          ),
                          controller: dayController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(2),
                          ],
                          onChanged: (value) {
                            setState(() {});
                          },
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: SizedBox(
                        height: 80,
                        child: TextField(
                          style: TextStyle(color: Colors.black),
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            hintText: "Year",
                            errorText: validateYear(yearController.text),
                          ),
                          controller: yearController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(4),
                          ],
                          onChanged: (value) {
                            setState(() {});
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24.0),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isValidDate() ? Colors.purple : Colors.grey,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24.0),
                  ),
                  minimumSize: const Size(double.infinity, 48.0),
                ),
                onPressed: isValidDate()
                    ? () {
                        widget.nextStep({
                          'dob': '${monthController.text}/${dayController.text}/${yearController.text}',
                        });
                      }
                    : null,
                child: const Text(
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

  // Add this method to check if all fields are valid
  bool isValidDate() {
    return validateMonth(monthController.text) == null &&
        validateDay(dayController.text) == null &&
        validateYear(yearController.text) == null &&
        monthController.text.isNotEmpty &&
        dayController.text.isNotEmpty &&
        yearController.text.isNotEmpty;
  }
}
