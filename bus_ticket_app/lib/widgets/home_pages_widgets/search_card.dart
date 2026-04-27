import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
class SearchCard extends StatefulWidget {
  const SearchCard({super.key});

  @override
  State<SearchCard> createState() => _SearchCardState();
}

class _SearchCardState extends State<SearchCard> {

  Widget BuildLocationTile(IconData icon, iconColor, String title, String value){
    return Row(
      children: [
        Icon(icon, color: iconColor,),
        const SizedBox(width: 16,),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          )
        ]
      ),
      child: Column(
        children: [
          SvgPicture.asset(
            'assets/images/busSearch.svg',
            height: 30,
            colorFilter: const ColorFilter.mode(
              Colors.black,
              BlendMode.srcIn,
            ),
          ),
          const Divider(),
          Stack(
            alignment: Alignment.centerRight,
            children: [
              Column(
                children: [
                  BuildLocationTile(Icons.circle_outlined, Colors.blue, "Nơi xuất phát", "Hồ Chí Minh"),
                  const Divider(indent: 40,),
                  BuildLocationTile(Icons.location_on, Colors.red, "Bạn muốn đi đâu", "Đắk Lắk"),
                ],
              ),
              Container(
                margin: const EdgeInsets.only(right: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                    onPressed: (){},
                    icon: const Icon(Icons.swap_vert, size: 20,)
                ),
              )
            ],
          ),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.calendar_today, color: Colors.blue,),
                  SizedBox(width: 8,),
                  Text("Ngày đi"),
                ],
              ),
              Row(
                children: [
                  Text("Khứ hồi"),
                  Switch(value: false, onChanged: (v){})
                ],
              )
            ],
          ),
          const SizedBox(height: 16,),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFD54F),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))
              ),
                onPressed: (){},
                child: const Text(
                  'Tìm kiếm',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                )
            ),
          )
        ],
      ),
    );
  }
}

