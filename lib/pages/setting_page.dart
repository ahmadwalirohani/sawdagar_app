import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:afghan_bazar/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserSettingsPage extends StatefulWidget {
  const UserSettingsPage({Key? key}) : super(key: key);

  @override
  State<UserSettingsPage> createState() => _UserSettingsPageState();
}

class _UserSettingsPageState extends State<UserSettingsPage>
    with SingleTickerProviderStateMixin {
  // Existing variables remain the same
  bool isEmailVerified = false;
  bool isPhoneVerified = false;
  bool notificationsEnabled = true;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String _phoneVerificationId = "";
  bool _otpSent = false;
  final TextEditingController _otpController = TextEditingController();
  bool _loadingPhone = false;

  String userEmail = "user@example.com";
  String? userPhone;
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

  // New animation variables
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();

    // Initialize animations
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _colorAnimation = ColorTween(
      begin: Colors.blue.withOpacity(0.1),
      end: Colors.transparent,
    ).animate(_animationController);

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // Keep all your existing methods (_pickImage, _showEmailVerificationDialog, etc.)
  // They remain exactly the same as in your original code

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

        if (response.statusCode == 200) {
          setState(() => isEmailVerified = true);
          final prefs = await SharedPreferences.getInstance();

          prefs.setString('user_info', response.body);
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
                        onPressed: () => sendConfirmationCode(),
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

  Future<void> _sendPhoneOTP(String phone) async {
    setState(() => _loadingPhone = true);

    await _auth.verifyPhoneNumber(
      phoneNumber: phone,
      timeout: const Duration(seconds: 60),
      verificationCompleted: (PhoneAuthCredential credential) async {
        await _auth.signInWithCredential(credential);
        await _verifyPhoneWithServer();
      },
      verificationFailed: (FirebaseAuthException e) {
        setState(() => _loadingPhone = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: ${e.message}")));
      },
      codeSent: (String verificationId, int? resendToken) {
        setState(() {
          _phoneVerificationId = verificationId;
          _otpSent = true;
          _loadingPhone = false;
        });

        _showPhoneOTPDialog();

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("OTP sent")));
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        _phoneVerificationId = verificationId;
      },
    );
  }

  Future<void> _verifyOTP() async {
    setState(() => _loadingPhone = true);

    final credential = PhoneAuthProvider.credential(
      verificationId: _phoneVerificationId,
      smsCode: _otpController.text.trim(),
    );

    try {
      await _auth.signInWithCredential(credential);
      await _verifyPhoneWithServer(); // Send token to Laravel
    } catch (e) {
      setState(() => _loadingPhone = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Invalid OTP")));
    }
  }

  Future<void> _verifyPhoneWithServer() async {
    User? user = _auth.currentUser;
    String idToken = await user!.getIdToken() ?? '';

    final response = await AuthService().authPost(
      'verify-phone',
      body: jsonEncode({'code': idToken, 'phone': userPhone}),
    );

    if (response.statusCode == 200) {
      final prefs = await SharedPreferences.getInstance();
      prefs.setString('user_info', response.body);

      setState(() {
        isPhoneVerified = true;
        _loadingPhone = false;
        _otpSent = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Phone verified successfully!")),
      );
    } else {
      setState(() => _loadingPhone = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to verify with server")),
      );
    }
  }

  void _changePassword() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      if (_newPassword != _confirmPassword) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('New passwords do not match')),
        );
        return;
      }
      final response = await AuthService().authPost(
        'update-user-password',
        body: jsonEncode({
          'old_password': _oldPassword,
          'new_password': _newPassword,
          'confirm_password': _confirmPassword,
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password changed successfully (mocked)'),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to update password")),
        );
      }
    }
  }

  void _addPhoneNumber() async {
    if (_phoneController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a phone number')),
      );
      return;
    }

    final phone = _phoneController.text.trim();

    try {
      final response = await AuthService().authPost(
        "update-phone",
        body: jsonEncode({'phone': phone}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        setState(() => userPhone = phone);

        final prefs = await SharedPreferences.getInstance();
        prefs.setString('user_info', response.body);
      } else {
        print(response.body);
      }
    } catch (e) {
      print(e);
    }
  }

  void _showPhoneOTPDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Verify Phone Number"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Enter the OTP sent to your phone"),
              const SizedBox(height: 12),
              TextField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "OTP",
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: _loadingPhone
                  ? null
                  : () async {
                      await _verifyOTP();

                      Navigator.pop(context);
                    },
              child: _loadingPhone
                  ? const CircularProgressIndicator()
                  : const Text("Verify"),
            ),
          ],
        );
      },
    );
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

      defaultProfileImage = "${AuthService.baseHost}/${userInfo['image']}";
    });
  }

  Widget _buildGradientBackground() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF0053E2).withOpacity(0.1),
            const Color(0xFFFFC220).withOpacity(0.05),
            Theme.of(context).colorScheme.background,
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final imageProvider = profileImageFile != null
        ? FileImage(profileImageFile!)
        : NetworkImage(defaultProfileImage ?? '') as ImageProvider;

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            margin: const EdgeInsets.only(bottom: 30, top: 20),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Background Blob
                Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(
                          0xFF0053E2,
                        ).withOpacity(isDark ? 0.2 : 0.15),
                        const Color(
                          0xFFFFC220,
                        ).withOpacity(isDark ? 0.1 : 0.08),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),

                // Profile Image with gradient border
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0053E2), Color(0xFFFFC220)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(
                          0xFF0053E2,
                        ).withOpacity(isDark ? 0.4 : 0.3),
                        blurRadius: 15,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(3.0),
                    child: CircleAvatar(
                      radius: 56,
                      backgroundImage: imageProvider,
                      child: Material(
                        shape: const CircleBorder(),
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(60),
                          onTap: _pickImage,
                        ),
                      ),
                    ),
                  ),
                ),

                // Edit button
                Positioned(
                  bottom: 5,
                  right: 100,
                  child: FloatingActionButton.small(
                    onPressed: _pickImage,
                    backgroundColor: theme.colorScheme.surface,
                    child: Icon(
                      Icons.camera_alt,
                      color: const Color(0xFF0053E2),
                    ),
                    elevation: 3,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF0053E2).withOpacity(isDark ? 0.2 : 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 20, color: const Color(0xFF0053E2)),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerificationCard({
    required String title,
    required String subtitle,
    required bool isVerified,
    required VoidCallback onTap,
    required IconData icon,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isVerified
            ? const Color(0xFF4CAF50).withOpacity(isDark ? 0.2 : 0.1)
            : const Color(0xFFFFC220).withOpacity(isDark ? 0.2 : 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isVerified
              ? const Color(0xFF4CAF50).withOpacity(0.3)
              : const Color(0xFFFFC220).withOpacity(0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isVerified
                ? const Color(0xFF4CAF50).withOpacity(isDark ? 0.3 : 0.2)
                : const Color(0xFFFFC220).withOpacity(isDark ? 0.3 : 0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: isVerified
                ? const Color(0xFF4CAF50)
                : const Color(0xFFFFC220),
            size: 24,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
            fontSize: 12,
          ),
        ),
        trailing: Container(
          height: 35,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isVerified
                  ? [const Color(0xFF4CAF50), const Color(0xFF66BB6A)]
                  : [const Color(0xFFFFC220), const Color(0xFFFF9800)],
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: ElevatedButton(
            onPressed: onTap,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: Text(
              isVerified ? 'VERIFIED' : 'VERIFY',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatsCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      margin: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withOpacity(isDark ? 0.8 : 0.7),
            color.withOpacity(isDark ? 0.4 : 0.3),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(isDark ? 0.4 : 0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withOpacity(0.9),
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        obscureText: obscure,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
          filled: true,
          fillColor: isDark ? theme.colorScheme.surface : Colors.grey.shade50,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(
              color: const Color(0xFF0053E2).withOpacity(0.1),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: Color(0xFF0053E2)),
          ),
          suffixIcon: IconButton(
            icon: Icon(
              obscure ? Icons.visibility : Icons.visibility_off,
              color: theme.colorScheme.onSurface.withOpacity(0.5),
            ),
            onPressed: onToggle,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
        ),
        style: TextStyle(fontSize: 16, color: theme.colorScheme.onSurface),
        onSaved: onSaved,
        validator: validator,
      ),
    );
  }

  Widget _buildAddPhoneCard() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF0053E2).withOpacity(isDark ? 0.15 : 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF0053E2).withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(
                      0xFF0053E2,
                    ).withOpacity(isDark ? 0.3 : 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.phone,
                    color: Color(0xFF0053E2),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Add Phone Number',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF0053E2),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              style: TextStyle(color: theme.colorScheme.onSurface),
              decoration: InputDecoration(
                hintText: 'Enter your phone number',
                hintStyle: TextStyle(
                  color: theme.colorScheme.onSurface.withOpacity(0.5),
                ),
                filled: true,
                fillColor: isDark ? theme.colorScheme.surface : Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: const Color(0xFF0053E2).withOpacity(0.1),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF0053E2)),
                ),
                prefixIcon: Icon(
                  Icons.phone_iphone,
                  color: theme.colorScheme.onSurface.withOpacity(0.5),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: Container(
                height: 40,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0053E2), Color(0xFF1E88E5)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: ElevatedButton.icon(
                  onPressed: _addPhoneNumber,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  icon: const Icon(Icons.add, size: 18, color: Colors.white),
                  label: const Text(
                    'ADD PHONE',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
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
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Settings',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: theme.colorScheme.onSurface,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Stack(
            children: [
              _buildGradientBackground(),
              SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(child: _buildProfileHeader()),

                    // Verification Section
                    _buildSectionHeader(
                      'Account Verification',
                      Icons.verified_user_rounded,
                    ),
                    _buildVerificationCard(
                      title: 'Email Address',
                      subtitle: userEmail,
                      isVerified: isEmailVerified,
                      onTap: _showEmailVerificationDialog,
                      icon: Icons.email_rounded,
                    ),

                    if (userPhone != null)
                      _buildVerificationCard(
                        title: 'Phone Number',
                        subtitle: userPhone!,
                        isVerified: isPhoneVerified,
                        onTap: () => _sendPhoneOTP(userPhone ?? ''),
                        icon: Icons.phone_iphone_rounded,
                      )
                    else
                      _buildAddPhoneCard(),

                    const SizedBox(height: 10),

                    // Notifications
                    _buildSectionHeader('Preferences', Icons.settings_rounded),
                    Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFF0053E2,
                            ).withOpacity(isDark ? 0.2 : 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.notifications_active,
                            color: const Color(0xFF0053E2),
                          ),
                        ),
                        title: Text(
                          'Push Notifications',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        subtitle: Text(
                          'Receive updates and alerts',
                          style: TextStyle(
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                        trailing: Transform.scale(
                          scale: 1.2,
                          child: Switch(
                            value: notificationsEnabled,
                            onChanged: _toggleNotifications,
                            activeColor: const Color(0xFF0053E2),
                            activeTrackColor: const Color(
                              0xFF0053E2,
                            ).withOpacity(0.5),
                          ),
                        ),
                      ),
                    ),

                    // Password Change
                    _buildSectionHeader('Security', Icons.security_rounded),
                    Container(
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              _buildPasswordField(
                                label: 'Current Password',
                                obscure: _showOld,
                                onToggle: () =>
                                    setState(() => _showOld = !_showOld),
                                onSaved: (val) => _oldPassword = val ?? '',
                                validator: (val) => val == null || val.isEmpty
                                    ? 'Enter current password'
                                    : null,
                              ),
                              _buildPasswordField(
                                label: 'New Password',
                                obscure: _showNew,
                                onToggle: () =>
                                    setState(() => _showNew = !_showNew),
                                onSaved: (val) => _newPassword = val ?? '',
                                validator: (val) =>
                                    val == null || val.length < 6
                                    ? 'Minimum 6 characters required'
                                    : null,
                              ),
                              _buildPasswordField(
                                label: 'Confirm New Password',
                                obscure: _showConfirm,
                                onToggle: () => setState(
                                  () => _showConfirm = !_showConfirm,
                                ),
                                onSaved: (val) => _confirmPassword = val ?? '',
                                validator: (val) => val == null || val.isEmpty
                                    ? 'Please confirm your password'
                                    : null,
                              ),
                              const SizedBox(height: 16),
                              Container(
                                width: double.infinity,
                                height: 50,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF0053E2),
                                      Color(0xFF1E88E5),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: ElevatedButton.icon(
                                  onPressed: _changePassword,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                  ),
                                  icon: const Icon(
                                    Icons.lock_reset,
                                    color: Colors.white,
                                  ),
                                  label: const Text(
                                    'UPDATE PASSWORD',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Statistics
                    _buildSectionHeader(
                      'Your Statistics',
                      Icons.analytics_rounded,
                    ),
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      childAspectRatio: 0.85,
                      padding: const EdgeInsets.only(bottom: 30),
                      children: [
                        _buildStatsCard(
                          'Published Ads',
                          totalAds.toString(),
                          Icons.ads_click,
                          const Color(0xFF0053E2), // Blue
                        ),
                        _buildStatsCard(
                          'Average Rating',
                          '$averageRating ★',
                          Icons.star_rate_rounded,
                          const Color(0xFFFFC220), // Yellow/Orange
                        ),
                        _buildStatsCard(
                          'Total Income',
                          '\$${totalIncome.toStringAsFixed(0)}',
                          Icons.attach_money_rounded,
                          const Color(0xFF4CAF50), // Green
                        ),
                        _buildStatsCard(
                          'Total Orders',
                          totalOrders.toString(),
                          Icons.shopping_cart_rounded,
                          const Color(0xFF9C27B0), // Purple
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // Include all your existing methods here (_pickImage, _showEmailVerificationDialog,
  // _sendPhoneOTP, _verifyOTP, _changePassword, _addPhoneNumber, _loadUserInfo, etc.)
  // They remain exactly the same as in your original code
}
