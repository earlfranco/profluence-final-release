import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

void fluttertoast(message) {
  Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 1,
      backgroundColor: const Color(0x00ffffff),
      textColor: Colors.white,
      fontSize: 16);
}
