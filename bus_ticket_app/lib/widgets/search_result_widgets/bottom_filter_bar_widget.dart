import 'package:flutter/material.dart';

class BottomFilterBarWidget extends StatelessWidget {
  const BottomFilterBarWidget ({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF152A47), // Màu xanh đen giống Vexere
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildFilterItem(Icons.tune, 'Lọc'),
          _buildDivider(),
          _buildFilterItem(Icons.sort, 'Sắp xếp'),
          _buildDivider(),
          _buildFilterItem(Icons.access_time, 'Giờ đi'),
          _buildDivider(),
          _buildFilterItem(Icons.directions_bus, 'Nhà xe'),
        ],
      ),
    );
  }

  Widget _buildFilterItem(IconData icon, String label) {
    return InkWell(
      onTap: () {},
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 18),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 16,
      color: Colors.white.withOpacity(0.3),
    );
  }
}