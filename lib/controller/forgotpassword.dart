import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:social/utils/globaltheme.dart';

class Forgotpasswordpage extends StatefulWidget {
  const Forgotpasswordpage({super.key});

  @override
  State<Forgotpasswordpage> createState() => _ForgotpasswordpageState();
}

class _ForgotpasswordpageState extends State<Forgotpasswordpage> {
  final TextEditingController _forgotpass = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool isSubmitting = false;

  @override
  void dispose() {
    _forgotpass.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Forgot Password",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: secondColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _forgotpass,
                    decoration: const InputDecoration(
                      labelText: 'Email address',
                      labelStyle: TextStyle(color: Colors.black),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: secondColor),
                      ),
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || !value.endsWith('@cpu.edu.ph')) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: 50,
                    child: GlobalButton(
                      callback: () {
                        if (_formKey.currentState!.validate()) {
                          _submitform();
                        }
                      },
                      title: "Reset Password",
                    ),
                  ),
                ],
              ),
            ),
            if (isSubmitting)
              const Padding(
                padding: EdgeInsets.only(top: 20.0),
                child: CircularProgressIndicator(),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitform() async {
    setState(() {
      isSubmitting = true;
    });

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: _forgotpass.text,
      );

      setState(() {
        isSubmitting = false;
      });
      _showSuccessModal();
    } catch (error) {
      setState(() {
        isSubmitting = false;
      });

      _showErrorModal(error.toString());
    }
  }

  void _showSuccessModal() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Success'),
          content: const Text(
              'Password reset email has been sent.\ncheck your email inbox'),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showErrorModal(String errorMessage) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(errorMessage),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
