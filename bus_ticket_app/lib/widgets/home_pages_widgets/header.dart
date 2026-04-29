import 'package:bus_ticket_app/pages/account_info_pages.dart';
import 'package:bus_ticket_app/widgets/bottom_navigation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class HeaderHomePage extends StatelessWidget {
  const HeaderHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 250,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.vertical(bottom: Radius.elliptical(200, 30)),
      ),
      padding: const EdgeInsets.only(top: 50, left: 16, right: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  SvgPicture.asset(
                    'assets/images/busIcon.svg',
                    height: 40,
                    colorFilter: const ColorFilter.mode(
                      Colors.yellow,
                      BlendMode.srcIn,
                    ),
                  ),
                  Text(
                    'VEXEDAT',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: () {
                  final bottomNav = context
                      .findAncestorStateOfType<CustomBottonNavState>();
                  bottomNav?.changeTab(4);
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Chào Phát',
                      style: Theme.of(context).appBarTheme.toolbarTextStyle,
                    ),
                    SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.white,
                      size: 14,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Cam kết hoàn 150% nếu nhà xe không cung cấp dịch vụ vận chuyển (*)',
            style: TextStyle(color: Colors.white, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
