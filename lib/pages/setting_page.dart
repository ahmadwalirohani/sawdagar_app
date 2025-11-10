import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:afghan_bazar/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserSettingsPage extends StatefulWidget {
  const UserSettingsPage({Key? key}) : super(key: key);

  @override
  State<UserSettingsPage> createState() => _UserSettingsPageState();
}

class _UserSettingsPageState extends State<UserSettingsPage> {
  bool isEmailVerified = false;
  bool isPhoneVerified = false;
  bool notificationsEnabled = true;

  String userEmail = "user@example.com";
  String? userPhone; // null means not provided
  File? profileImageFile;
  String? defaultProfileImage = "https://via.placeholder.com/150";

  int totalAds = 32;
  double averageRating = 4.5;
  double totalIncome = 25340.75;
  int totalOrders = 128;

  final _formKey = GlobalKey<FormState>();
  bool _showOld = false;
  bool _showNew = false;
  bool _showConfirm = false;
  String _oldPassword = '';
  String _newPassword = '';
  String _confirmPassword = '';

  final TextEditingController _phoneController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );

    if (pickedFile != null) {
      setState(() {
        profileImageFile = File(pickedFile.path);
      });

      // Create MultipartRequest to post the image
      final uri = Uri.parse(
        "${AuthService.baseUrl}/user-update-image",
      ); // Replace with your API endpoint
      var request = http.MultipartRequest(
        'POST',
        uri,
      )..files.add(await http.MultipartFile.fromPath('image', pickedFile.path));

      try {
        // Send the request using your authPost method
        final response = await AuthService().authPost(
          'user-update-image', // Replace with actual endpoint
          isMultipart: true,
          body: request, // Pass the MultipartRequest as the body
        );

        if (response.statusCode == 200) {
          final prefs = await SharedPreferences.getInstance();

          prefs.setString('user_info', response.body);

          print(response.body);

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile image updated successfully!'),
            ),
          );
        } else {
          // Handle error
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to update profile image')),
          );
        }
      } catch (e) {
        // Handle any error (e.g., network issues)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('An error occurred while uploading the image.'),
          ),
        );
      }
    }
  }

  void _showEmailVerificationDialog() {
    final codeController = TextEditingController();
    int secondsRemaining = 60;
    bool canResend = false;
    Timer? timer;

    void startTimer(Function setDialogState) {
      timer?.cancel();
      secondsRemaining = 60;
      canResend = false;
      timer = Timer.periodic(const Duration(seconds: 1), (t) {
        if (secondsRemaining > 0) {
          secondsRemaining--;
          setDialogState(() {});
        } else {
          t.cancel();
          canResend = true;
          setDialogState(() {});
        }
      });
    }

    void sendConfirmationCode() async {
      try {
        final response = await AuthService().authPost(
          "verify-email",
          body: jsonEncode({'email': userEmail, 'code': codeController.text}),
        );
        if (response.statusCode == 201) {
          setState(() => isEmailVerified = true);
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Email verified successfully!')),
          );
        } else {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Invalid code!')));
        }
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }

    Future<void> sendVerificationRequest(Function setDialogState) async {
      try {
        // 🔹 Replace with your API endpoint
        final response = await AuthService().authGet('send-verification-code');
        if (response.statusCode == 201) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Verification code sent to your email'),
            ),
          );

          startTimer(setDialogState); // start countdown
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to send verification code')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }

    showDialog(
      context: context,
      barrierDismissible: true, // ✅ can close by clicking outside
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            // Start by sending code once on open
            if (timer == null) sendVerificationRequest(setDialogState);

            return AlertDialog(
              title: const Text('Email Verification'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Enter the 6-digit code sent to your email.'),
                  const SizedBox(height: 12),
                  TextField(
                    controller: codeController,
                    maxLength: 6,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Verification Code',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    canResend
                        ? 'You can resend now.'
                        : 'Resend in ${secondsRemaining}s',
                    style: TextStyle(
                      color: canResend ? Colors.green : Colors.grey,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: canResend
                            ? () async {
                                await sendVerificationRequest(setDialogState);
                              }
                            : null,
                        child: Text(
                          'Resend',
                          style: TextStyle(
                            color: canResend ? Colors.blue : Colors.grey,
                          ),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () => sendConfirmationCode,
                        child: const Text('Confirm'),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    ).then((_) {
      timer?.cancel();
      timer = null;
    });
  }

  void _toggleVerification(String type) {
    setState(() {
      if (type == 'email') {
        isEmailVerified = !isEmailVerified;
      } else {
        isPhoneVerified = !isPhoneVerified;
      }
    });
  }

  void _toggleNotifications(bool value) {
    setState(() => notificationsEnabled = value);
  }

  void _changePassword() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      if (_newPassword != _confirmPassword) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('New passwords do not match')),
        );
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password changed successfully (mocked)')),
      );
    }
  }

  void _addPhoneNumber() {
    if (_phoneController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a phone number')),
      );
      return;
    }
    setState(() {
      userPhone = _phoneController.text.trim();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Phone number added successfully (mocked)')),
    );
  }

  Widget _buildSectionTitle(String title) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    ),
  );

  Widget _buildVerificationRow({
    required String label,
    required String value,
    required bool verified,
    required VoidCallback onPressed,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        leading: Icon(
          verified ? Icons.verified_rounded : Icons.error_outline,
          color: verified ? Colors.green : Colors.red,
        ),
        title: Text(label),
        subtitle: Text(value),
        trailing: ElevatedButton(
          onPressed: onPressed,
          child: Text(verified ? 'Unverify' : 'Verify'),
        ),
      ),
    );
  }

  Widget _buildStatsCard(String label, String value, IconData icon) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        child: Column(
          children: [
            Icon(icon, size: 30, color: Colors.blueAccent),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required String label,
    required bool obscure,
    required VoidCallback onToggle,
    required Function(String?) onSaved,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      obscureText: !obscure,
      decoration: InputDecoration(
        labelText: label,
        suffixIcon: IconButton(
          icon: Icon(obscure ? Icons.visibility : Icons.visibility_off),
          onPressed: onToggle,
        ),
        border: const OutlineInputBorder(),
      ),
      onSaved: onSaved,
      validator: validator,
    );
  }

  @override
  void initState() {
    super.initState();
    _loadUserInfo(); // Call the async method without awaiting it
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
      userEmail = userInfo['email'];

      if (userInfo['phone_verified_at'] != null) {
        isPhoneVerified = true;
      } else {
        isPhoneVerified = false;
      }
      userPhone = userInfo['phone'];
      print("${AuthService.baseHost}${userInfo['image']}");
      defaultProfileImage = "${AuthService.baseHost}${userInfo['image']}";
    });
  }

  @override
  Widget build(BuildContext context) {
    final imageProvider = profileImageFile != null
        ? FileImage(profileImageFile!)
        : NetworkImage(defaultProfileImage ?? '') as ImageProvider;

    return Scaffold(
      appBar: AppBar(title: const Text('User Settings'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Section
            _buildSectionTitle('Profile Image'),
            Center(
              child: Column(
                children: [
                  CircleAvatar(radius: 50, backgroundImage: imageProvider),
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: _pickImage,
                    icon: const Icon(Icons.camera_alt_outlined),
                    label: const Text('Change Image'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Email & Phone Verification
            _buildSectionTitle('Email & Phone Verification'),
            _buildVerificationRow(
              label: 'Email',
              value: userEmail,
              verified: isEmailVerified,
              onPressed: () => _showEmailVerificationDialog(),
            ),

            if (userPhone != null)
              _buildVerificationRow(
                label: 'Phone',
                value: userPhone!,
                verified: isPhoneVerified,
                onPressed: () => _toggleVerification('phone'),
              )
            else
              Card(
                margin: const EdgeInsets.symmetric(vertical: 6),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Add Phone Number',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          labelText: 'Phone Number',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.phone),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton.icon(
                          onPressed: _addPhoneNumber,
                          icon: const Icon(Icons.add_call),
                          label: const Text('Add Phone'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 20),

            // Notifications
            _buildSectionTitle('Notifications'),
            Card(
              child: SwitchListTile(
                title: const Text('Enable Notifications'),
                secondary: const Icon(Icons.notifications_active_outlined),
                value: notificationsEnabled,
                onChanged: _toggleNotifications,
              ),
            ),

            const SizedBox(height: 20),

            // Password Change
            _buildSectionTitle('Change Password'),
            Card(
              elevation: 2,
              margin: const EdgeInsets.only(bottom: 20),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _buildPasswordField(
                        label: 'Old Password',
                        obscure: _showOld,
                        onToggle: () => setState(() => _showOld = !_showOld),
                        onSaved: (val) => _oldPassword = val ?? '',
                        validator: (val) => val == null || val.isEmpty
                            ? 'Enter old password'
                            : null,
                      ),
                      const SizedBox(height: 12),
                      _buildPasswordField(
                        label: 'New Password',
                        obscure: _showNew,
                        onToggle: () => setState(() => _showNew = !_showNew),
                        onSaved: (val) => _newPassword = val ?? '',
                        validator: (val) => val == null || val.length < 6
                            ? 'Min 6 chars'
                            : null,
                      ),
                      const SizedBox(height: 12),
                      _buildPasswordField(
                        label: 'Confirm Password',
                        obscure: _showConfirm,
                        onToggle: () =>
                            setState(() => _showConfirm = !_showConfirm),
                        onSaved: (val) => _confirmPassword = val ?? '',
                        validator: (val) => val == null || val.isEmpty
                            ? 'Confirm password'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.lock_reset_rounded),
                        onPressed: _changePassword,
                        label: const Text('Change Password'),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Statistics
            _buildSectionTitle('Statistics'),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 1.3,
              children: [
                _buildStatsCard(
                  'Total Published Ads',
                  totalAds.toString(),
                  Icons.ads_click,
                ),
                _buildStatsCard(
                  'Star Ratings',
                  '$averageRating ★',
                  Icons.star_rate_rounded,
                ),
                _buildStatsCard(
                  'Total Income',
                  '\$${totalIncome.toStringAsFixed(2)}',
                  Icons.attach_money,
                ),
                _buildStatsCard(
                  'Total Orders',
                  totalOrders.toString(),
                  Icons.shopping_cart_outlined,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
