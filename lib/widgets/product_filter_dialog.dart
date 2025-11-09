import 'package:flutter/material.dart';

void showFilterDialog(
  BuildContext context, {
  required List<String>? locations,
  required String? minPrice,
  required String? maxPrice,
  required void Function(List<String>?, String?, String?) onFilterSearch,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (_) => FilterDialog(
      locations: locations,
      minPrice: minPrice,
      maxPrice: maxPrice,
      onFilterSearch: onFilterSearch,
    ),
  );
}

// -----------------------------------------------------------------------------
// Filter Dialog Widget
// -----------------------------------------------------------------------------

class FilterDialog extends StatefulWidget {
  final void Function(List<String>?, String?, String?) onFilterSearch;
  final List<String>? locations;
  final String? minPrice;
  final String? maxPrice;

  const FilterDialog({
    super.key,
    required this.locations,
    required this.maxPrice,
    required this.minPrice,
    required this.onFilterSearch,
  });

  @override
  State<FilterDialog> createState() => _FilterDialogState();
}

class _FilterDialogState extends State<FilterDialog> {
  final TextEditingController minPriceController = TextEditingController();
  final TextEditingController maxPriceController = TextEditingController();

  List<String> selectedLocations = [];
  final List<String> allLocations = [
    'Kabul',
    'Kandahar',
    'Herat',
    'Mazar',
    'Nangarhar',
    'Ghazni',
  ];

  @override
  void initState() {
    super.initState();

    minPriceController.text = widget.minPrice ?? '';
    maxPriceController.text = widget.maxPrice ?? '';
    selectedLocations = widget.locations ?? ["Kandahar"];
  }

  void resetFilters() {
    minPriceController.clear();
    maxPriceController.clear();
    selectedLocations = ["Kandahar"];
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: MediaQuery.of(context).viewInsets,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    "Filter Search",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const Divider(height: 0),

            // Location Selector
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Location",
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () => _showLocationSelectorDialog(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(selectedLocations.join(", ")),
                          const Icon(Icons.arrow_forward_ios, size: 16),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    children: selectedLocations.map((loc) {
                      return InputChip(
                        label: Text(loc),
                        avatar: const Icon(Icons.refresh, size: 18),
                        onPressed: () {
                          setState(() {
                            selectedLocations.remove(loc);
                          });
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),

            const Divider(height: 24),

            // Price Range
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Price",
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _buildPriceInput("Min", minPriceController),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: Text("to"),
                      ),
                      Expanded(
                        child: _buildPriceInput("Max", maxPriceController),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Reset Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: resetFilters,
                  child: const Text(
                    "Reset filters",
                    style: TextStyle(color: Colors.blue),
                  ),
                ),
              ),
            ),

            // Apply Button
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00332D),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    widget.onFilterSearch(
                      selectedLocations,
                      minPriceController.text,
                      maxPriceController.text,
                    );
                    Navigator.pop(context);
                  },
                  child: const Text(
                    "Search for results",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Build price input
  Widget _buildPriceInput(String hint, TextEditingController controller) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        hintText: hint,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 14,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        isDense: true,
      ),
    );
  }

  // Location selector dialog
  Future<void> _showLocationSelectorDialog(BuildContext context) async {
    final List<String> selected = List.from(selectedLocations);

    final List<String> newSelection =
        await showDialog<List<String>>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Select Locations'),
            content: StatefulBuilder(
              builder: (context, setStateDialog) {
                return SingleChildScrollView(
                  child: Column(
                    children: allLocations.map((location) {
                      return CheckboxListTile(
                        title: Text(location),
                        value: selected.contains(location),
                        onChanged: (bool? value) {
                          setStateDialog(() {
                            if (value == true) {
                              selected.add(location);
                            } else {
                              selected.remove(location);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                );
              },
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, selected),
                child: const Text('Done'),
              ),
            ],
          ),
        ) ??
        [];

    if (newSelection.isNotEmpty) {
      setState(() {
        selectedLocations = newSelection;
      });
    }
  }
}
