import 'package:flutter/material.dart';
import 'package:revuer/res/colors.dart';

class WithdrawFullImageScreen extends StatefulWidget {
  final String url;
  const WithdrawFullImageScreen({Key? key,required this.url}) : super(key: key);

  @override
  State<WithdrawFullImageScreen> createState() => _WithdrawFullImageScreenState();
}

class _WithdrawFullImageScreenState extends State<WithdrawFullImageScreen> {

  final _transformationController = TransformationController();
  late TapDownDetails _doubleTapDetails;

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: const Text("Withdraw Attachment"),
        backgroundColor: secondaryColor,
      ),
      body: SafeArea(
        child: GestureDetector(
          onDoubleTapDown: _handleDoubleTapDown,
          onDoubleTap: _handleDoubleTap,
          child: Center(
            child: InteractiveViewer(
              transformationController: _transformationController,
              panEnabled: true, // Set it to false
              boundaryMargin: const EdgeInsets.all(0),
              child: Image.network(
                  widget.url,
                  fit: BoxFit.fill,
                  errorBuilder:
                      (context, error, stackTrace) {
                    return SizedBox(
                      child: Image.asset(
                        'assets/images/error_image.png',
                        fit: BoxFit.fill,),
                    );}
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _handleDoubleTapDown(TapDownDetails details) {
    _doubleTapDetails = details;
  }

  void _handleDoubleTap() {
    if (_transformationController.value != Matrix4.identity()) {
      _transformationController.value = Matrix4.identity();
    } else {
      final position = _doubleTapDetails.localPosition;
      // For a 3x zoom
      _transformationController.value = Matrix4.identity()
        ..translate(-position.dx, -position.dy)
        ..scale(2.0);
    }
  }
}

