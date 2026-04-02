import 'package:flutter/material.dart';

class InforBanner extends StatelessWidget {
  final String text;
  final IconData iconData;
  final Color backgroundColor;
  final Color borderColor;
  final Color iconColor;

  const InforBanner({
    super.key,
    required this.text,
    required this.iconData,
    required this.backgroundColor,
    required this.borderColor,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Icon(iconData, color: iconColor, size: 20,),
          SizedBox(width: 12.0,),
          Expanded(child: Text(
            text, style: TextStyle(fontSize: 13, color: Colors.black87, height: 1.4),
          ),),
        ],
      ),
    );
  }
}
