import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../viewmodels/venta/venta_viewmodel.dart';

class ScannerVentaWidget extends StatefulWidget {
  final VentasViewModel viewModel;

  const ScannerVentaWidget({Key? key, required this.viewModel}) : super(key: key);

  @override
  State<ScannerVentaWidget> createState() => _ScannerVentaWidgetState();
}

class _ScannerVentaWidgetState extends State<ScannerVentaWidget> {
  late MobileScannerController cameraController;
  bool isScanning = true;
  bool _flashOn = false;
  bool _frontCamera = false;

  @override
  void initState() {
    super.initState();
    cameraController = MobileScannerController(
      torchEnabled: _flashOn,
      facing: _frontCamera ? CameraFacing.front : CameraFacing.back,
    );
  }

  void _onScanningChanged(bool scanning) {
    setState(() {
      isScanning = scanning;
    });
    if (!scanning) Navigator.of(context).pop();
  }

  void _toggleFlash() {
    setState(() {
      _flashOn = !_flashOn;
    });
    cameraController.toggleTorch();
  }

  void _switchCamera() {
    setState(() {
      _frontCamera = !_frontCamera;
    });
    cameraController.switchCamera();
  }

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => _onScanningChanged(false),
        ),
        title: Text('ESCÁNER VENTA',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
              letterSpacing: 1.5,
            )),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          if (isScanning)
            MobileScanner(
              controller: cameraController,
              onDetect: (capture) async {
                final barcodes = capture.barcodes;
                if (barcodes.isNotEmpty) {
                  final code = barcodes.first.rawValue;
                  if (code != null) {
                    _onScanningChanged(false);
                    await widget.viewModel.buscarProductoPorCodigo(code);
                  }
                }
              },
            )
          else
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                    strokeWidth: 3,
                  ),
                  SizedBox(height: 20),
                  Text('PROCESANDO...',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        letterSpacing: 1.2,
                      )),
                ],
              ),
            ),

          Center(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.7,
              height: MediaQuery.of(context).size.width * 0.7,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.red.withOpacity(0.8),
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Stack(
                children: [
                  _CornerEffect(color: Colors.red, position: CornerPosition.topLeft),
                  _CornerEffect(color: Colors.red, position: CornerPosition.topRight),
                  _CornerEffect(color: Colors.red, position: CornerPosition.bottomRight),
                  _CornerEffect(color: Colors.red, position: CornerPosition.bottomLeft),
                ],
              ),
            ),
          ),

          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _ToolButton(icon: _flashOn ? Icons.flash_off : Icons.flash_on, onPressed: _toggleFlash, color: Colors.red),
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.red.withOpacity(0.6), width: 3),
                  ),
                  child: Center(
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.red.withOpacity(0.2),
                        border: Border.all(color: Colors.red.withOpacity(0.8), width: 2),
                      ),
                    ),
                  ),
                ),
                _ToolButton(icon: Icons.cameraswitch_rounded, onPressed: _switchCamera, color: Colors.red),
              ],
            ),
          ),

          if (isScanning)
            Positioned(
              top: MediaQuery.of(context).size.height * 0.3,
              left: 0,
              right: 0,
              child: _ScanningBeam(color: Colors.red),
            ),
        ],
      ),
    );
  }
}

enum CornerPosition { topLeft, topRight, bottomRight, bottomLeft }

class _CornerEffect extends StatelessWidget {
  final Color color;
  final CornerPosition position;

  const _CornerEffect({this.color = Colors.cyan, required this.position});

  @override
  Widget build(BuildContext context) {
    double angle = 0;
    switch (position) {
      case CornerPosition.topLeft:
        angle = 0;
        break;
      case CornerPosition.topRight:
        angle = 1.5708;
        break;
      case CornerPosition.bottomRight:
        angle = 3.1416;
        break;
      case CornerPosition.bottomLeft:
        angle = 4.7124;
        break;
    }

    return Transform.rotate(
      angle: angle,
      child: Container(
        width: 30,
        height: 30,
        child: Stack(
          children: [
            Positioned(
              top: 0,
              left: 0,
              child: Container(width: 15, height: 3, color: color),
            ),
            Positioned(
              top: 0,
              left: 0,
              child: Container(width: 3, height: 15, color: color),
            ),
          ],
        ),
      ),
    );
  }
}

class _ToolButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final Color color;

  const _ToolButton({required this.icon, required this.onPressed, this.color = Colors.cyan});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.black.withOpacity(0.5), border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.5)),
      child: IconButton(icon: Icon(icon, color: color, size: 26), onPressed: onPressed),
    );
  }
}

class _ScanningBeam extends StatefulWidget {
  final Color color;

  const _ScanningBeam({this.color = Colors.cyan});

  @override
  __ScanningBeamState createState() => __ScanningBeamState();
}

class __ScanningBeamState extends State<_ScanningBeam> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
    _animation = Tween<Offset>(begin: const Offset(0, -0.5), end: const Offset(0, 0.5)).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _animation,
      child: Container(
        height: 3,
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [Colors.transparent, widget.color.withOpacity(0.8), Colors.transparent], stops: const [0.0, 0.5, 1.0]),
        ),
      ),
    );
  }
}
