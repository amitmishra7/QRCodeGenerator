import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QRCodePage extends StatefulWidget {
  QRCodePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _QRCodePageState createState() => _QRCodePageState();
}

class _QRCodePageState extends State<QRCodePage> {
  GlobalKey _globalKey = new GlobalKey();
  bool showQR = false;
  String qrText;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            _buildTextInputField(),
            _buildQRCode(),
            _buildButtons(),
          ],
        ),
      ),
    );
  }

  _buildTextInputField() {
    return TextField(
      onChanged: (text) {
        setState(() {
          showQR = false;
          qrText = text;
        });
      },
      decoration: InputDecoration(labelText: 'Text here'),
    );
  }

  _buildButtons() {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Visibility(
            visible: !showQR,
            child: ElevatedButton(
              child: Text('Create QR Code'),
              style: ElevatedButton.styleFrom(primary: Colors.blue),
              onPressed: () {
                setState(() {
                  showQR = true;
                });
              },
            ),
          ),
          Visibility(
            visible: showQR,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(primary: Colors.red),
              child: Text('Clear QR Code'),
              onPressed: () {
                setState(() {
                  showQR=false;
                });
              },
            ),
          ),
          Visibility(
            visible: showQR,
            child: Padding(
              padding: const EdgeInsets.only(left: 50),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(primary: Colors.green),
                child: Text('Share QR Code'),
                onPressed: () {
                  _qrCodeToImage();
                },
              ),
            ),
          )
        ],
      ),
    );
  }

  _buildQRCode() {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Visibility(
        visible: showQR,
        child: RepaintBoundary(
          key: _globalKey,
          child: Container(
            color : Colors.white,
            child: QrImage(
              data: qrText,
              version: QrVersions.auto,
              size: MediaQuery.of(context).size.width - 50,
              gapless: false,
            ),
          ),
        ),
      ),
    );
  }

  void _qrCodeToImage() async {
    try {
      RenderRepaintBoundary boundary =
          _globalKey.currentContext.findRenderObject();
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      var pngBytes = byteData.buffer.asUint8List();
      _shareQRCodeImage(pngBytes);
      setState(() {});
    } catch (e) {
      print(e);
    }
  }

  Future<void> _shareQRCodeImage(Uint8List bytes) async {
    try {
      await Share.file('Share Via', 'QRCode.png', bytes, 'image/png',
          text: 'QR Code');
    } catch (e) {
      print('error: $e');
    }
  }

}
