import 'package:flutter/material.dart';
import 'package:social/utils/globaltheme.dart';

class VerifacationMessage extends StatefulWidget {
  const VerifacationMessage({super.key});

  @override
  State<VerifacationMessage> createState() => _VerifacationMessageState();
}

class _VerifacationMessageState extends State<VerifacationMessage> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Center(
            child: Icon(
              Icons.verified_rounded,
              color: Colors.green,
              size: 100,
            ),
          ),
          Center(
            child: PrimaryText(
                falign: TextAlign.center,
                data: "Please check your email\nfor verification"),
          )
        ],
      ),
    );
  }
}
