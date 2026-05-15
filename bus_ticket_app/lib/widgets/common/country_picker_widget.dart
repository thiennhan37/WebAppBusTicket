import 'package:flutter/material.dart';

class CountryInfo {
  final String code;
  final String flag;
  final String name;

  CountryInfo({required this.code, required this.flag, required this.name});
}

class CountryPickerWidget extends StatelessWidget {
  final Map<String, String> selectedCountry;
  final List<Map<String, String>> countries;
  final Function(Map<String, String>) onCountrySelected;

  const CountryPickerWidget({
    super.key,
    required this.selectedCountry,
    required this.countries,
    required this.onCountrySelected,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _showCountryPicker(context),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 14,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              selectedCountry['flag']!,
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(width: 8.0),
            Text(
              '${selectedCountry['code']}',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(width: 4.0),
            const Icon(Icons.arrow_drop_down, size: 20),
          ],
        ),
      ),
    );
  }

  void _showCountryPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.only(top: 16),
          height: 400,
          child: Column(
            children: [
              const Text(
                'Chọn quốc gia/ Vùng lãnh thổ',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: countries.length,
                  itemBuilder: (context, index) {
                    final country = countries[index];
                    return ListTile(
                      leading: Text(
                        country['flag']!,
                        style: const TextStyle(fontSize: 24),
                      ),
                      title: Text(country['name']!),
                      trailing: Text(
                        country['code']!,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                      onTap: () {
                        onCountrySelected(country);
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
