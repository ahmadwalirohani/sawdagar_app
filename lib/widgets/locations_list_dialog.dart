import 'package:flutter/material.dart';

void showLocationDialog(BuildContext context) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: "Locations",
    pageBuilder: (_, __, ___) => const LocationSelectorDialog(),
    transitionDuration: const Duration(milliseconds: 300),
    transitionBuilder: (_, animation, __, child) {
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 1),
          end: Offset.zero,
        ).animate(animation),
        child: child,
      );
    },
  );
}

class LocationSelectorDialog extends StatelessWidget {
  const LocationSelectorDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final List<String> afghanProvinces = [
      'Badakhshan, Afghanistan',
      'Badghis, Afghanistan',
      'Baghlan, Afghanistan',
      'Balkh, Afghanistan',
      'Bamyan, Afghanistan',
      'Daykundi, Afghanistan',
      'Farah, Afghanistan',
      'Faryab, Afghanistan',
      'Ghazni, Afghanistan',
      'Ghor, Afghanistan',
      'Helmand, Afghanistan',
      'Herat, Afghanistan',
      'Jowzjan, Afghanistan',
      'Kabul, Afghanistan',
      'Kandahar, Afghanistan',
      'Kapisa, Afghanistan',
      'Khost, Afghanistan',
      'Kunar, Afghanistan',
      'Kunduz, Afghanistan',
      'Laghman, Afghanistan',
      'Logar, Afghanistan',
      'Nangarhar, Afghanistan',
      'Nimroz, Afghanistan',
      'Nuristan, Afghanistan',
      'Paktia, Afghanistan',
      'Paktika, Afghanistan',
      'Panjshir, Afghanistan',
      'Parwan, Afghanistan',
      'Samangan, Afghanistan',
      'Sar-e Pol, Afghanistan',
      'Takhar, Afghanistan',
      'Urozgan, Afghanistan',
      'Wardak, Afghanistan',
      'Zabul, Afghanistan',
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Top App Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    "Locations",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),

            // Search Box
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search area, city or province',
                  prefixIcon: const Icon(Icons.search),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  isDense: true,
                ),
              ),
            ),

            // Use current location + See all
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () {
                      // TODO: Add location logic
                    },
                    child: Row(
                      children: const [
                        Icon(Icons.my_location, color: Colors.blue, size: 18),
                        SizedBox(width: 4),
                        Text(
                          "Use Current Location",
                          style: TextStyle(color: Colors.blue),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text(
                      "See all in Afghanistan",
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),

            const Divider(height: 0),

            Expanded(
              child: ListView(
                children: [
                  // Recent Section
                  const Padding(
                    padding: EdgeInsets.fromLTRB(16, 16, 16, 6),
                    child: Text(
                      "Recent",
                      style: TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  _buildLocationTile("Afghanistan"),

                  // Region Header
                  const Padding(
                    padding: EdgeInsets.fromLTRB(16, 20, 16, 6),
                    child: Text(
                      "Choose Province",
                      style: TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  // Region List
                  ...afghanProvinces.map(_buildLocationTile).toList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationTile(String title) {
    return Column(
      children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          title: Text(title),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {
            // TODO: Handle location tap
          },
        ),
        const Divider(height: 0),
      ],
    );
  }
}
