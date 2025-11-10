import 'dart:convert';

import 'package:afghan_bazar/pages/account_profile_page.dart';
import 'package:afghan_bazar/pages/home.dart';
import 'package:afghan_bazar/pages/setting_page.dart';
import 'package:afghan_bazar/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

class MarketplaceSellPage extends StatefulWidget {
  const MarketplaceSellPage({super.key});

  @override
  State<MarketplaceSellPage> createState() => _MarketplaceSellPageState();
}

class _MarketplaceSellPageState extends State<MarketplaceSellPage> {
  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  GoogleMapController? _mapController;
  LatLng? _currentLatLng;
  String? _currentAddress;
  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    if (permission == LocationPermission.deniedForever) {
      // Optionally, show a dialog directing the user to settings
      return;
    }

    Position pos = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    _updateLocation(LatLng(pos.latitude, pos.longitude));
  }

  Future<void> _updateLocation(LatLng pos) async {
    setState(() {
      _currentLatLng = pos;
    });

    try {
      final placemarks = await placemarkFromCoordinates(
        pos.latitude,
        pos.longitude,
      );
      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        final addr = "${p.locality}, ${p.subLocality}, ${p.country}";
        setState(() {
          _currentAddress = addr;
          locationCtrl.text = addr;
        });
      } else {
        setState(() {
          _currentAddress = "${pos.latitude}, ${pos.longitude}";
          locationCtrl.text = _currentAddress!;
        });
      }
    } catch (e) {
      setState(() {
        _currentAddress = "${pos.latitude}, ${pos.longitude}";
        locationCtrl.text = _currentAddress!;
      });
    }
  }

  final _formKey = GlobalKey<FormState>();

  // Controllers
  final titleCtrl = TextEditingController();
  final priceCtrl = TextEditingController();
  final descCtrl = TextEditingController();
  final locationCtrl = TextEditingController();

  // State
  final List<File> photos = [];
  File? videoFile;
  VideoPlayerController? videoController;

  String? category;
  String condition = 'Used – Good';
  bool allowOffers = true;
  bool hideFromFriends = false;
  bool availableForPickup = true;
  bool availableForDelivery = false;
  bool isEmailVerified = false;
  bool isPhoneVerified = false;

  final picker = ImagePicker();

  final categories = const [
    {'name': 'Mobiles', 'imagePath': 'assets/images/ic_mobiles.png'},
    {'name': 'Services', 'imagePath': 'assets/images/ic_services.png'},
    {'name': 'Vehicles', 'imagePath': 'assets/images/ic_motors.png'},
    {'name': 'Jobs', 'imagePath': 'assets/images/ic_jobs.png'},
    {
      'name': 'Property for Sales',
      'imagePath': 'assets/images/ic_property.png',
    },
    {'name': 'Animals', 'imagePath': 'assets/images/ic_animals.png'},
    {
      'name': 'Property for Rent',
      'imagePath': 'assets/images/ic_property_for_rent.png',
    },
    {
      'name': 'Furnitures & Home Decoration',
      'imagePath': 'assets/images/ic_furniture.png',
    },
    {
      'name': 'Electornices & Home Applainces',
      'imagePath': 'assets/images/ic_electronics.png',
    },
    {'name': 'Fashion and Beauty', 'imagePath': 'assets/images/ic_fashion.png'},
    {'name': 'Bikes', 'imagePath': 'assets/images/ic_bikes.png'},
    {
      'name': 'Books ,Sports &  Hobbies',
      'imagePath': 'assets/images/ic_books.png',
    },
    {
      'name': 'Bussiness ,Industrial & Agriculture',
      'imagePath': 'assets/images/ic_business_industrial.png',
    },
    {'name': 'Kids', 'imagePath': 'assets/images/ic_for_kids.png'},
  ];

  final conditions = const [
    'New',
    'Like New',
    'Used – Good',
    'Used – Fair',
    'For Parts',
  ];

  String selectedCurrency = 'AFN'; // Default
  final List<String> currencies = ['AFN', 'USD', 'EUR', 'INR', 'PKR'];

  @override
  void dispose() {
    // titleCtrl.dispose();
    // priceCtrl.dispose();
    // descCtrl.dispose();
    // locationCtrl.dispose();
    // videoController?.dispose();
    super.dispose();
  }

  /* ---------------------- Image / Video Pickers ---------------------- */

  Future<void> _addPhotos() async {
    if (photos.length >= 10) return;

    final picked = await picker.pickMultiImage(imageQuality: 80);

    if (picked.isNotEmpty) {
      List<File> newFiles = [];

      for (var file in picked) {
        final targetPath =
            '${file.path.substring(0, file.path.lastIndexOf('/'))}/compressed_${DateTime.now().millisecondsSinceEpoch}.jpg';

        // compress + resize
        final compressedFile = await FlutterImageCompress.compressAndGetFile(
          file.path,
          targetPath,
          quality: 80,
          minWidth: 512,
          minHeight: 350,
        );

        if (compressedFile != null) {
          newFiles.add(File(compressedFile.path));
        }
      }

      setState(() {
        photos.addAll(newFiles);
        if (photos.length > 10) {
          photos.removeRange(10, photos.length); // keep only 10
        }
      });
    }
  }

  void _removePhoto(int index) {
    setState(() => photos.removeAt(index));
  }

  void _openConditionSheet() async {
    final chosen = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: ListView.separated(
          itemCount: conditions.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (ctx, i) => ListTile(
            title: Text(conditions[i]),
            trailing: condition == conditions[i]
                ? const Icon(Icons.check)
                : const SizedBox.shrink(),
            onTap: () => Navigator.pop(ctx, conditions[i]),
          ),
        ),
      ),
    );
    if (chosen != null) setState(() => condition = chosen);
  }

  Future<void> _pickVideo() async {
    if (videoFile != null) return; // only one video
    final picked = await picker.pickVideo(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        videoFile = File(picked.path);
        videoController = VideoPlayerController.file(videoFile!)
          ..initialize().then((_) {
            setState(() {});
          });
      });
    }
  }

  void _removeVideo() {
    videoController?.dispose();
    setState(() {
      videoFile = null;
      videoController = null;
    });
  }

  void _openCategorySheet() async {
    final chosen = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: ListView.separated(
          itemCount: categories.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (ctx, i) {
            final item = categories[i];
            final name = item['name']!;
            final imagePath = item['imagePath']!;

            return ListTile(
              leading: Image.asset(
                imagePath,
                width: 30,
                height: 30,
                fit: BoxFit.contain,
              ),
              title: Text(name),
              trailing: category == name
                  ? const Icon(Icons.check)
                  : const SizedBox.shrink(),
              onTap: () => Navigator.pop(ctx, name),
            );
          },
        ),
      ),
    );

    if (chosen != null) setState(() => category = chosen);
  }

  Future<void> _loadUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    var userInfo = json.decode(prefs.getString('user_info') ?? '');

    setState(() {
      if (userInfo['email_verified_at'] != null) {
        isEmailVerified = true;
      } else {
        isEmailVerified = false;
      }
      if (userInfo['phone_verified_at'] != null) {
        isPhoneVerified = true;
      } else {
        isPhoneVerified = false;
      }
    });
  }
  /* -------------------------- Form Submit --------------------------- */

  bool _isSubmitting = false;
  String? _errorMessage;
  String? _successMessage;

  Future<void> _submit() async {
    final valid = _formKey.currentState?.validate() ?? false;
    if (!valid) return;

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      var uri = Uri.parse("${AuthService.baseUrl}/product-ads/create");
      var request = http.MultipartRequest("POST", uri);

      request.fields.addAll({
        'title': titleCtrl.text.trim(),
        'price': priceCtrl.text.trim(),
        'currency': selectedCurrency,
        'category': category ?? '',
        'condition': condition,
        'description': descCtrl.text.trim(),
        'location': locationCtrl.text.trim(),
        'allow_offers': allowOffers ? '1' : '0',
        'hide_from_friends': hideFromFriends ? '1' : '0',
        'pickup': availableForPickup ? '1' : '0',
        'delivery': availableForDelivery ? '1' : '0',
        'pickup_locations': selectedPickupLocations.join(','),
        'delivery_by_afghanbazaar': deliveryByAfghanBazaar ? '1' : '0',
        'latitude': _currentLatLng?.latitude.toString() ?? '',
        'longitude': _currentLatLng?.longitude.toString() ?? '',
      });

      for (int i = 0; i < photos.length; i++) {
        request.files.add(
          await http.MultipartFile.fromPath('photos[$i]', photos[i].path),
        );
      }

      if (videoFile != null) {
        request.files.add(
          await http.MultipartFile.fromPath('video', videoFile!.path),
        );
      }

      final response = await AuthService().authPost(
        "ads",
        body: request,
        isMultipart: true,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        setState(() => _successMessage = "✅ Ad created successfully!");

        // short delay so user sees success banner
        await Future.delayed(const Duration(seconds: 2));

        if (!mounted) return;

        // navigate & remove this page from stack
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
      } else {
        setState(() {
          _errorMessage = "Failed: ${response.body}";
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Error: $e";
      });
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  // state variables
  List<String> selectedPickupLocations = [];
  bool deliveryByAfghanBazaar = false;

  final pickupLocations = const [
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

  void _selectPickupLocations() async {
    final chosen = await showDialog<List<String>>(
      context: context,
      builder: (ctx) {
        final tempSelected = List<String>.from(selectedPickupLocations);
        return AlertDialog(
          title: const Text('Select Pickup Locations'),
          content: StatefulBuilder(
            builder: (ctx, setStateDialog) => SizedBox(
              width: double.maxFinite,
              child: ListView(
                shrinkWrap: true,
                children: pickupLocations.map((loc) {
                  return CheckboxListTile(
                    title: Text(loc),
                    value: tempSelected.contains(loc),
                    onChanged: (v) {
                      setStateDialog(() {
                        if (v == true) {
                          tempSelected.add(loc);
                        } else {
                          tempSelected.remove(loc);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, null),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, tempSelected),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );

    if (chosen != null) {
      setState(() => selectedPickupLocations = chosen);
    }
  }

  /* ---------------------------- UI ---------------------------- */

  Widget _blockedPage(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Verification Required")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock, size: 70, color: Colors.red),
            const SizedBox(height: 16),
            const Text("Please verify your phone & email before posting."),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => UserSettingsPage()),
              ),
              child: const Text("Verify Account"),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (!isPhoneVerified || !isEmailVerified) {
      return _blockedPage(context);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create new Ads'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.purple, Colors.deepPurpleAccent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 6,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: TextButton(
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                onPressed: _isSubmitting ? null : _submit,
                child: _isSubmitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        "🚀 Post",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
          children: [
            _Section(
              title: 'Photos',
              trailing: Text(
                '${photos.length}/10',
                style: theme.textTheme.bodyMedium,
              ),
              child: _PhotoGrid(
                photos: photos.map((f) => FileImage(f)).toList(),
                onAdd: photos.length < 10 ? _addPhotos : null,
                onRemove: _removePhoto,
              ),
            ),
            const SizedBox(height: 12),

            _Section(
              title: 'Video (max 1)',
              child: videoFile == null
                  ? _AddPhotoTile(
                      onTap: _pickVideo,
                      label: "Add Video",
                      icon: Icons.videocam,
                    )
                  : Stack(
                      children: [
                        AspectRatio(
                          aspectRatio:
                              videoController?.value.aspectRatio ?? 16 / 9,
                          child:
                              videoController != null &&
                                  videoController!.value.isInitialized
                              ? VideoPlayer(videoController!)
                              : const Center(
                                  child: CircularProgressIndicator(),
                                ),
                        ),
                        Positioned(
                          top: 6,
                          right: 6,
                          child: Material(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(20),
                            child: InkWell(
                              onTap: _removeVideo,
                              borderRadius: BorderRadius.circular(20),
                              child: const Padding(
                                padding: EdgeInsets.all(6),
                                child: Icon(
                                  Icons.close,
                                  size: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
            const SizedBox(height: 12),

            /* ------------------ Other form fields (unchanged) ------------------ */
            // Keep all your details, availability, location, safety tips sections
            // ... (copy your existing code for details, availability, etc.)
            const SizedBox(height: 12),
            _Section(
              title: 'Details',
              child: Column(
                children: [
                  _InputTile(
                    label: 'Title',
                    controller: titleCtrl,
                    hint: 'What are you selling?',
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Required' : null,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      // Expanded Price Input
                      Expanded(
                        flex: 3,
                        child: _InputTile(
                          label: 'Price',
                          controller: priceCtrl,
                          hint: '0',
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'Required'
                              : null,
                        ),
                      ),

                      const SizedBox(width: 10),

                      // Currency Dropdown
                      Expanded(
                        flex: 1,
                        child: DropdownButtonFormField<String>(
                          value: selectedCurrency,
                          items: currencies
                              .map(
                                (c) =>
                                    DropdownMenuItem(value: c, child: Text(c)),
                              )
                              .toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                selectedCurrency = value;
                              });
                            }
                          },
                          decoration: const InputDecoration(
                            labelText: 'Currency',
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _PickerTile(
                    label: 'Category',
                    value: category ?? 'Select',
                    onTap: _openCategorySheet,
                    isError: category == null,
                  ),
                  const SizedBox(height: 10),
                  _PickerTile(
                    label: 'Condition',
                    value: condition,
                    onTap: _openConditionSheet,
                  ),
                  const SizedBox(height: 10),
                  _MultilineTile(
                    label: 'Description',
                    controller: descCtrl,
                    hint:
                        'Add key details buyers care about (brand, specs, defects)...',
                    maxLength: 1000,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _Section(
              title: 'Availability',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CheckboxListTile(
                    title: const Text('Available for pickup'),
                    value: availableForPickup,
                    onChanged: (v) =>
                        setState(() => availableForPickup = v ?? false),
                  ),
                  CheckboxListTile(
                    title: const Text('Available for delivery'),
                    value: availableForDelivery,
                    onChanged: (v) =>
                        setState(() => availableForDelivery = v ?? false),
                  ),
                  if (availableForDelivery) ...[
                    const Divider(height: 20),
                    ListTile(
                      title: const Text('Availible Locations'),
                      subtitle: Text(
                        selectedPickupLocations.isEmpty
                            ? 'None selected'
                            : selectedPickupLocations.join(', '),
                      ),
                      trailing: const Icon(Icons.edit_location_alt_outlined),
                      onTap: _selectPickupLocations,
                    ),
                    CheckboxListTile(
                      title: const Text('Delivery by Afghan Bazaar service'),
                      subtitle: const Text(
                        'Your order will be handled by Afghan Bazaar\'s delivery network.',
                        style: TextStyle(fontSize: 12, color: Colors.black54),
                      ),
                      value: deliveryByAfghanBazaar,
                      onChanged: (v) =>
                          setState(() => deliveryByAfghanBazaar = v ?? false),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 12),
            _Section(
              title: 'Location',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 200,
                    child: _currentLatLng == null
                        ? const Center(child: CircularProgressIndicator())
                        : GoogleMap(
                            initialCameraPosition: CameraPosition(
                              target: _currentLatLng!,
                              zoom: 14,
                            ),
                            onMapCreated: (controller) =>
                                _mapController = controller,
                            markers: {
                              Marker(
                                markerId: const MarkerId('pickup'),
                                position: _currentLatLng!,
                                draggable: true,
                                onDragEnd: (pos) => _updateLocation(pos),
                              ),
                            },
                            onTap: (pos) => _updateLocation(pos),
                          ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: locationCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Pickup location',
                      prefixIcon: Icon(Icons.location_on_outlined),
                      border: OutlineInputBorder(),
                    ),
                    readOnly: false,
                  ),
                  if (_currentAddress != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        "Detected: $_currentAddress",
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                  if (_errorMessage != null)
                    Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        border: Border.all(color: Colors.red),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red, fontSize: 14),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/* --------------------------- Reusable widgets --------------------------- */

class _Section extends StatelessWidget {
  final String title;
  final Widget child;
  final Widget? trailing;
  const _Section({required this.title, required this.child, this.trailing});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Material(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                Text(
                  title,
                  style: t.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                if (trailing != null) trailing!,
              ],
            ),
            const SizedBox(height: 10),
            child,
          ],
        ),
      ),
    );
  }
}

class _PhotoGrid extends StatelessWidget {
  final List<ImageProvider> photos;
  final VoidCallback? onAdd;
  final void Function(int index) onRemove;
  const _PhotoGrid({required this.photos, this.onAdd, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    final canAdd = onAdd != null;
    final items = [for (int i = 0; i < photos.length; i++) i, if (canAdd) -1];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
      ),
      itemBuilder: (ctx, idx) {
        final val = items[idx];
        if (val == -1) {
          return _AddPhotoTile(onTap: onAdd!);
        }
        return _PhotoTile(image: photos[val], onRemove: () => onRemove(val));
      },
    );
  }
}

class _AddPhotoTile extends StatelessWidget {
  final VoidCallback onTap;
  final String label;
  final IconData icon;
  const _AddPhotoTile({
    required this.onTap,
    this.label = "Add",
    this.icon = Icons.add_a_photo_outlined,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      clipBehavior: Clip.antiAlias,
      borderRadius: BorderRadius.circular(12),
      color: Theme.of(context).colorScheme.surfaceVariant,
      child: InkWell(
        onTap: onTap,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 28),
              const SizedBox(height: 6),
              Text(label, style: const TextStyle(fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }
}

class _PhotoTile extends StatelessWidget {
  final ImageProvider image;
  final VoidCallback onRemove;
  const _PhotoTile({required this.image, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: Container(
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.black12,
            ),
            child: Image(image: image, fit: BoxFit.cover),
          ),
        ),
        Positioned(
          top: 6,
          right: 6,
          child: Material(
            color: Colors.black54,
            borderRadius: BorderRadius.circular(20),
            child: InkWell(
              onTap: onRemove,
              borderRadius: BorderRadius.circular(20),
              child: const Padding(
                padding: EdgeInsets.all(6),
                child: Icon(Icons.close, size: 16, color: Colors.white),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _InputTile extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String? hint;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final Widget? prefix;
  final Widget? prefixIcon;

  const _InputTile({
    required this.label,
    required this.controller,
    this.hint,
    this.validator,
    this.keyboardType,
    this.prefix,
    this.prefixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefix: prefix,
        prefixIcon: prefixIcon,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
      ),
    );
  }
}

class _PickerTile extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;
  final bool isError;
  const _PickerTile({
    required this.label,
    required this.value,
    required this.onTap,
    this.isError = false,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final borderColor = isError ? cs.error : cs.outline;
    return Material(
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          decoration: BoxDecoration(
            border: Border.all(color: borderColor),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
              const Spacer(),
              Text(value, style: TextStyle(color: cs.onSurfaceVariant)),
              const SizedBox(width: 6),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}

class _MultilineTile extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String? hint;
  final int maxLength;

  const _MultilineTile({
    required this.label,
    required this.controller,
    this.hint,
    this.maxLength = 1000,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: 6,
      maxLength: maxLength,
      decoration: InputDecoration(
        alignLabelWithHint: true,
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
      ),
    );
  }
}

class _SwitchTile extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  const _SwitchTile({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(label),
      contentPadding: EdgeInsets.zero,
      trailing: Switch(value: value, onChanged: onChanged),
      onTap: () => onChanged(!value),
    );
  }
}
