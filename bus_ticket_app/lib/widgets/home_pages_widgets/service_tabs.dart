import 'package:flutter/material.dart';

class ServiceTabs extends StatelessWidget {
  const ServiceTabs({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildFeatureItem(Icons.verified_user_outlined, "Chắc chắn\nCó chỗ"),
          _buildFeatureItem(Icons.headset_mic_outlined, "Hỗ trợ\n24/7"),
          _buildFeatureItem(Icons.local_offer_outlined, "Nhiều\nưu đãi"),
          _buildFeatureItem(Icons.payment, "Thanh toán\nđa dạng"),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String tittle){
    return Row(
      children: [
        Icon(icon, color: Colors.green, size: 25,),
        Text(tittle, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, color: Colors.black87),),
      ],
    );
  }
}
