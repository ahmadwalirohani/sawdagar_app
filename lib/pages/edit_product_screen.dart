import 'dart:io';
import 'package:afghan_bazar/blocs/my_ads_bloc.dart';
import 'package:afghan_bazar/models/product_ads_model.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class EditProductScreen extends StatefulWidget {
  final ProductAdsModel product;

  const EditProductScreen({Key? key, required this.product}) : super(key: key);

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _priceController;
  late TextEditingController _descriptionController;
  late TextEditingController _locationController;

  List<String> _selectedLocations = [];
  List<XFile> _newImages = [];
  List<String> _existingImages = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.product.title);
    _priceController = TextEditingController(
      text: widget.product.price.toString(),
    );
    _descriptionController = TextEditingController(
      text: widget.product.description ?? '',
    );
    _locationController = TextEditingController(
      text: widget.product.location ?? '',
    );
    _existingImages = List.from(widget.product.photos ?? []);

    // Parse locations if they exist
    if (widget.product.availableLocations != null &&
        widget.product.availableLocations!.isNotEmpty) {
      _selectedLocations = List.from(widget.product.availableLocations!);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final pickedFiles = await picker.pickMultiImage(
      maxWidth: 1920,
      maxHeight: 1080,
      imageQuality: 85,
    );

    if (pickedFiles != null && pickedFiles.isNotEmpty) {
      setState(() {
        _newImages.addAll(pickedFiles);
      });
    }
  }

  void _removeImage(int index, bool isExisting) {
    setState(() {
      if (isExisting) {
        _existingImages.removeAt(index);
      } else {
        _newImages.removeAt(index);
      }
    });
  }

  Future<void> _updateProduct() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final myAdsBloc = context.read<MyAdsBloc>();

      // Prepare updated product data
      final updatedProduct = ProductAdsModel(
        id: widget.product.id,
        userId: widget.product.userId,
        title: _titleController.text.trim(),
        price: _priceController.text.trim(),
        description: _descriptionController.text.trim(),
        location: _locationController.text.trim(),
        availableLocations: _selectedLocations,
        // Keep other fields unchanged
        currency: widget.product.currency,
        condition: widget.product.condition,
        status: widget.product.status,
        isFavorite: widget.product.isFavorite,
        createdAt: widget.product.createdAt,
        photos: _existingImages, // Updated existing images
      );

      // Call API to update product
      final success = await myAdsBloc.updateProduct(
        updatedProduct,
        newImages: _newImages,
        deletedImages: widget.product.photos!
            .where((img) => !_existingImages.contains(img))
            .toList(),
      );

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Product updated successfully')),
        );
        Navigator.pop(context, true); // Return success
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update product')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showLocationPicker() {
    // This is a simplified version - you should implement your actual location picker
    // For now, using a simple dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Locations'),
        content: StatefulBuilder(
          builder: (context, setState) {
            // Replace with your actual locations list
            final allLocations = [
              'Badakhshan',
              'Badghis',
              'Baghlan',
              'Balkh',
              'Bamyan',
              'Daykundi',
              'Farah',
              'Faryab',
              'Ghazni',
              'Ghor',
              'Helmand',
              'Herat',
              'Jowzjan',
              'Kabul',
              'Kandahar',
              'Kapisa',
              'Khost',
              'Kunar',
              'Kunduz',
              'Laghman',
              'Logar',
              'Maidan Wardak',
              'Nangarhar',
              'Nimroz',
              'Nuristan',
              'Paktia',
              'Paktika',
              'Panjshir',
              'Parwan',
              'Samangan',
              'Sar-e Pol',
              'Takhar',
              'Urozgan',
              'Zabul',
            ];

            return SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: allLocations.length,
                itemBuilder: (context, index) {
                  final location = allLocations[index];
                  final isSelected = _selectedLocations.contains(location);

                  return CheckboxListTile(
                    title: Text(location),
                    value: isSelected,
                    onChanged: (value) {
                      setState(() {
                        if (value == true) {
                          _selectedLocations.add(location);
                        } else {
                          _selectedLocations.remove(location);
                        }
                      });
                    },
                  );
                },
              ),
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _locationController.text = _selectedLocations.join(', ');
              });
              Navigator.pop(context);
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Product'),
        actions: [
          IconButton(
            onPressed: _isLoading ? null : _updateProduct,
            icon: _isLoading
                ? const CircularProgressIndicator()
                : const Icon(Icons.save),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Images Section
                    const Text(
                      'Product Images',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tap to add new images, long press to remove',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 12),

                    // Existing Images
                    if (_existingImages.isNotEmpty) ...[
                      Text(
                        'Existing Images:',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 100,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _existingImages.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: GestureDetector(
                                onTap: () => _removeImage(index, true),
                                child: Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.network(
                                        _existingImages[index],
                                        width: 100,
                                        height: 100,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    Positioned(
                                      top: 4,
                                      right: 4,
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: const BoxDecoration(
                                          color: Colors.red,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.close,
                                          size: 16,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // New Images
                    Text(
                      'New Images:',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 100,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _newImages.length + 1,
                        itemBuilder: (context, index) {
                          if (index == _newImages.length) {
                            return GestureDetector(
                              onTap: _pickImages,
                              child: Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.add_photo_alternate,
                                      size: 40,
                                      color: Colors.grey,
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'Add Image',
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }

                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: GestureDetector(
                              onTap: () => _removeImage(index, false),
                              child: Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.file(
                                      File(_newImages[index].path),
                                      width: 100,
                                      height: 100,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Positioned(
                                    top: 4,
                                    right: 4,
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: const BoxDecoration(
                                        color: Colors.red,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.close,
                                        size: 16,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Title
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Product Title',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a title';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // Price
                    TextFormField(
                      controller: _priceController,
                      decoration: const InputDecoration(
                        labelText: 'Price',
                        border: OutlineInputBorder(),
                        prefixText: '\$ ',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a price';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // Location
                    TextFormField(
                      controller: _locationController,
                      decoration: InputDecoration(
                        labelText: 'Location',
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          onPressed: _showLocationPicker,
                          icon: const Icon(Icons.location_on),
                        ),
                      ),
                      readOnly: true,
                      onTap: _showLocationPicker,
                    ),

                    const SizedBox(height: 16),

                    // Selected Locations (if multiple)
                    if (_selectedLocations.isNotEmpty) ...[
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: _selectedLocations.map((location) {
                          return Chip(
                            label: Text(location),
                            onDeleted: () {
                              setState(() {
                                _selectedLocations.remove(location);
                                _locationController.text = _selectedLocations
                                    .join(', ');
                              });
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Description
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(),
                        alignLabelWithHint: true,
                      ),
                      maxLines: 5,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a description';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 32),

                    // Update Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _updateProduct,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text(
                                'Update Product',
                                style: TextStyle(fontSize: 16),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
