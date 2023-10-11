import 'package:flutter/material.dart';
import '../../res/colors.dart';
import 'SliderModel.dart';
import '../../widgets/button_widget.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  List<SliderModel> slides = <SliderModel>[];
  int currentIndex = 0;

  /*late final PageController _controller;*/
  final _controller = PageController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    /*_controller = PageController(initialPage: 0);*/
    slides = getSlides();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future _callNextPage() async {
    _controller.nextPage(
        duration: const Duration(milliseconds: 500), curve: Curves.easeIn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Expanded(
                flex: 5,
                child: PageView.builder(
                    controller: _controller,
                    scrollDirection: Axis.horizontal,
                    onPageChanged: (value) {
                      setState(() {
                        currentIndex = value;
                      });
                    },
                    itemCount: slides.length,
                    itemBuilder: (context, index) {
                      // contents of slider
                      return Slider(
                        image: slides[index].image,
                        title: slides[index].title,
                        description: slides[index].description,
                      );
                    }),
              ),
              Expanded(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        slides.length,
                        (index) => buildDot(index, context),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 34),
              width: double.infinity,
              child: Row(
                children: [
                  if (currentIndex != slides.length - 1)
                    Expanded(
                      child: Container(
                        height: 48,
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.all(
                            Radius.circular(8.0),
                          ),
                        ),
                        child: GestureDetector(
                          onTap: () => Navigator.pushReplacementNamed(
                              context, '/signup'),
                          child: const Text(
                            'Skip',
                            style: TextStyle(
                                color: thirdColor,
                                fontSize: 16.0,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1.0),
                          ),
                        ),
                      ),
                    ),
                  if (currentIndex != slides.length - 1)
                    const SizedBox(
                      width: 10.0,
                    ),
                  Expanded(
                    child: ButtonWidget(
                      buttonContent: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            currentIndex == slides.length - 1
                                ? "GET STARTED"
                                : "NEXT",
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16.0,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.0),
                          ),
                          const SizedBox(
                            width: 10.0,
                          ),
                          Image.asset(
                            "assets/icons/arrow-right.png",
                            width: 22,
                            height: 12,
                            fit: BoxFit.contain,
                          ),
                        ],
                      ),
                      onPressed: () async {
                        if (currentIndex == slides.length - 1) {
                          Navigator.pushReplacementNamed(context, '/signup');
                        }
                        _callNextPage();
                      },
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // container created for dots
  Container buildDot(int index, BuildContext context) {
    return Container(
      height: 10,
      width: currentIndex == index ? 30 : 10,
      margin: const EdgeInsets.only(right: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5.0),
        border: Border.all(
            width: currentIndex == index ? 0 : 1,
            color: currentIndex == index ? primaryColor : thirdColor),
        color: currentIndex == index ? primaryColor : Colors.transparent,
      ),
    );
  }
}

// ignore: must_be_immutable
// slider declared
class Slider extends StatelessWidget {
  String? image;
  String? title;
  String? description;

  Slider({Key? key, this.image, this.title, this.description})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Image(image: AssetImage(image!)),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: secondaryColor,
                  fontSize: 24.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 20.0),
              Text(
                description!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: thirdColor,
                  fontSize: 16.0,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 10.0),
            ],
          ),
        ),
      ],
    );
  }
}
