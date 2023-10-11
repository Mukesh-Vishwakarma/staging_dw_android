import 'package:flutter/material.dart';
import 'package:revuer/res/colors.dart';
import 'package:shimmer/shimmer.dart';

class FullImageViewScreen extends StatefulWidget {
  final String url;

  const FullImageViewScreen({Key? key, required this.url}) : super(key: key);

  @override
  State<FullImageViewScreen> createState() => _FullImageViewScreenState();
}

class _FullImageViewScreenState extends State<FullImageViewScreen> {
  final _transformationController = TransformationController();
  late TapDownDetails _doubleTapDetails;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: const Text("Full Image"),
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
              child: Image.network(widget.url, fit: BoxFit.fill, loadingBuilder:
                  (BuildContext context, Widget child,
                      ImageChunkEvent? loadingProgress) {
                if (loadingProgress == null) return child;
                return Shimmer.fromColors(
                  baseColor:
                      const Color.fromRGBO(191, 191, 191, 0.5254901960784314),
                  highlightColor: Colors.white,
                  child: Container(
                    width: 41.0,
                    height: 41.0,
                    color: Colors.grey,
                  ),
                );
              }, errorBuilder: (context, error, stackTrace) {
                return SizedBox(
                  child: Image.asset(
                    'assets/images/error_image.png',
                    fit: BoxFit.fill,
                  ),
                );
              }),
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
      /*..translate(-position.dx * 2, -position.dy * 2)
        ..scale(3.0);*/
      // Fox a 2x zoom
      // ..translate(-position.dx, -position.dy)
      // ..scale(2.0);
    }
  }
}
