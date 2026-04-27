import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class HeaderLoginWidget extends StatelessWidget {
  final String title;
  final String subtitle;
  final String imagePath;

  const HeaderLoginWidget({
    super.key,
    this.title = 'Xin chào',
    this.subtitle = 'Đăng nhập để tận hưởng nhiều ưu đãi',
    this.imagePath = 'assets/images/busLogin.svg',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Theme.of(context).colorScheme.primary,
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back, color: Colors.white),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20.0),
            Container(
              width: double.infinity,
              height: 150,
              alignment: Alignment.bottomCenter,
              child: SvgPicture.asset(imagePath),
            ),
            const SizedBox(height: 20.0),
          ],
        ),
      ),
    );
  }
}
