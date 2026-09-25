import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

void main() {
  runApp(const StudentCardApp());
}

class StudentCardApp extends StatelessWidget {
  const StudentCardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Student Identity Card',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF07090E),
      ),
      home: const StudentCardScreen(),
    );
  }
}

class StudentCardScreen extends StatefulWidget {
  const StudentCardScreen({super.key});

  @override
  State<StudentCardScreen> createState() => _StudentCardScreenState();
}

class _StudentCardScreenState extends State<StudentCardScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _borderAnimationController;

  @override
  void initState() {
    super.initState();
    // Animation controller driving the continuous perimeter light sweep around the card
    _borderAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(); // Continuously repeat the animation
  }

  @override
  void dispose() {
    _borderAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;

    // Calculate responsive card width
    final cardWidth = math.min(screenWidth * 0.88, 380.0);

    return Scaffold(
      body: Stack(
        children: [
          // Background ambient gradient and glowing accents
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(0, -0.2),
                  radius: 1.2,
                  colors: [
                    Color(0xFF1A1F36),
                    Color(0xFF0D111A),
                    Color(0xFF05070B),
                  ],
                  stops: [0.0, 0.6, 1.0],
                ),
              ),
            ),
          ),

          // Decorative background blur circles for modern depth
          Positioned(
            top: screenHeight * 0.15,
            left: screenWidth * 0.1,
            child: Container(
              width: 180,
              height: 180,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0x1400F2FE),
              ),
            ),
          ),
          Positioned(
            bottom: screenHeight * 0.15,
            right: screenWidth * 0.1,
            child: Container(
              width: 200,
              height: 200,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0x149D4EDD),
              ),
            ),
          ),

          // Main Content Layout
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // =========================================================
                    // PAGE HEADING (OUTSIDE THE CARD AT THE VERY TOP)
                    // =========================================================
                    const _PageHeading(),

                    const SizedBox(height: 20),

                    // =========================================================
                    // STUDENT IDENTITY CARD WITH ANIMATED GLOWING BORDER
                    // =========================================================
                    SizedBox(
                      width: cardWidth,
                      child: AnimatedBuilder(
                        animation: _borderAnimationController,
                        builder: (context, child) {
                          return CustomPaint(
                            painter: GlowingBorderPainter(
                              animationValue: _borderAnimationController.value,
                              borderRadius: 24.0,
                              borderWidth: 3.0,
                              glowColors: const [
                                Color(0xFF00F2FE), // Electric Cyan
                                Color(0xFF3B82F6), // Royal Blue
                                Color(0xFF8B5CF6), // Bright Purple
                                Color(0xFFD946EF), // Neon Magenta/Violet
                                Color(0xFF00F2FE), // Cyan Loop
                              ],
                            ),
                            child: child,
                          );
                        },
                        child: const _StudentCardContent(),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Footer subtext
                    const Text(
                      'Scan card or use NFC for digital verification',
                      style: TextStyle(
                        color: Color(0x59FFFFFF),
                        fontSize: 11,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// ============================================================================
/// PAGE HEADING WIDGET (DISPLAYED OUTSIDE THE CARD AT THE VERY TOP)
/// ============================================================================
class _PageHeading extends StatelessWidget {
  const _PageHeading();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0x1F00F2FE),
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0x4D00F2FE),
                  width: 1,
                ),
              ),
              child: const Icon(
                Icons.school_rounded,
                color: Color(0xFF00F2FE),
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [
                  Color(0xFFFFFFFF),
                  Color(0xFFE2E8F0),
                  Color(0xFF00F2FE),
                ],
                stops: [0.0, 0.7, 1.0],
              ).createShader(bounds),
              child: const Text(
                'STUDENT IDENTITY CARD',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2.2,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Container(
          width: 140,
          height: 2,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(2),
            gradient: const LinearGradient(
              colors: [
                Colors.transparent,
                Color(0xFF00F2FE),
                Color(0xFF8B5CF6),
                Colors.transparent,
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// ============================================================================
/// STUDENT CARD CONTENT WIDGET (GLASSMORPHISM CARD INTERIOR)
/// ============================================================================
class _StudentCardContent extends StatelessWidget {
  const _StudentCardContent();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24.0),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24.0),
            // Glassmorphism dark gradient background
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xF0131B2E), // Deep navy
                Color(0xF00D121F), // Dark slate
                Color(0xF0181128), // Deep purple tint
              ],
              stops: [0.0, 0.5, 1.0],
            ),
            border: Border.all(
              color: const Color(0x14FFFFFF),
              width: 1.0,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x80000000),
                blurRadius: 25,
                spreadRadius: 2,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ---------------------------------------------------------------
              // CARD TOP HEADER: Institution Name & Smart Chip / NFC
              // ---------------------------------------------------------------
              const _CardHeader(),

              const SizedBox(height: 18),

              // ---------------------------------------------------------------
              // STUDENT PHOTO SECTION WITH GLOW RING
              // ---------------------------------------------------------------
              const _StudentPhotoSection(),

              const SizedBox(height: 14),

              // ---------------------------------------------------------------
              // STUDENT NAME & ROLE BADGE
              // ---------------------------------------------------------------
              const Text(
                'Ali Asad',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: 0.5,
                  shadows: [
                    Shadow(
                      color: Color(0x8000F2FE),
                      blurRadius: 10,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 4),

              // Capsule Tag / Status
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0x1F00F2FE),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0x4D00F2FE),
                    width: 1,
                  ),
                ),
                child: const Text(
                  'UNDERGRADUATE STUDENT',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF00F2FE),
                    letterSpacing: 1.2,
                  ),
                ),
              ),

              const SizedBox(height: 18),

              // Subtle Glow Line Divider
              Container(
                height: 1,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      Color(0x26FFFFFF),
                      Color(0x6600F2FE),
                      Color(0x26FFFFFF),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 18),

              // ---------------------------------------------------------------
              // STUDENT DETAILS TILES
              // ---------------------------------------------------------------
              const _StudentDetailsGrid(),

              const SizedBox(height: 20),

              // ---------------------------------------------------------------
              // CARD FOOTER: Barcode & Expiry Date
              // ---------------------------------------------------------------
              const _CardFooter(),
            ],
          ),
        ),
      ),
    );
  }
}

/// ============================================================================
/// CARD HEADER (INSTITUTION NAME, SMART CHIP & NFC ICON)
/// ============================================================================
class _CardHeader extends StatelessWidget {
  const _CardHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Left side: University Title & Subtitle
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: Color(0xFF00F2FE),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                const Text(
                  'METROPOLITAN UNIVERSITY',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                    color: Color(0xE6FFFFFF),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            const Padding(
              padding: EdgeInsets.only(left: 12),
              child: Text(
                'FACULTY OF COMPUTING',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.0,
                  color: Color(0xCC00F2FE),
                ),
              ),
            ),
          ],
        ),

        // Right side: IC Chip graphic & Contactless Icon
        Row(
          children: [
            // Gold Sim/IC Chip Simulation
            Container(
              width: 30,
              height: 22,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFFFFE066),
                    Color(0xFFD4AF37),
                    Color(0xFFA67C1E),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(
                  color: const Color(0xFFFFF5C0),
                  width: 0.5,
                ),
              ),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _ChipLinesPainter(),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.contactless_rounded,
              size: 20,
              color: Color(0x99FFFFFF),
            ),
          ],
        ),
      ],
    );
  }
}

/// Custom painter for microchip grid lines
class _ChipLinesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0x59000000)
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke;

    final path = Path();
    // Center divider lines for IC Chip
    path.moveTo(size.width * 0.5, 0);
    path.lineTo(size.width * 0.5, size.height);
    path.moveTo(0, size.height * 0.5);
    path.lineTo(size.width, size.height * 0.5);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// ============================================================================
/// STUDENT PHOTO SECTION
/// ============================================================================
class _StudentPhotoSection extends StatelessWidget {
  const _StudentPhotoSection();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer ambient glow ring
          Container(
            width: 104,
            height: 104,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Color(0x5900F2FE),
                  blurRadius: 18,
                  spreadRadius: 2,
                ),
                BoxShadow(
                  color: Color(0x408B5CF6),
                  blurRadius: 22,
                  spreadRadius: 4,
                ),
              ],
            ),
          ),

          // Glowing border gradient circle
          Container(
            width: 100,
            height: 100,
            padding: const EdgeInsets.all(3),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: SweepGradient(
                colors: [
                  Color(0xFF00F2FE),
                  Color(0xFF3B82F6),
                  Color(0xFF8B5CF6),
                  Color(0xFFD946EF),
                  Color(0xFF00F2FE),
                ],
              ),
            ),
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF0D121F),
              ),
              child: ClipOval(
                child: Container(
                  width: 90,
                  height: 90,
                  color: const Color(0xFF1E293B),
                  child: Image.asset(
                    'assets/images/main.jpeg',
                    fit: BoxFit.cover,
                    width: 90,
                    height: 90,
                    errorBuilder: (context, error, stackTrace) {
                      final localFile = File(r'C:\Users\adam\Pictures\Camera Roll\main.jpeg');
                      if (localFile.existsSync()) {
                        return Image.file(
                          localFile,
                          fit: BoxFit.cover,
                          width: 90,
                          height: 90,
                        );
                      }
                      return const Icon(
                        Icons.person_rounded,
                        size: 64,
                        color: Color(0xBFFFFFFF),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// ============================================================================
/// STUDENT DETAILS GRID (DEPARTMENT, REG NO, SEMESTER, SECTION, EMAIL)
/// ============================================================================
class _StudentDetailsGrid extends StatelessWidget {
  const _StudentDetailsGrid();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        // Row 1: Department & Registration Number
        Row(
          children: [
            Expanded(
              child: _DetailTile(
                icon: Icons.computer_rounded,
                label: 'DEPARTMENT',
                value: 'Computer Science',
                accentColor: Color(0xFF00F2FE),
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: _DetailTile(
                icon: Icons.badge_outlined,
                label: 'REGISTRATION NO',
                value: 'REG-XXXXXX',
                accentColor: Color(0xFF3B82F6),
              ),
            ),
          ],
        ),

        SizedBox(height: 10),

        // Row 2: Semester & Section
        Row(
          children: [
            Expanded(
              child: _DetailTile(
                icon: Icons.timeline_rounded,
                label: 'SEMESTER',
                value: '5th',
                accentColor: Color(0xFF8B5CF6),
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: _DetailTile(
                icon: Icons.grid_view_rounded,
                label: 'SECTION',
                value: 'A',
                accentColor: Color(0xFFD946EF),
              ),
            ),
          ],
        ),

        SizedBox(height: 10),

        // Row 3: Email Address (Full Width)
        _DetailTile(
          icon: Icons.email_outlined,
          label: 'EMAIL ADDRESS',
          value: 'aliasadu376@gmail.com',
          accentColor: Color(0xFF00F2FE),
          isFullWidth: true,
        ),
      ],
    );
  }
}

/// Reusable individual detail tile
class _DetailTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color accentColor;
  final bool isFullWidth;

  const _DetailTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.accentColor,
    this.isFullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0x0AFFFFFF),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.18),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Icon Container with soft background tint
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              size: 16,
              color: accentColor,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 8.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0x73FFFFFF),
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// ============================================================================
/// CARD FOOTER (BARCODE GRAPHIC & EXPIRY DATE)
/// ============================================================================
class _CardFooter extends StatelessWidget {
  const _CardFooter();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Simulated Barcode graphic
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: List.generate(
                22,
                (index) => Container(
                  margin: const EdgeInsets.only(right: 2),
                  width: (index % 3 == 0) ? 3.0 : ((index % 2 == 0) ? 1.5 : 2.0),
                  height: 22,
                  color: Color(index % 5 == 0 ? 0x4DFFFFFF : 0xBFFFFFFF),
                ),
              ),
            ),
            const SizedBox(height: 3),
            const Text(
              '* REG-XXXXXX *',
              style: TextStyle(
                fontSize: 8,
                letterSpacing: 1.5,
                color: Color(0x66FFFFFF),
                fontFamily: 'monospace',
              ),
            ),
          ],
        ),

        // Expiry date & Security stamp
        const Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'VALID THRU',
              style: TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.w700,
                color: Color(0x66FFFFFF),
                letterSpacing: 0.8,
              ),
            ),
            SizedBox(height: 2),
            Row(
              children: [
                Icon(
                  Icons.verified_user_outlined,
                  size: 11,
                  color: Color(0xFF00F2FE),
                ),
                SizedBox(width: 4),
                Text(
                  '12 / 2026',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Color(0xE600F2FE),
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

/// ============================================================================
/// CUSTOM PAINTER FOR ANIMATED DYNAMIC GLOWING LIGHT BORDER
/// ============================================================================
/// This CustomPainter creates a continuous, liquid-smooth neon laser beam sweeping
/// around the rounded rectangle perimeter of the student card.
///
/// Parameters:
/// - [animationValue]: Value from 0.0 to 1.0 provided by AnimationController.
/// - [borderRadius]: Corner radius matching the card border radius.
/// - [borderWidth]: Stroke width of the glowing border line.
/// - [glowColors]: List of glowing neon colors (Cyan, Blue, Purple, Violet).
class GlowingBorderPainter extends CustomPainter {
  final double animationValue;
  final double borderRadius;
  final double borderWidth;
  final List<Color> glowColors;

  GlowingBorderPainter({
    required this.animationValue,
    required this.borderRadius,
    required this.borderWidth,
    required this.glowColors,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(borderRadius));

    // Rotation angle based on animation controller value (0.0 to 1.0 -> 0 to 2*pi)
    final rotationAngle = animationValue * 2 * math.pi;

    // Create a rotating SweepGradient shader centered at the card center
    final sweepGradientShader = SweepGradient(
      colors: glowColors,
      stops: const [0.0, 0.25, 0.50, 0.75, 1.0],
      transform: GradientRotation(rotationAngle),
    ).createShader(rect);

    // -------------------------------------------------------------------------
    // PASS 1: SUBTLE AMBIENT TRACK BORDER (BACKGROUND GLOW BASE)
    // -------------------------------------------------------------------------
    final trackPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..color = const Color(0x2600F2FE);

    canvas.drawRRect(rrect, trackPaint);

    // -------------------------------------------------------------------------
    // PASS 2: SOFT DEEP OUTSIDE GLOW (NEON AURA BLOOM EFFECT)
    // -------------------------------------------------------------------------
    final auraPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth * 3.5
      ..shader = sweepGradientShader
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14.0);

    canvas.drawRRect(rrect, auraPaint);

    // -------------------------------------------------------------------------
    // PASS 3: MEDIUM INTENSITY GLOW LAYER
    // -------------------------------------------------------------------------
    final glowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth * 1.8
      ..shader = sweepGradientShader
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5.0);

    canvas.drawRRect(rrect, glowPaint);

    // -------------------------------------------------------------------------
    // PASS 4: CRISP HIGH-INTENSITY CORE LIGHT BEAM
    // -------------------------------------------------------------------------
    final corePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth
      ..shader = sweepGradientShader;

    canvas.drawRRect(rrect, corePaint);
  }

  @override
  bool shouldRepaint(covariant GlowingBorderPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
        oldDelegate.borderRadius != borderRadius ||
        oldDelegate.borderWidth != borderWidth;
  }
}
