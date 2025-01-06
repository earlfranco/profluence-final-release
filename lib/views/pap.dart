// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:social/utils/globaltheme.dart';

class PrivacyPolicyScreen extends StatefulWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  _PrivacyPolicyScreenState createState() => _PrivacyPolicyScreenState();
}

class _PrivacyPolicyScreenState extends State<PrivacyPolicyScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: secondColor,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(color: Colors.white),
        title: const Text('Privacy Policy'),
      ),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Profluence Privacy Policy",
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

Profluence is a social media platform exclusively for university students. We value your privacy and are committed to protecting your personal data. Here is an overview of how we handle your data:

1. **Data Collection**: 
   We collect basic information such as your name, email address, and university affiliation to verify your identity as a student. Additional information, such as your posts and interactions within the platform, is also stored to enhance your experience.

2. **How We Use Your Data**: 
   Your data is used to provide, personalize, and improve Profluence's services. This includes verifying your identity, allowing interactions between users, and enhancing the social experience. We do not share your personal data with third parties without your explicit consent.

3. **Community Guidelines**: 
   Profluence is a community exclusively for university students. We expect all users to engage in respectful communication and follow our community guidelines. Violations of these guidelines may result in the suspension or termination of your account.

4. **Account Termination and Data Deletion**: 
   If you decide to leave Profluence, you may request to have your account and personal data permanently deleted. Once deleted, this information cannot be recovered.

5. **Data Security**: 
   We implement various security measures to protect your personal data. However, no online service can be completely secure. By using Profluence, you acknowledge that you are using the platform at your own risk.

6. **Third-Party Services**: 
   Profluence may integrate with third-party services (such as external apps or websites). While we ensure these services meet certain standards, their privacy policies are separate from ours, and you should review them when necessary.

7. **Changes to This Policy**: 
   We may update our Privacy Policy from time to time. Any significant changes will be communicated to you through the platform or via email. Continued use of the platform following updates signifies your acceptance of these changes.

8. **Your Rights**: 
   As a user, you have the right to access, correct, or request the deletion of your personal data. You may also limit the processing of your data, where applicable.

For any questions, concerns, or requests regarding this policy, please contact Profluence support. We are here to ensure your privacy and a safe, enjoyable experience on our platform.

Thank you for being part of the Profluence community!

Version 1.1
by the Comp19
The ProFluence Team
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
