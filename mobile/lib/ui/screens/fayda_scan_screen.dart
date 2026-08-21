import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../fayda/fayda_decoder.dart';
import '../../state/auth_controller.dart';
import '../../theme/app_colors.dart';
import 'fayda_confirm_screen.dart';

enum FaydaScanMode { login, register }

class FaydaScanScreen extends ConsumerStatefulWidget {
  const FaydaScanScreen({super.key, required this.mode});

  final FaydaScanMode mode;

  @override
  ConsumerState<FaydaScanScreen> createState() => _FaydaScanScreenState();
}

class _FaydaScanScreenState extends ConsumerState<FaydaScanScreen> {
  // Fayda V4 QRs are dense. Android defaults to 640x480 if unset, which
  // cannot read the card; gallery photos work because they keep full resolution.
  final _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.unrestricted,
    formats: const [BarcodeFormat.qrCode],
    cameraResolution: const Size(1920, 1080),
  );
  var _loading = false;
  String? _error;
  var _handled = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String get _title => widget.mode == FaydaScanMode.login
      ? 'Sign in with Fayda'
      : 'Scan Fayda ID';

  Future<void> _handleQrText(String text) async {
    if (_handled || _loading) return;
    _handled = true;
    await _processText(text);
  }

  Future<void> _processText(String text) async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final result = decodeAndVerify(text, includeFace: true);
    if (!mounted) return;
    if (result is FaydaResultErr) {
      setState(() {
        _error = faydaScanErrorMessage(result.error.code);
        _loading = false;
        _handled = false;
      });
      return;
    }
    final data = (result as FaydaResultOk).data;
    if (widget.mode == FaydaScanMode.login) {
      await ref
          .read(authControllerProvider.notifier)
          .loginWithFayda(rawPayload: data.rawPayload);
      if (!mounted) return;
      final auth = ref.read(authControllerProvider);
      if (auth.status == AuthStatus.signedIn) {
        Navigator.of(context).pop();
        return;
      }
      setState(() {
        _error = auth.error ?? 'Could not sign in with this Fayda ID.';
        _loading = false;
        _handled = false;
      });
      return;
    }
    if (!mounted) return;
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => FaydaConfirmScreen(fayda: data),
      ),
    );
    if (!mounted) return;
    setState(() {
      _loading = false;
      _handled = false;
    });
  }

  Future<void> _pickImage() async {
    if (_loading) return;
    try {
      final file = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 100,
        requestFullMetadata: false,
      );
      if (!mounted || file == null) return;
      setState(() {
        _loading = true;
        _error = null;
      });
      final analyzer = MobileScannerController();
      try {
        final capture = await analyzer.analyzeImage(file.path);
        if (!mounted) return;
        final raw = capture?.barcodes.firstOrNull?.rawValue;
        if (raw != null && raw.isNotEmpty) {
          _handled = false;
          await _processText(raw);
          return;
        }
        setState(() {
          _error =
              'No QR code found in the selected image.\nUse a clearer photo of the card back.';
          _loading = false;
        });
      } finally {
        analyzer.dispose();
      }
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = 'Could not open the gallery. Try again.';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authControllerProvider);
    final busy = _loading || auth.busy;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: (capture) {
              final value = capture.barcodes.firstOrNull?.rawValue;
              if (value != null && value.isNotEmpty) {
                _handleQrText(value);
              }
            },
          ),
          Center(
            child: SizedBox(
              width: 240,
              height: 240,
              child: CustomPaint(painter: _BracketPainter()),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left,
                          color: AppColors.snow, size: 28),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    Expanded(
                      child: Text(
                        _title,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.geist(
                          color: AppColors.snow,
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: busy ? null : _pickImage,
                      icon: const Icon(Icons.photo_outlined,
                          color: AppColors.snow),
                      tooltip: 'Choose a photo',
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: 24,
            right: 24,
            bottom: 28,
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Hold the camera close to the QR on the back of the card.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.snow.withValues(alpha: 0.75),
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    height: 46,
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: busy ? null : _pickImage,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.snow,
                        side: const BorderSide(color: AppColors.snow),
                      ),
                      icon: const Icon(Icons.photo_outlined, size: 18),
                      label: Text(
                        'CHOOSE FROM GALLERY',
                        style: GoogleFonts.geist(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.1,
                        ),
                      ),
                    ),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 10),
                    Text(
                      _error!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xFFFF8A80),
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                  if (busy) ...[
                    const SizedBox(height: 16),
                    const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.snow,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BracketPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.snow
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.square;
    const arm = 28.0;
    canvas.drawLine(Offset.zero, const Offset(arm, 0), paint);
    canvas.drawLine(Offset.zero, const Offset(0, arm), paint);
    canvas.drawLine(Offset(size.width, 0), Offset(size.width - arm, 0), paint);
    canvas.drawLine(Offset(size.width, 0), Offset(size.width, arm), paint);
    canvas.drawLine(Offset(0, size.height), Offset(arm, size.height), paint);
    canvas.drawLine(Offset(0, size.height), Offset(0, size.height - arm), paint);
    canvas.drawLine(
      Offset(size.width, size.height),
      Offset(size.width - arm, size.height),
      paint,
    );
    canvas.drawLine(
      Offset(size.width, size.height),
      Offset(size.width, size.height - arm),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
