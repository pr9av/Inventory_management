import 'dart:math';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'scan_hardware_screen.dart';
import '../services/api_service.dart';

// --- Global Theme & Color Tokens for SaaS UI ---
class AppColors {
  static const Color primary = Color(0xFF0F172A); // Slate 900
  static const Color primaryHover = Color(0xFF1E293B);
  static const Color accent = Color(0xFF6366F1); // Indigo 500
  static const Color background = Color(0xFFF8FAFC); // Slate 50
  static const Color cardBg = Colors.white;
  static const Color border = Color(0xFFE2E8F0); // Slate 200
  static const Color textMain = Color(0xFF0F172A);
  static const Color textMuted = Color(0xFF64748B); // Slate 500
  
  // Status Colors
  static const Color statusPendingBg = Color(0xFFF1F5F9);
  static const Color statusPendingText = Color(0xFF475569);
  static const Color statusActiveBg = Color(0xFFEEF2FF);
  static const Color statusActiveText = Color(0xFF4F46E5);
  static const Color statusSuccessBg = Color(0xFFECFDF5);
  static const Color statusSuccessText = Color(0xFF10B981);
  static const Color statusErrorBg = Color(0xFFFEF2F2);
  static const Color statusErrorText = Color(0xFFEF4444);
}

class AppStyles {
  static BoxDecoration cardDecoration = BoxDecoration(
    color: AppColors.cardBg,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: AppColors.border, width: 1),
    boxShadow: [
      BoxShadow(
        color: const Color(0xFF0F172A).withValues(alpha: 0.04),
        blurRadius: 20,
        spreadRadius: 0,
        offset: const Offset(0, 4),
      ),
      BoxShadow(
        color: const Color(0xFF0F172A).withValues(alpha: 0.02),
        blurRadius: 6,
        spreadRadius: 0,
        offset: const Offset(0, 2),
      ),
    ],
  );

  static BoxDecoration activeCardDecoration = boxDecorationWithGlow(AppColors.accent);
  static BoxDecoration successCardDecoration = boxDecorationWithGlow(AppColors.statusSuccessText);

  static BoxDecoration boxDecorationWithGlow(Color glowColor) {
    return BoxDecoration(
      color: AppColors.cardBg,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: glowColor.withValues(alpha: 0.3), width: 1.5),
      boxShadow: [
        BoxShadow(
          color: glowColor.withValues(alpha: 0.08),
          blurRadius: 24,
          spreadRadius: 4,
          offset: const Offset(0, 8),
        ),
      ],
    );
  }
}

// --- Status Badge Component ---
enum BadgeType { pending, active, success, error }

class StatusBadge extends StatelessWidget {
  final String label;
  final BadgeType type;

  const StatusBadge({super.key, required this.label, required this.type});

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;
    IconData? icon;

    switch (type) {
      case BadgeType.pending:
        bgColor = AppColors.statusPendingBg;
        textColor = AppColors.statusPendingText;
        icon = Icons.hourglass_empty_rounded;
        break;
      case BadgeType.active:
        bgColor = AppColors.statusActiveBg;
        textColor = AppColors.statusActiveText;
        icon = Icons.sync_rounded;
        break;
      case BadgeType.success:
        bgColor = AppColors.statusSuccessBg;
        textColor = AppColors.statusSuccessText;
        icon = Icons.check_circle_rounded;
        break;
      case BadgeType.error:
        bgColor = AppColors.statusErrorBg;
        textColor = AppColors.statusErrorText;
        icon = Icons.error_rounded;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: textColor),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}

// --- Modern Action Button Component ---
class ModernActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isPrimary;
  final bool isSuccess;

  const ModernActionButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
    this.isLoading = false,
    this.isPrimary = true,
    this.isSuccess = false,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = isPrimary 
      ? (isSuccess ? AppColors.statusSuccessText : AppColors.primary) 
      : Colors.white;
    final fgColor = isPrimary ? Colors.white : AppColors.primary;
    final border = isPrimary ? BorderSide.none : const BorderSide(color: AppColors.border);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: 48,
      decoration: BoxDecoration(
        color: onPressed == null ? AppColors.border : bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.fromBorderSide(onPressed == null ? BorderSide.none : border),
        boxShadow: (isPrimary && onPressed != null) ? [
          BoxShadow(
            color: bgColor.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          )
        ] : [],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: isLoading ? null : onPressed,
          child: Center(
            child: isLoading
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(fgColor),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(icon, color: onPressed == null ? AppColors.textMuted : fgColor, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        label,
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: onPressed == null ? AppColors.textMuted : fgColor,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

// --- Step Progress Stepper Component ---
class StepProgress extends StatelessWidget {
  final int currentStep;
  const StepProgress({super.key, required this.currentStep});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _buildStepItem(1, "Scan", currentStep >= 1),
        _buildConnector(currentStep >= 2),
        _buildStepItem(2, "Verify", currentStep >= 2),
        _buildConnector(currentStep >= 3),
        _buildStepItem(3, "Assign", currentStep >= 3),
      ],
    );
  }

  Widget _buildStepItem(int step, String label, bool isActive) {
    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: isActive ? AppColors.primary : AppColors.background,
            border: Border.all(
              color: isActive ? AppColors.primary : AppColors.border,
              width: 2,
            ),
            shape: BoxShape.circle,
            boxShadow: isActive ? [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.2),
                blurRadius: 8,
                offset: const Offset(0, 4),
              )
            ] : [],
          ),
          child: Center(
            child: isActive && currentStep > step
                ? const Icon(Icons.check, size: 16, color: Colors.white)
                : Text(
                    step.toString(),
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isActive ? Colors.white : AppColors.textMuted,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
            color: isActive ? AppColors.textMain : AppColors.textMuted,
          ),
        ),
      ],
    );
  }

  Widget _buildConnector(bool isActive) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(bottom: 24, left: 8, right: 8),
        height: 2,
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : AppColors.border,
          borderRadius: BorderRadius.circular(1),
        ),
      ),
    );
  }
}

// --- Map Preview Component ---
class MapPreview extends StatelessWidget {
  final Map<String, dynamic>? location;
  final bool isDetecting;
  final bool hasError;

  const MapPreview({
    super.key,
    required this.location,
    required this.isDetecting,
    required this.hasError,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 160,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
        color: const Color(0xFFF1F5F9), // Slate 100
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Mock Map Background Grid
          Positioned.fill(
            child: Opacity(
              opacity: 0.5,
              child: CustomPaint(painter: GridPainter()),
            ),
          ),
          
          if (isDetecting)
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(strokeWidth: 2, color: AppColors.accent),
                const SizedBox(height: 16),
                Text(
                  "Acquiring GPS Signal...",
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            )
          else if (hasError)
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.location_off_rounded, color: AppColors.statusErrorText, size: 32),
                const SizedBox(height: 8),
                Text(
                  "Location Access Denied",
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            )
          else if (location == null)
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.map_rounded, color: AppColors.textMuted, size: 32),
                const SizedBox(height: 8),
                Text(
                  "Map Preview Not Available",
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            )
          else ...[
            // Pulse Animation underneath the pin
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(seconds: 2),
              curve: Curves.easeOutQuart,
              builder: (context, value, child) {
                return Container(
                  width: 100 * value,
                  height: 100 * value,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.statusSuccessText.withValues(alpha: (1 - value) * 0.4),
                  ),
                );
              },
              onEnd: () {
                // Infinite loop mock would require a stateful widget, 
                // but this single pulse is enough for the micro-interaction feel.
              },
            ),
            const Icon(Icons.location_on, color: AppColors.statusSuccessText, size: 40),
            
            // Badge for Coordinates
            Positioned(
              bottom: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 4, offset: const Offset(0, 2)),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 8, height: 8,
                      decoration: const BoxDecoration(color: AppColors.statusSuccessText, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "Lat: ${(location!['lat'] as double).toStringAsFixed(4)} • Lng: ${(location!['lng'] as double).toStringAsFixed(4)}",
                      style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textMain),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// Helper to draw a sleek map grid
class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.border
      ..strokeWidth = 1.0;

    for (double i = 0; i < size.width; i += 20) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (double i = 0; i < size.height; i += 20) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}


// --- Main Dashboard Screen State ---
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int? _selectedLocationId;
  String? _scannedBarcode;
  Map<String, dynamic>? _hardwareData;
  bool _isCheckingHardware = false;
  bool _isDetectingGPS = false;
  bool _isSubmitting = false;
  bool _hasGPSError = false;

  final int _currentUserId = 1;

  final Map<int, Map<String, dynamic>> _warehouseLocations = {
    1: {'name': 'Pune', 'lat': 18.5204, 'lng': 73.8567},
    2: {'name': 'Mumbai', 'lat': 19.0760, 'lng': 72.8777},
    3: {'name': 'Bangalore', 'lat': 12.9716, 'lng': 77.5946},
  };
  final double _allowedRadiusMeters = 100000;

  int get _currentStep {
    if (_hardwareData == null) return 1;
    if (_selectedLocationId == null) return 2;
    return 3;
  }

  void _showToast(String message, {bool isError = false, bool isSuccess = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).clearSnackBars();
    
    Color bgColor = AppColors.primary;
    IconData icon = Icons.info_outline_rounded;
    
    if (isError) {
      bgColor = AppColors.statusErrorText;
      icon = Icons.error_outline_rounded;
    } else if (isSuccess) {
      bgColor = AppColors.statusSuccessText;
      icon = Icons.check_circle_outline_rounded;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(child: Text(message, style: GoogleFonts.inter(fontWeight: FontWeight.w600))),
          ],
        ),
        backgroundColor: bgColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.only(bottom: 24, left: 24, right: 24),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  Future<void> _navigateToScan() async {
    final scannedValue = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (context) => const ScanHardwareScreen()),
    );

    if (scannedValue != null) {
      setState(() {
        _scannedBarcode = scannedValue;
        _hardwareData = null; // reset
        _isCheckingHardware = true;
      });

      try {
        final result = await ApiService.scanHardware(scannedValue);
        setState(() => _hardwareData = result['hardware']);
        _showToast('Hardware scanned successfully!', isSuccess: true);
      } catch (e) {
        final errorMsg = e.toString();
        if (errorMsg.contains('Hardware not found')) {
           // Barcode is fresh. Trigger the registration dialog
           await _showRegistrationDialog(scannedValue);
        } else {
           _showToast('Verification failed: ${errorMsg.replaceAll("Exception: ", "")}', isError: true);
        }
      } finally {
        setState(() => _isCheckingHardware = false);
      }
    }
  }

  Future<void> _showRegistrationDialog(String barcode) async {
    final TextEditingController nameController = TextEditingController();
    bool isRegistering = false;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Text("Register New Hardware", style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(8)),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.qr_code_2_rounded, size: 16, color: AppColors.textMuted),
                        const SizedBox(width: 8),
                        Text(barcode, style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: AppColors.textMain)),
                      ]
                    )
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: nameController,
                    autofocus: true,
                    decoration: InputDecoration(
                      labelText: "Hardware Name",
                      hintText: "e.g. Dell XPS 15",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AppColors.primary, width: 2),
                      ),
                    ),
                  ),
                ],
              ),
              actionsPadding: const EdgeInsets.all(16),
              actions: [
                TextButton(
                  onPressed: isRegistering ? null : () => Navigator.pop(context),
                  child: Text("Cancel", style: GoogleFonts.inter(color: AppColors.textMuted, fontWeight: FontWeight.w600)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  onPressed: isRegistering ? null : () async {
                    if (nameController.text.trim().isEmpty) return;
                    setDialogState(() => isRegistering = true);
                    try {
                      final result = await ApiService.registerHardware(
                        hardwareName: nameController.text.trim(),
                        barcodeValue: barcode,
                        currentLocationId: 1, // Defaulting safe origin logic
                      );
                      Navigator.pop(context); // Close dialog
                      
                      if (mounted) {
                        setState(() {
                          // Standardize response payload, often wrapped in 'data'
                          _hardwareData = result['data'] ?? result['hardware'];
                        });
                        _showToast('Hardware successfully registered & loaded!', isSuccess: true);
                      }
                    } catch (e) {
                      _showToast('Registration failed: ${e.toString().replaceAll("Exception: ", "")}', isError: true);
                      setDialogState(() => isRegistering = false);
                    }
                  },
                  child: isRegistering 
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : Text("Register Unit", style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                ),
              ],
            );
          }
        );
      }
    );
  }

  Future<void> _detectLocation() async {
    setState(() {
       _isDetectingGPS = true;
       _hasGPSError = false;
       _selectedLocationId = null;
    });

    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) throw Exception('Location permissions are denied');
      }

      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.medium,
          timeLimit: const Duration(seconds: 10)); 

      int? nearestLocationId;
      double shortestDistance = double.infinity;
      String nearestLocationName = "";

      _warehouseLocations.forEach((id, loc) {
        double distanceInMeters = Geolocator.distanceBetween(
          position.latitude, position.longitude, loc['lat'] as double, loc['lng'] as double);

        if (distanceInMeters < shortestDistance) {
          shortestDistance = distanceInMeters;
          if (distanceInMeters <= _allowedRadiusMeters) {
             nearestLocationId = id;
             nearestLocationName = loc['name'] as String;
          }
        }
      });
      
      if (nearestLocationId != null) {
        setState(() => _selectedLocationId = nearestLocationId);
        _showToast('Detected nearby warehouse: $nearestLocationName', isSuccess: true);
      } else {
        throw Exception("No inventory warehouse found near your current location.");
      }
    } catch (e) {
      setState(() => _hasGPSError = true);
      _showToast(e.toString().replaceAll("Exception: ", ""), isError: true);
    } finally {
      setState(() => _isDetectingGPS = false);
    }
  }

  Future<void> _markLocation() async {
     if (_hardwareData == null || _selectedLocationId == null) return;

     setState(() => _isSubmitting = true);

     try {
        await ApiService.markLocation(_hardwareData!['hardware_id'], _selectedLocationId!, _currentUserId);
        _showToast('Location Assignment complete!', isSuccess: true);
        setState(() {
           _scannedBarcode = null;
           _hardwareData = null;
           _selectedLocationId = null;
        });
     } catch (e) {
        _showToast('Failed to assign: ${e.toString()}', isError: true);
     } finally {
        setState(() => _isSubmitting = false);
     }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(64),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 2))],
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Row(
                children: [
                  Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.inventory_2_rounded, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    'Workspace',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5,
                      color: AppColors.textMain,
                    ),
                  ),
                  const Spacer(),
                  // Avatar mock
                  Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(color: AppColors.accent.withValues(alpha: 0.1), shape: BoxShape.circle),
                    child: const Center(child: Text("JD", style: TextStyle(color: AppColors.accent, fontWeight: FontWeight.bold))),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640), // Standard SaaS dashboard container width
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Text(
                  "Assignment Workflow",
                  style: GoogleFonts.inter(
                    fontSize: 32, 
                    fontWeight: FontWeight.w800, 
                    letterSpacing: -1.0,
                    color: AppColors.textMain,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Securely scan hardware and confirm its physical warehouse destination.",
                  style: GoogleFonts.inter(
                    fontSize: 16, 
                    color: AppColors.textMuted, 
                  ),
                ),
                const SizedBox(height: 48),

                // Stepper
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: StepProgress(currentStep: _currentStep),
                ),
                const SizedBox(height: 48),

                // Step 1: Scanner Card
                _buildScannerCard(),
                const SizedBox(height: 24),

                // Step 2: Location Card
                if (_currentStep >= 2) ...[
                  _buildLocationCard(),
                  const SizedBox(height: 24),
                ],

                // Step 3: Assignment Trigger
                if (_currentStep == 3) ...[
                  ModernActionButton(
                    label: "Confirm Assignment",
                    icon: Icons.check_circle_outline_rounded,
                    onPressed: _markLocation,
                    isLoading: _isSubmitting,
                    isSuccess: true, // colors it green if we build that style
                  ),
                  const SizedBox(height: 48),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildScannerCard() {
    final bool isDone = _hardwareData != null;
    final bool isActive = _currentStep == 1;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(24),
      decoration: isDone ? AppStyles.successCardDecoration : (isActive ? AppStyles.activeCardDecoration : AppStyles.cardDecoration),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Hardware Identification",
                style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textMain),
              ),
              StatusBadge(
                label: _isCheckingHardware ? "Verifying..." : (isDone ? "Verified" : (isActive ? "Awaiting Scan" : "Pending")),
                type: _isCheckingHardware ? BadgeType.active : (isDone ? BadgeType.success : (isActive ? BadgeType.active : BadgeType.pending)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (!isDone)
            Text(
              "Initialize the camera to scan the hardware QR or Barcode label attached to the physical unit.",
              style: GoogleFonts.inter(fontSize: 15, color: AppColors.textMuted, height: 1.5),
            )
          else
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
                    child: const Icon(Icons.qr_code_2_rounded, color: AppColors.primary),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Scanned Identity", style: GoogleFonts.inter(fontSize: 12, color: AppColors.textMuted)),
                        const SizedBox(height: 4),
                        Text(
                          _hardwareData!['hardware_name'] ?? _scannedBarcode ?? "Unknown", 
                          style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textMain)
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 24),
          ModernActionButton(
            label: _isCheckingHardware ? "Verifying Item..." : (isDone ? "Re-scan Item" : "Open Camera Scanner"),
            icon: Icons.camera_alt_outlined,
            onPressed: (isActive || isDone) && !_isCheckingHardware ? _navigateToScan : null, 
            isPrimary: !isDone,
            isLoading: _isCheckingHardware,
          ),
        ],
      ),
    );
  }

  Widget _buildLocationCard() {
    final bool isDone = _selectedLocationId != null;
    final bool isActive = _currentStep == 2;

    Map<String, dynamic>? detectedLoc = isDone ? _warehouseLocations[_selectedLocationId] : null;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(24),
      decoration: isDone ? AppStyles.successCardDecoration : (isActive ? AppStyles.activeCardDecoration : AppStyles.cardDecoration),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Geospatial Verification",
                style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textMain),
              ),
              StatusBadge(
                label: _isDetectingGPS ? "Searching..." : (isDone ? "Locked" : (_hasGPSError ? "Error" : "Required")),
                type: _isDetectingGPS ? BadgeType.active : (isDone ? BadgeType.success : (_hasGPSError ? BadgeType.error : BadgeType.pending)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          MapPreview(
            location: detectedLoc,
            isDetecting: _isDetectingGPS,
            hasError: _hasGPSError,
          ),
          const SizedBox(height: 24),
          if (isDone)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warehouse_rounded, color: AppColors.primary),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Nearest Detected Origin", style: GoogleFonts.inter(fontSize: 12, color: AppColors.textMuted)),
                        const SizedBox(height: 4),
                        Text(
                          detectedLoc!['name'] as String, 
                          style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textMain)
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          if (isDone) const SizedBox(height: 24),
          ModernActionButton(
            label: isDone ? "Re-acquire GPS" : "Detect GPS Coordinates",
            icon: Icons.my_location_rounded,
            onPressed: isActive || isDone ? _detectLocation : null,
            isPrimary: !isDone,
            isLoading: _isDetectingGPS,
          ),
        ],
      ),
    );
  }
}
