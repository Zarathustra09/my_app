import 'dart:async';
import 'package:flutter/material.dart';
import 'profiledetails_page.dart';

class VerificationPage extends StatefulWidget {
  const VerificationPage({super.key});

  @override
  _VerificationPageState createState() => _VerificationPageState();
}

class _VerificationPageState extends State<VerificationPage> {
  int _currentTime = 60;
  bool _isButtonDisabled = true;
  final List<int?> _verificationCode = [null, null, null, null];
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_currentTime == 0) {
        setState(() {
          _isButtonDisabled = false;
          timer.cancel();
        });
      } else {
        setState(() {
          _currentTime--;
        });
      }
    });
  }

  void _onNumberTap(int number) {
    if (_currentIndex < 4) {
      setState(() {
        _verificationCode[_currentIndex] = number;
        _currentIndex++;
      });
    }
  }

  void _onBackspaceTap() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
        _verificationCode[_currentIndex] = null;
      });
    }
  }

  Widget _buildNumberButton(int number) {
    return GestureDetector(
      onTap: () => _onNumberTap(number),
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.grey[300],
        ),
        child: Center(
          child: Text(
            number.toString(),
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
      ),
    );
  }

  void _onVerifyTap() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ProfileDetailsPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 50),              

              // Timer
              Text(
                _currentTime.toString().padLeft(2, '0'),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),

              const SizedBox(height: 10),

              // Instruction text
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 25.0),
                child: Text(
                  'Type the verification code we\'ve sent you',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 16,
                  ),
                ),
              ),

              const SizedBox(height: 25),

              // Verification code input fields
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(4, (index) {
                    return Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: _verificationCode[index] != null
                              ? Colors.pink
                              : Colors.grey,
                        ),
                        color: _verificationCode[index] != null
                            ? Colors.pink
                            : Colors.transparent,
                      ),
                      child: Center(
                        child: Text(
                          _verificationCode[index]?.toString() ?? '',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),

              const SizedBox(height: 25),

              // Numeric keypad
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(3, (index) {
                        int number = index + 1;
                        return _buildNumberButton(number);
                      }),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(3, (index) {
                        int number = index + 4;
                        return _buildNumberButton(number);
                      }),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(3, (index) {
                        int number = index + 7;
                        return _buildNumberButton(number);
                      }),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        const SizedBox(width: 60), // Empty space for alignment
                        _buildNumberButton(0),
                        GestureDetector(
                          onTap: _onBackspaceTap,
                          child: Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.grey[300],
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.backspace,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              // Verify button
              ElevatedButton(
                onPressed: _onVerifyTap,
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white, backgroundColor: Colors.pink,
                  padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Verify',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 25),

              // Resend button
              TextButton(
                onPressed: _isButtonDisabled ? null : () {},
                child: Text(
                  'Send again',
                  style: TextStyle(
                    color: _isButtonDisabled ? Colors.grey : Colors.red,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
