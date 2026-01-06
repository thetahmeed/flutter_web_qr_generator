import 'dart:js_interop';
import 'dart:typed_data';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:web/web.dart' as web;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:screenshot/screenshot.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _controller = TextEditingController();
  final ScreenshotController _screenshotController = ScreenshotController();

  Uint8List? _logoBytes;
  String _qrData = "hi";

  double _currentSliderValue = 50;

  // 1. Pick Logo from Device
  Future<void> _pickLogo() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true, // Required for Web to get bytes
    );

    if (result != null) {
      setState(() {
        _logoBytes = result.files.first.bytes;
      });
    }
  }

  // 2. Capture and Download PNG
  Future<void> _downloadQr() async {
    String timeStamp = DateTime.timestamp().toString();

    final Uint8List? image = await _screenshotController.capture(
      delay: Duration(milliseconds: 50),
      pixelRatio: 3.0,
    );

    if (image != null) {
      // Modern Web Download Logic
      final blob = web.Blob(
        [image.toJS].toJS,
        web.BlobPropertyBag(type: 'image/png'),
      );
      final url = web.URL.createObjectURL(blob);
      final anchor = web.HTMLAnchorElement()
        ..href = url
        ..download = "qr_$timeStamp.png";
      anchor.click();
      web.URL.revokeObjectURL(url);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SizedBox(
          width: 400,
          child: Column(
            children: [
              const SizedBox(height: 20),
              Text(
                'Qr Generator',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _controller,
                decoration: InputDecoration(
                  labelText: "Enter Text or URL",
                  border: OutlineInputBorder(),
                ),
                onChanged: (val) => setState(() => _qrData = val),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: _pickLogo,
                    icon: Icon(Icons.image),
                    label: Text("Add Photo"),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton.icon(
                    onPressed: _downloadQr,
                    icon: Icon(Icons.download),
                    label: Text("Save"),
                  ),
                ],
              ),

              SizedBox(height: 20),
              Text('Logo size:'),
              if (_logoBytes != null)
                Slider(
                  value: _currentSliderValue,
                  max: 150,
                  onChanged: (double value) {
                    setState(() {
                      _currentSliderValue = value;
                    });
                  },
                ),
              const Spacer(),
              // The QR code display area
              Screenshot(
                controller: _screenshotController,
                child: Stack(
                  alignment: AlignmentGeometry.center,
                  children: [
                    Container(
                      padding: EdgeInsets.all(10),
                      color: Colors.white, // Background for the captured image
                      child: QrImageView(
                        data: _qrData,
                        version: QrVersions.auto,
                        size: 300.0,
                        // Higher error correction allows for a larger logo without breaking the QR
                        errorCorrectionLevel: QrErrorCorrectLevel.H,
                        // embeddedImage: _logoBytes != null
                        //     ? MemoryImage(_logoBytes!)
                        //     : null,
                        embeddedImageStyle: QrEmbeddedImageStyle(
                          size: Size(60, 60),
                        ),
                      ),
                    ),

                    if (_logoBytes != null)
                      Container(
                        padding: EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          // borderRadius: BorderRadius.circular(60),
                        ),
                        height: _currentSliderValue,
                        width: _currentSliderValue,
                        child: Image.memory(_logoBytes!),
                      ),
                  ],
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
