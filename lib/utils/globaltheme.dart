//
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Primary Text
class PrimaryText extends StatelessWidget {
  final double? fsize;
  final FontWeight? fw;
  final String data;
  final Color? fcolor;
  final TextAlign? falign;

  const PrimaryText({
    super.key,
    this.fsize,
    this.fw,
    required this.data,
    this.fcolor,
    this.falign,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      data,
      textAlign: falign,
      style: GoogleFonts.poppins(
        color: fcolor ?? Colors.black,
        fontWeight: fw,
        fontSize: fsize,
      ),
    );
  }
}

// Color

const maincolor = Color(0xffC96868);

const secondColor = Color(0xff4338CA);

// Button
class GlobalButton extends StatelessWidget {
  final Function callback;
  final String title;
  const GlobalButton({super.key, required this.callback, required this.title});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        style: ElevatedButton.styleFrom(
            backgroundColor: secondColor,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(6))),
        onPressed: () {
          callback();
        },
        child: PrimaryText(
          data: title,
          fcolor: Colors.white,
        ));
  }
}
