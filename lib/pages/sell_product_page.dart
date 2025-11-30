import 'dart:convert';
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
    _loadUserInfo();
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
    safeSetState(() {
      _currentLatLng = pos;
    });

    try {
      final placemarks = await placemarkFromCoordinates(
        pos.latitude,
        pos.longitude,
      );

      if (!mounted) return;

      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        final addr = "${p.locality}, ${p.subLocality}, ${p.country}";

        safeSetState(() {
          _currentAddress = addr;
          locationCtrl.text = addr;
        });
      } else {
        safeSetState(() {
          _currentAddress = "${pos.latitude}, ${pos.longitude}";
          locationCtrl.text = _currentAddress!;
        });
      }
    } catch (e) {
      if (!mounted) return;
      safeSetState(() {
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
  bool isPhoneVerified = true;

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

  void safeSetState(VoidCallback fn) {
    if (!mounted) return;
    setState(fn);
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

    if (!mounted) return;
    safeSetState(() {
      if (userInfo['email_verified_at'] != null) {
        isEmailVerified = true;
      } else {
        isEmailVerified = false;
      }
      // if (userInfo['phone_verified_at'] != null) {
      //   isPhoneVerified = true;
      // } else {
      //   isPhoneVerified = false;
      // }
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
  // ... (Keep all your existing controller and state variables)

  /* ---------------------- UI Redesign Starts Here ---------------------- */
  Widget _blockedPage(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: const Color(
                  0xFF0053E2,
                ).withOpacity(0.1), // Blue with opacity
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.lock_clock,
                size: 50,
                color: const Color(0xFF0053E2),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              "Verification Required",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                "Please verify your phone & email to start selling on Sawdagar ",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey[600],
                  height: 1.4,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF0053E2),
                    Color(0xFF0042B3),
                  ], // Blue gradient
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: const Color(
                      0xFF0053E2,
                    ).withOpacity(0.3), // Blue shadow
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(25),
                child: InkWell(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => UserSettingsPage()),
                  ),
                  borderRadius: BorderRadius.circular(25),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 14,
                    ),
                    child: const Text(
                      "Verify Account",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Optional: Add a secondary button with orange color
            Container(
              decoration: BoxDecoration(
                color: const Color(
                  0xFFFFC220,
                ).withOpacity(0.1), // Orange background
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: const Color(0xFFFFC220).withOpacity(0.3),
                  width: 1.5,
                ),
              ),
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(25),
                child: InkWell(
                  onTap: () {
                    // Add alternative action
                  },
                  borderRadius: BorderRadius.circular(25),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 14,
                    ),
                    child: Text(
                      "Contact Support",
                      style: TextStyle(
                        color: const Color(0xFFFFC220), // Orange text
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    if (!isPhoneVerified || !isEmailVerified) {
      return _blockedPage(context);
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: colors.primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Create Listing',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: colors.primary,
          ),
        ),
        centerTitle: true,
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
        child: CustomScrollView(
          slivers: [
            SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: 16),

                // Media Section
                _ModernSection(
                  title: "Media",
                  subtitle: "Add photos and video of your item",
                  child: Column(
                    children: [
                      _ModernPhotoGrid(
                        photos: photos.map((f) => FileImage(f)).toList(),
                        onAdd: photos.length < 10 ? _addPhotos : null,
                        onRemove: _removePhoto,
                      ),
                      const SizedBox(height: 16),
                      if (videoFile == null)
                        _ModernAddCard(
                          onTap: _pickVideo,
                          icon: Icons.videocam_rounded,
                          title: "Add Video",
                          subtitle: "Optional - max 1 video",
                        )
                      else
                        _VideoPreviewCard(
                          videoFile: videoFile!,
                          videoController: videoController,
                          onRemove: _removeVideo,
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Details Section
                _ModernSection(
                  title: "Product Details",
                  subtitle: "Tell us about what you're selling",
                  child: Column(
                    children: [
                      _ModernInputField(
                        label: 'Title',
                        controller: titleCtrl,
                        hint: 'What are you selling?',
                        icon: Icons.title_rounded,
                        validator: (v) =>
                            (v == null || v.trim().isEmpty) ? 'Required' : null,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: _ModernInputField(
                              label: 'Price',
                              controller: priceCtrl,
                              hint: '0',
                              icon: Icons.attach_money_rounded,
                              keyboardType: TextInputType.numberWithOptions(
                                decimal: true,
                              ),
                              validator: (v) => (v == null || v.trim().isEmpty)
                                  ? 'Required'
                                  : null,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 2,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Currency',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: colors.onSurface.withOpacity(0.7),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  decoration: BoxDecoration(
                                    color: colors.surface,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: colors.outline.withOpacity(0.3),
                                    ),
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      value: selectedCurrency,
                                      items: currencies
                                          .map(
                                            (c) => DropdownMenuItem(
                                              value: c,
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 12,
                                                    ),
                                                child: Text(
                                                  c,
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          )
                                          .toList(),
                                      onChanged: (value) {
                                        if (value != null) {
                                          setState(
                                            () => selectedCurrency = value,
                                          );
                                        }
                                      },
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _ModernPickerCard(
                        label: 'Category',
                        value: category ?? 'Select Category',
                        onTap: _openCategorySheet,
                        icon: Icons.category_rounded,
                        isRequired: true,
                      ),
                      const SizedBox(height: 12),
                      _ModernPickerCard(
                        label: 'Condition',
                        value: condition,
                        onTap: _openConditionSheet,
                        icon: Icons.verified_rounded,
                      ),
                      const SizedBox(height: 16),
                      _ModernTextArea(
                        label: 'Description',
                        controller: descCtrl,
                        hint: 'Describe your item in detail...',
                        maxLength: 1000,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Availability Section
                _ModernSection(
                  title: "Availability",
                  subtitle: "How can buyers get this item?",
                  child: Column(
                    children: [
                      _ModernSwitchTile(
                        title: "Available for Pickup",
                        value: availableForPickup,
                        onChanged: (v) =>
                            setState(() => availableForPickup = v),
                        icon: Icons.storefront_rounded,
                      ),
                      _ModernSwitchTile(
                        title: "Available for Delivery",
                        value: availableForDelivery,
                        onChanged: (v) =>
                            setState(() => availableForDelivery = v),
                        icon: Icons.delivery_dining_rounded,
                      ),
                      if (availableForDelivery) ...[
                        const SizedBox(height: 16),
                        _ModernPickerCard(
                          label: 'Delivery Locations',
                          value: selectedPickupLocations.isEmpty
                              ? 'Select locations'
                              : '${selectedPickupLocations.length} selected',
                          onTap: _selectPickupLocations,
                          icon: Icons.location_pin,
                        ),
                        const SizedBox(height: 12),
                        _ModernSwitchTile(
                          title: "Afghan Bazaar Delivery",
                          subtitle: "Use our delivery network",
                          value: deliveryByAfghanBazaar,
                          onChanged: (v) =>
                              setState(() => deliveryByAfghanBazaar = v),
                          icon: Icons.local_shipping_rounded,
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Location Section
                _ModernSection(
                  title: "Location",
                  subtitle: "Where is this item located?",
                  child: Column(
                    children: [
                      Container(
                        height: 180,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: colors.surface,
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: _currentLatLng == null
                              ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      CircularProgressIndicator(
                                        color: colors.primary,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        "Loading map...",
                                        style: TextStyle(
                                          color: colors.onSurface.withOpacity(
                                            0.6,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
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
                                      icon:
                                          BitmapDescriptor.defaultMarkerWithHue(
                                            BitmapDescriptor.hueRed,
                                          ),
                                    ),
                                  },
                                  onTap: (pos) => _updateLocation(pos),
                                ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _ModernInputField(
                        label: 'Pickup Location',
                        controller: locationCtrl,
                        hint: 'Enter your location',
                        icon: Icons.location_on_rounded,
                        readOnly: false,
                      ),
                      if (_currentAddress != null)
                        Container(
                          margin: const EdgeInsets.only(top: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: colors.primary.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: colors.primary.withOpacity(0.1),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.gps_fixed_rounded,
                                size: 16,
                                color: colors.primary,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  "Detected: $_currentAddress",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: colors.onSurface.withOpacity(0.7),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),
              ]),
            ),
          ],
        ),
      ),
    );
  }

  // ... (Keep all your existing methods: _getCurrentLocation, _updateLocation,
  // _addPhotos, _removePhoto, _pickVideo, _removeVideo, _openCategorySheet,
  // _openConditionSheet, _loadUserInfo, _submit, _selectPickupLocations)
}

/* --------------------------- Modern Widget Components --------------------------- */

class _ModernSection extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;

  const _ModernSection({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(fontSize: 13, color: Colors.grey[600]),
              ),
            ],
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }
}

class _ModernPhotoGrid extends StatelessWidget {
  final List<ImageProvider> photos;
  final VoidCallback? onAdd;
  final void Function(int index) onRemove;

  const _ModernPhotoGrid({
    required this.photos,
    this.onAdd,
    required this.onRemove,
  });

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
          return _ModernAddPhotoCard(onTap: onAdd!);
        }
        return _ModernPhotoCard(
          image: photos[val],
          onRemove: () => onRemove(val),
        );
      },
    );
  }
}

class _ModernAddPhotoCard extends StatelessWidget {
  final VoidCallback onTap;

  const _ModernAddPhotoCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.grey[100],
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.add_photo_alternate_rounded,
                color: Colors.grey[500],
                size: 28,
              ),
              const SizedBox(height: 4),
              Text(
                "Add",
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ModernPhotoCard extends StatelessWidget {
  final ImageProvider image;
  final VoidCallback onRemove;

  const _ModernPhotoCard({required this.image, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.black12,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image(image: image, fit: BoxFit.cover),
          ),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: Material(
            color: Colors.black54,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              onTap: onRemove,
              borderRadius: BorderRadius.circular(12),
              child: const Padding(
                padding: EdgeInsets.all(4),
                child: Icon(Icons.close_rounded, size: 14, color: Colors.white),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ModernAddCard extends StatelessWidget {
  final VoidCallback onTap;
  final IconData icon;
  final String title;
  final String subtitle;

  const _ModernAddCard({
    required this.onTap,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.grey[50],
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }
}

class _VideoPreviewCard extends StatelessWidget {
  final File videoFile;
  final VideoPlayerController? videoController;
  final VoidCallback onRemove;

  const _VideoPreviewCard({
    required this.videoFile,
    this.videoController,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.black12,
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child:
                  videoController != null &&
                      videoController!.value.isInitialized
                  ? VideoPlayer(videoController!)
                  : Container(
                      color: Colors.grey[200],
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(),
                            const SizedBox(height: 8),
                            Text(
                              "Loading video...",
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ),
                    ),
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: Material(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                onTap: onRemove,
                borderRadius: BorderRadius.circular(12),
                child: const Padding(
                  padding: EdgeInsets.all(6),
                  child: Icon(
                    Icons.close_rounded,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          if (videoController != null && videoController!.value.isInitialized)
            Positioned.fill(
              child: Center(
                child: Material(
                  color: Colors.black38,
                  borderRadius: BorderRadius.circular(25),
                  child: IconButton(
                    icon: Icon(
                      videoController!.value.isPlaying
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      if (videoController!.value.isPlaying) {
                        videoController!.pause();
                      } else {
                        videoController!.play();
                      }
                    },
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ModernInputField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String? hint;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final IconData icon;
  final bool readOnly;

  const _ModernInputField({
    required this.label,
    required this.controller,
    this.hint,
    this.validator,
    this.keyboardType,
    required this.icon,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          validator: validator,
          keyboardType: keyboardType,
          readOnly: readOnly,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, size: 20),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            filled: true,
            fillColor: Colors.grey[50],
          ),
        ),
      ],
    );
  }
}

class _ModernPickerCard extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;
  final IconData icon;
  final bool isRequired;

  const _ModernPickerCard({
    required this.label,
    required this.value,
    required this.onTap,
    required this.icon,
    this.isRequired = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: Theme.of(context).colorScheme.primary,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          label,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[700],
                          ),
                        ),
                        if (isRequired)
                          Text(
                            " *",
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      value,
                      style: TextStyle(
                        fontSize: 14,
                        color: value.contains('Select')
                            ? Colors.grey[500]
                            : Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }
}

class _ModernTextArea extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String? hint;
  final int maxLength;

  const _ModernTextArea({
    required this.label,
    required this.controller,
    this.hint,
    this.maxLength = 1000,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          maxLines: 5,
          maxLength: maxLength,
          decoration: InputDecoration(
            hintText: hint,
            alignLabelWithHint: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            filled: true,
            fillColor: Colors.grey[50],
          ),
        ),
      ],
    );
  }
}

class _ModernSwitchTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final IconData icon;

  const _ModernSwitchTile({
    required this.title,
    this.subtitle,
    required this.value,
    required this.onChanged,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onChanged(!value),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: Theme.of(context).colorScheme.primary,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ],
                ),
              ),
              Switch.adaptive(
                value: value,
                onChanged: onChanged,
                activeColor: Theme.of(context).colorScheme.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
