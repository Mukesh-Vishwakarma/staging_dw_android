import 'package:flutter/material.dart';
import 'package:revuer/res/colors.dart';

class ComingSoonScreen extends StatefulWidget {
  const ComingSoonScreen({Key? key}) : super(key: key);

  @override
  State<ComingSoonScreen> createState() => _ComingSoonScreenState();
}

class _ComingSoonScreenState extends State<ComingSoonScreen> {
  void _openMyPage() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _openMyPage();
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          backgroundColor: secondaryColor,
        ),
        body: const Center(
          child: Text(
            "Coming Soon",
            style: TextStyle(
              fontSize: 25,
              color: secondaryColor,
            ),
          ),
        ),
      ),
    );
  }
}
