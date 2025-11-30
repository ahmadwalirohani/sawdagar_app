import 'package:afghan_bazar/pages/home.dart';
import 'package:afghan_bazar/utils/next_screen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class IntroPage extends StatefulWidget {
  const IntroPage({super.key});

  @override
  State<IntroPage> createState() => _IntroPageState();
}

class _IntroPageState extends State<IntroPage> {
  final PageController _controller = PageController();
  bool isLastPage = false;

  final List<Map<String, String>> pages = [
    {
      'title': 'Your Ultimate Online Marketplace',
      'subtitle':
          'Shop a wide range of products at great prices—all in one place',
      'image': 'assets/images/slide1.png',
    },
    {
      'title': 'Easy Shopping',
      'subtitle': 'Browse and buy with just a few taps, anytime, anywhere',
      'image': 'assets/images/slide1.png',
    },
    {
      'title': 'Quick Delivery & Support',
      'subtitle':
          'Get your orders delivered quickly and enjoy top-notch support',
      'image': 'assets/images/slide1.png',
    },
  ];

  // Brand Colors
  final Color brandBlue = Color(0xFF0053E2);
  final Color brandYellow = Color(0xFFFFC220);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFF8FAFF), // Light blue white
              Color(0xFFF0F5FF), // Very light blue
              Colors.white,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Abstract Background Elements
              _buildAbstractBackground(),

              Column(
                children: [
                  Expanded(
                    child: PageView.builder(
                      controller: _controller,
                      onPageChanged: (index) {
                        setState(() {
                          isLastPage = index == pages.length - 1;
                        });
                      },
                      itemCount: pages.length,
                      itemBuilder: (context, index) {
                        return _buildPageContent(pages[index], index);
                      },
                    ),
                  ),

                  // Indicators and Button
                  _buildBottomSection(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAbstractBackground() {
    return Stack(
      children: [
        // Large Blue Circle
        Positioned(
          top: -100,
          right: -80,
          child: Container(
            width: 280,
            height: 280,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [brandBlue.withOpacity(0.15), Colors.transparent],
                stops: [0.1, 0.8],
              ),
            ),
          ),
        ),

        // Yellow Circle
        Positioned(
          bottom: -60,
          left: -40,
          child: Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [brandYellow.withOpacity(0.2), Colors.transparent],
                stops: [0.1, 0.8],
              ),
            ),
          ),
        ),

        // Geometric Blue Square
        Positioned(
          top: 120,
          left: 30,
          child: Transform.rotate(
            angle: 0.3,
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: brandBlue.withOpacity(0.1),
                border: Border.all(
                  color: brandBlue.withOpacity(0.3),
                  width: 1.5,
                ),
              ),
            ),
          ),
        ),

        // Small Yellow Circle
        Positioned(
          bottom: 200,
          right: 40,
          child: Container(
            width: 35,
            height: 35,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: brandYellow.withOpacity(0.15),
              border: Border.all(
                color: brandYellow.withOpacity(0.4),
                width: 1.5,
              ),
            ),
          ),
        ),

        // Blue Triangle
        Positioned(
          top: 300,
          right: 50,
          child: CustomPaint(
            size: Size(40, 40),
            painter: _TrianglePainter(color: brandBlue.withOpacity(0.1)),
          ),
        ),
      ],
    );
  }

  Widget _buildPageContent(Map<String, String> page, int index) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animated Image Container
          _buildAnimatedImageContainer(page['image']!, index),

          SizedBox(height: 50),

          // Title with brand colors
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                height: 1.3,
                letterSpacing: -0.5,
                color: Color(0xFF1A1D1F), // Dark text
              ),
              children: [
                TextSpan(
                  text: page['title']!.tr().substring(
                    0,
                    page['title']!.indexOf(' '),
                  ),
                ),
                TextSpan(
                  text: page['title']!.tr().substring(
                    page['title']!.indexOf(' '),
                  ),
                  style: TextStyle(
                    foreground: Paint()
                      ..shader = LinearGradient(
                        colors: [brandBlue, brandBlue.withOpacity(0.8)],
                      ).createShader(Rect.fromLTWH(0, 0, 200, 20)),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 20),

          // Subtitle
          Text(
            page['subtitle']!.tr(),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF6F767E),
              fontWeight: FontWeight.w400,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedImageContainer(String imagePath, int index) {
    return Container(
      height: 300,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background glow with brand color
          Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  _getPageAccentColor(index).withOpacity(0.15),
                  Colors.transparent,
                ],
                stops: [0.1, 0.8],
              ),
            ),
          ),

          // Main image with abstract container
          Container(
            width: 220,
            height: 220,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: Offset(0, 10),
                ),
                BoxShadow(
                  color: _getPageAccentColor(index).withOpacity(0.1),
                  blurRadius: 30,
                  offset: Offset(0, 15),
                ),
              ],
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(25),
              child: Image.asset(imagePath, fit: BoxFit.cover),
            ),
          ),

          // Floating brand elements
          Positioned(
            top: 40,
            right: 40,
            child: Container(
              width: 25,
              height: 25,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: brandYellow,
                boxShadow: [
                  BoxShadow(
                    color: brandYellow.withOpacity(0.4),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
            ),
          ),

          Positioned(
            bottom: 50,
            left: 40,
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: brandBlue,
                boxShadow: [
                  BoxShadow(
                    color: brandBlue.withOpacity(0.4),
                    blurRadius: 8,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSection() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 32, vertical: 20),
      child: Column(
        children: [
          // Custom Page Indicator
          SmoothPageIndicator(
            controller: _controller,
            count: pages.length,
            effect: ExpandingDotsEffect(
              dotColor: Color(0xFFE0E5F0),
              activeDotColor: brandBlue,
              dotHeight: 8,
              dotWidth: 8,
              expansionFactor: 3,
              spacing: 6,
            ),
          ),

          SizedBox(height: 30),

          // Animated Button with brand colors
          Container(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: isLastPage ? brandBlue : Colors.transparent,
                foregroundColor: isLastPage ? Colors.white : brandBlue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: isLastPage
                      ? BorderSide.none
                      : BorderSide(color: brandBlue.withOpacity(0.3), width: 2),
                ),
                elevation: isLastPage ? 4 : 0,
                shadowColor: isLastPage
                    ? brandBlue.withOpacity(0.3)
                    : Colors.transparent,
              ),
              onPressed: () {
                if (isLastPage) {
                  nextScreenReplace(context, HomePage());
                } else {
                  _controller.nextPage(
                    duration: Duration(milliseconds: 600),
                    curve: Curves.easeInOutCubic,
                  );
                }
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (isLastPage) ...[
                    Icon(Icons.shopping_bag_outlined, size: 20),
                    SizedBox(width: 8),
                  ],
                  Text(
                    isLastPage ? 'Start Shopping' : 'Continue',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  if (!isLastPage) ...[
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward_rounded, size: 20),
                  ],
                ],
              ),
            ),
          ),

          SizedBox(height: 20),

          // Skip button for first pages
          if (!isLastPage)
            TextButton(
              onPressed: () {
                nextScreenReplace(context, HomePage());
              },
              child: Text(
                'Skip Introduction',
                style: TextStyle(
                  color: Color(0xFF6F767E),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Color _getPageAccentColor(int index) {
    switch (index) {
      case 0:
        return brandBlue;
      case 1:
        return brandYellow;
      case 2:
        return brandBlue;
      default:
        return brandBlue;
    }
  }
}

class _TrianglePainter extends CustomPainter {
  final Color color;

  _TrianglePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(size.width / 2, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
