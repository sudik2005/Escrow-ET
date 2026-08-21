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

class _FaydaScanScreenState extends ConsumerState<FaydaScanScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  var _loading = false;
  String? _error;
  var _cameraHandled = false;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
    _tabs.addListener(() {
      if (mounted) setState(() => _error = null);
    });
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  String get _title => widget.mode == FaydaScanMode.login
      ? 'Sign in with Fayda'
      : 'Scan Fayda ID';

  Future<void> _handleQrText(String text) async {
    if (_tabs.index != 0) return;
    if (_cameraHandled || _loading) return;
    _cameraHandled = true;
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
        _cameraHandled = false;
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
        _cameraHandled = false;
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
      _cameraHandled = false;
    });
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 100,
    );
    if (file == null) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    final controller = MobileScannerController();
    try {
      final capture = await controller.analyzeImage(file.path);
      if (!mounted) return;
      final raw = capture?.barcodes.firstOrNull?.rawValue;
      if (raw != null && raw.isNotEmpty) {
        _cameraHandled = false;
        await _processText(raw);
        return;
      }
      setState(() {
        _error =
            'No QR code found in the selected image.\nUse a clearer photo of the card back.';
        _loading = false;
      });
    } finally {
      controller.dispose();
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
          TabBarView(
            controller: _tabs,
            children: [
              MobileScanner(
                onDetect: (capture) {
                  final value = capture.barcodes.firstOrNull?.rawValue;
                  if (value != null && value.isNotEmpty) {
                    _handleQrText(value);
                  }
                },
              ),
              _GalleryTab(onPick: busy ? null : _pickImage),
            ],
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
                    const SizedBox(width: 48),
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
                  TabBar(
                    controller: _tabs,
                    indicatorColor: AppColors.crimson,
                    labelColor: AppColors.snow,
                    unselectedLabelColor: AppColors.snow.withValues(alpha: 0.5),
                    tabs: const [
                      Tab(text: 'CAMERA'),
                      Tab(text: 'GALLERY'),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Scan the QR on the back of your Fayda ID.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.snow.withValues(alpha: 0.75),
                      fontSize: 13,
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

class _GalleryTab extends StatelessWidget {
  const _GalleryTab({required this.onPick});

  final VoidCallback? onPick;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.black,
      child: Center(
        child: TextButton.icon(
          onPressed: onPick,
          icon: const Icon(Icons.photo_outlined, color: AppColors.snow),
          label: Text(
            'Choose a photo',
            style: GoogleFonts.geist(
              color: AppColors.snow,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
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
