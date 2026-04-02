import 'package:flutter/material.dart';

class RecentList extends StatefulWidget {
  const RecentList({super.key});

  @override
  State<RecentList> createState() => _RecentListState();
}

class _RecentListState extends State<RecentList> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Tìm kiếm gần đây',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold,),
              ),
              TextButton(
                  onPressed: (){},
                  child: const Text('Xóa tất cả', style: TextStyle(color: Colors.blue, fontSize: 16, fontWeight: FontWeight.bold, decoration: TextDecoration.underline),)
              ),
            ],
          ),
        ),
        const SizedBox(height: 4,),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(left: 16),
            itemCount: 5,
            itemBuilder: (context, index){
              return _buildRecentCard(from: "Đắk Lắk", to: "Hồ Chí Minh" , date: "19/9/2026");
            },
          ),
        )
      ],
    );
  }
  // Hàm build từng thẻ card
  Widget _buildRecentCard({
    required String from,
    required String to,
    required String date,
  }){
    return Container(
      width: 220,
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(right: 12, bottom: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [BoxShadow(
          color: Colors.black26,
          blurRadius: 4,
          offset: Offset(0, 2),
        )],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(top: 4,),
            child: Column(
              children: [
                _buildCircleDot(Colors.blue),
                _buildDottedLine(),
                _buildCircleDot(Colors.red),
              ],
            ),
          ),
          const SizedBox(width: 12,),
          //Cột chứa text địa điểm và thời gian
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  from,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                    fontWeight: FontWeight.w600
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8,),
                Text(
                  to,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const Spacer(),
                Text(
                  date,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8,),
            child: Icon(
              Icons.arrow_forward,
              size: 20,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  // Hàm vẽ dấu chấm tròn ở giữa
  Widget _buildCircleDot(Color color){
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: color, width: 3),
        color: Colors.white,
      ),
    );
  }

  //Hàm vẽ đường nét đức giữa hai vòng tròn
  Widget _buildDottedLine(){
    return Column(
      children: List.generate(
        3,
        (index) => Container(
          width: 1.5,
          height: 3,
          margin: const EdgeInsets.symmetric(vertical: 2),
          color: Colors.grey.shade400,
        ),
      ),
    );
  }
}
