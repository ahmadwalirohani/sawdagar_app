import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpSupportPage extends StatefulWidget {
  const HelpSupportPage({super.key});

  @override
  State<HelpSupportPage> createState() => _HelpSupportPageState();
}

class _HelpSupportPageState extends State<HelpSupportPage> {
  final TextEditingController _messageController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 180,
            pinned: true,
            backgroundColor: Colors.transparent,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                "Help & Support",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              centerTitle: true,
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF0053E2), Color(0xFF0039A6)],
                  ),
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Background pattern
                    Opacity(
                      opacity: 0.1,
                      child: Icon(
                        Icons.help_outline,
                        size: 150,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Column(
              children: [
                const SizedBox(height: 20),

                // Quick Help Section
                _buildQuickHelpSection(),

                // Contact Methods
                _buildContactMethods(),

                // Send Message Section
                _buildMessageSection(),

                // Legal Section
                _buildLegalSection(),

                // Social Media
                _buildSocialMediaSection(),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickHelpSection() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF0053E2).withOpacity(isDark ? 0.15 : 0.08),
            const Color(0xFFFFC220).withOpacity(isDark ? 0.1 : 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF0053E2).withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.help_outline,
                color: const Color(0xFF0053E2),
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                "Quick Help",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _helpChip("How to post an ad?", Icons.sell),
              _helpChip("Payment issues", Icons.payment),
              _helpChip("Account settings", Icons.settings),
              _helpChip("Shipping info", Icons.local_shipping),
              _helpChip("Return policy", Icons.assignment_return),
              _helpChip("Security tips", Icons.security),
            ],
          ),
        ],
      ),
    );
  }

  Widget _helpChip(String text, IconData icon) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ActionChip(
      avatar: Icon(icon, size: 16, color: const Color(0xFF0053E2)),
      label: Text(
        text,
        style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface),
      ),
      backgroundColor: isDark ? theme.colorScheme.surface : Colors.white,
      elevation: 2,
      onPressed: () {
        _showHelpDialog(text);
      },
    );
  }

  Widget _buildContactMethods() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
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
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.contact_support,
                color: const Color(0xFF0053E2),
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                "Contact Methods",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            children: [
              _contactMethod(
                Icons.phone,
                "Call Us",
                "+93 123 456 789",
                const Color(0xFF4CAF50), // Green
                () => _launchUrl('tel:+93123456789'),
              ),
              _contactMethod(
                Icons.email,
                "Email Us",
                "support@afghanbazar.com",
                const Color(0xFF0053E2), // Blue
                () => _launchUrl('mailto:support@afghanbazar.com'),
              ),
              _contactMethod(
                Icons.chat,
                "Live Chat",
                "24/7 Available",
                const Color(0xFFFFC220), // Yellow/Orange
                () => _startLiveChat(),
              ),
              _contactMethod(
                Icons.location_on,
                "Visit Us",
                "Kabul, Afghanistan",
                const Color(0xFFF44336), // Red
                () => _showLocation(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _contactMethod(
    IconData icon,
    String title,
    String subtitle,
    Color color,
    Function onTap,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      color: theme.colorScheme.surface,
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: () => onTap(),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withOpacity(isDark ? 0.2 : 0.1),
                color.withOpacity(isDark ? 0.1 : 0.05),
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(isDark ? 0.3 : 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: theme.colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMessageSection() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.message, color: const Color(0xFF0053E2), size: 24),
              const SizedBox(width: 8),
              Text(
                "Send us a Message",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _messageController,
                  maxLines: 5,
                  style: TextStyle(color: theme.colorScheme.onSurface),
                  decoration: InputDecoration(
                    hintText: "Describe your issue or question...",
                    hintStyle: TextStyle(
                      color: theme.colorScheme.onSurface.withOpacity(0.5),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: theme.colorScheme.outline.withOpacity(0.5),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF0053E2)),
                    ),
                    filled: true,
                    fillColor: isDark
                        ? theme.colorScheme.surface.withOpacity(0.5)
                        : Colors.grey.shade50,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your message';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _submitMessage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0053E2),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.send, size: 20),
                        SizedBox(width: 8),
                        Text(
                          "Send Message",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegalSection() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.gavel, color: const Color(0xFF0053E2), size: 24),
              const SizedBox(width: 8),
              Text(
                "Legal & Policies",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _legalItem(
            "Terms & Conditions",
            Icons.description,
            const Color(0xFFFFC220), // Yellow/Orange
            () => _showTermsAndConditions(),
          ),
          _legalItem(
            "Privacy Policy",
            Icons.privacy_tip,
            const Color(0xFF4CAF50), // Green
            () => _showPrivacyPolicy(),
          ),
          _legalItem(
            "Cookie Policy",
            Icons.cookie,
            const Color(0xFF795548), // Brown
            () => _showCookiePolicy(),
          ),
          _legalItem(
            "Return Policy",
            Icons.assignment_return,
            const Color(0xFF9C27B0), // Purple
            () => _showReturnPolicy(),
          ),
        ],
      ),
    );
  }

  Widget _legalItem(String title, IconData icon, Color color, Function onTap) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: theme.colorScheme.surface,
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(isDark ? 0.2 : 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: theme.colorScheme.onSurface,
          ),
        ),
        trailing: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: theme.colorScheme.onSurface.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.arrow_forward_ios,
            size: 14,
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
        onTap: () => onTap(),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildSocialMediaSection() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF0053E2).withOpacity(isDark ? 0.15 : 0.08),
            const Color(0xFFFFC220).withOpacity(isDark ? 0.1 : 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF0053E2).withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.thumb_up, color: const Color(0xFF0053E2), size: 24),
              const SizedBox(width: 8),
              Text(
                "Follow Us",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            "Stay connected with us on social media",
            style: TextStyle(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _socialMediaIcon(
                Icons.facebook,
                "Facebook",
                const Color(0xFF1877F2), // Facebook blue
                () => _launchUrl('https://facebook.com/afghanbazar'),
              ),
              _socialMediaIcon(
                Icons.camera_alt,
                "Instagram",
                const Color(0xFFE4405F), // Instagram pink
                () => _launchUrl('https://instagram.com/afghanbazar'),
              ),
              _socialMediaIcon(
                Icons.one_x_mobiledata,
                "Twitter",
                const Color(0xFF1DA1F2), // Twitter blue
                () => _launchUrl('https://twitter.com/afghanbazar'),
              ),
              _socialMediaIcon(
                Icons.telegram,
                "Telegram",
                const Color(0xFF0088CC), // Telegram blue
                () => _launchUrl('https://t.me/afghanbazar'),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _socialMediaIcon(
                Icons.youtube_searched_for,
                "YouTube",
                const Color(0xFFFF0000), // YouTube red
                () => _launchUrl('https://youtube.com/afghanbazar'),
              ),
              _socialMediaIcon(
                Icons.linked_camera,
                "LinkedIn",
                const Color(0xFF0A66C2), // LinkedIn blue
                () => _launchUrl('https://linkedin.com/company/afghanbazar'),
              ),
              _socialMediaIcon(
                Icons.chat,
                "WhatsApp",
                const Color(0xFF25D366), // WhatsApp green
                () => _launchUrl('https://wa.me/93123456789'),
              ),
              _socialMediaIcon(
                Icons.email,
                "Email",
                const Color(0xFF0053E2), // Your brand blue
                () => _launchUrl('mailto:info@afghanbazar.com'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _socialMediaIcon(
    IconData icon,
    String label,
    Color color,
    Function onTap,
  ) {
    final theme = Theme.of(context);

    return Column(
      children: [
        InkWell(
          onTap: () => onTap(),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.4),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  // Helper Methods
  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not launch $url'),
          backgroundColor: Colors.red.shade500,
        ),
      );
    }
  }

  void _submitMessage() {
    if (_formKey.currentState!.validate()) {
      // Simulate sending message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Message sent successfully!'),
          backgroundColor: Colors.green.shade500,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      _messageController.clear();
    }
  }

  void _showHelpDialog(String topic) {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.colorScheme.surface,
        title: Text(
          topic,
          style: TextStyle(color: theme.colorScheme.onSurface),
        ),
        content: Text(
          "Help content for $topic would be displayed here.",
          style: TextStyle(color: theme.colorScheme.onSurface),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "Close",
              style: TextStyle(color: theme.colorScheme.primary),
            ),
          ),
        ],
      ),
    );
  }

  void _startLiveChat() {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.colorScheme.surface,
        title: Text(
          "Live Chat",
          style: TextStyle(color: theme.colorScheme.onSurface),
        ),
        content: Text(
          "Connecting you with our support team...",
          style: TextStyle(color: theme.colorScheme.onSurface),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "Cancel",
              style: TextStyle(color: theme.colorScheme.primary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Live chat started!")),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0053E2),
            ),
            child: const Text("Start Chat"),
          ),
        ],
      ),
    );
  }

  void _showLocation() {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.colorScheme.surface,
        title: Text(
          "Our Location",
          style: TextStyle(color: theme.colorScheme.onSurface),
        ),
        content: Text(
          "Kabul, Afghanistan\n\nWe're located in the heart of the city.",
          style: TextStyle(color: theme.colorScheme.onSurface),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "Close",
              style: TextStyle(color: theme.colorScheme.primary),
            ),
          ),
          TextButton(
            onPressed: () =>
                _launchUrl('https://maps.google.com/?q=Kabul,Afghanistan'),
            child: Text(
              "Open Map",
              style: TextStyle(color: const Color(0xFF0053E2)),
            ),
          ),
        ],
      ),
    );
  }

  void _showTermsAndConditions() {
    _showLegalDialog(
      "Terms & Conditions",
      "Your terms and conditions content here...",
    );
  }

  void _showPrivacyPolicy() {
    _showLegalDialog("Privacy Policy", "Your privacy policy content here...");
  }

  void _showCookiePolicy() {
    _showLegalDialog("Cookie Policy", "Your cookie policy content here...");
  }

  void _showReturnPolicy() {
    _showLegalDialog("Return Policy", "Your return policy content here...");
  }

  void _showLegalDialog(String title, String content) {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.colorScheme.surface,
        title: Text(
          title,
          style: TextStyle(color: theme.colorScheme.onSurface),
        ),
        content: SingleChildScrollView(
          child: Text(
            content,
            style: TextStyle(color: theme.colorScheme.onSurface),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "Close",
              style: TextStyle(color: theme.colorScheme.primary),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }
}
