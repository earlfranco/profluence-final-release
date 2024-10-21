// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:social/utils/globaltheme.dart';

class TermsConditionsScreen extends StatefulWidget {
  const TermsConditionsScreen({super.key});

  @override
  _TermsConditionsScreenState createState() => _TermsConditionsScreenState();
}

class _TermsConditionsScreenState extends State<TermsConditionsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: secondColor,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(color: Colors.white),
        title: const Text('Terms and Conditions'),
      ),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Profluence Terms and Conditions",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
            SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  '''
Welcome to Profluence!

These Terms and Conditions govern your use of Profluence, a social media platform designed exclusively for university students. By accessing or using Profluence, you agree to be bound by these terms.

1. **Eligibility**: 
   To create an account on Profluence, you must be an active university student and provide proof of enrollment. Profluence reserves the right to suspend or delete accounts if eligibility cannot be verified.

2. **Account Responsibilities**: 
   You are responsible for maintaining the confidentiality of your account and password. You agree to notify us immediately if you suspect any unauthorized use of your account. Profluence is not liable for any loss or damage arising from your failure to protect your account.

3. **Acceptable Use**: 
   You agree to use Profluence in compliance with all applicable laws and regulations. You must not:
   - Use the platform for any unlawful purposes.
   - Post content that is abusive, harmful, offensive, or violates others' rights.
   - Impersonate any person or entity or misrepresent your affiliation with any group.
   - Use Profluence to transmit any form of spam or unsolicited communication.

4. **Content Ownership and License**: 
   All content you post, including messages, photos, and other materials, remains your intellectual property. However, by posting content on Profluence, you grant us a non-exclusive, royalty-free license to use, display, reproduce, and modify your content for the purpose of providing and promoting the platform.

5. **Account Termination**: 
   Profluence reserves the right to suspend or terminate your account at any time for violating these terms or for any reason deemed appropriate. Upon termination, you will no longer have access to your account or content within the platform.

6. **Modification of Terms**: 
   Profluence reserves the right to update or modify these terms at any time. You will be notified of significant changes through the platform or via email. Your continued use of Profluence after such changes indicates your acceptance of the new terms.

7. **Disclaimers**: 
   Profluence is provided on an "as is" and "as available" basis. We make no warranties or guarantees regarding the platform's availability, reliability, or fitness for a particular purpose. You use the platform at your own risk.

8. **Limitation of Liability**: 
   To the fullest extent permitted by law, Profluence is not liable for any indirect, incidental, or consequential damages resulting from your use of the platform. Our total liability to you, for any reason, will be limited to the amount you paid for using the platform (which, for most users, is 0).

9. **Governing Law**: 
   These terms are governed by and construed in accordance with the laws of the jurisdiction in which Profluence operates. Any legal action or proceeding will take place in that jurisdiction.

By using Profluence, you agree to these terms. If you do not agree with any part of these terms, you must discontinue using the platform.

For any questions or concerns regarding these terms, please contact Profluence support.

Thank you for being a part of the Profluence community!
                  ''',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
