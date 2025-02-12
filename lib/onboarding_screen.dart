import 'package:flutter/material.dart';

class OnboardingScreen extends StatefulWidget {
  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: _controller,
            onPageChanged: (index) {
              setState(() {
                currentPage = index;
              });
            },
            children: [
              buildPage(
                image: 'images/handcrafted1.jpeg',
                title: 'Crafted with Love',
                description:
                    'Explore unique handmade products from talented artisans.',
              ),
              buildPage(
                image: 'images/handcrafted2.jpeg',
                title: 'Support Local Artists',
                description:
                    'Every purchase helps local artists thrive and grow.',
              ),
              buildPage(
                image: 'images/handcrafted3.jpeg',
                title: 'Exclusive Designs',
                description:
                    'Find one-of-a-kind pieces you won’t see anywhere else.',
              ),
            ],
          ),
          Positioned(
            bottom: 80,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                3,
                (index) => buildDot(index),
              ),
            ),
          ),
          Positioned(
            bottom: 30,
            left: 30,
            right: 30,
            child: ElevatedButton(
              onPressed: () {
                if (currentPage == 2) {
                  Navigator.pushReplacementNamed(context, '/home');
                } else {
                  _controller.nextPage(
                    duration: Duration(milliseconds: 400),
                    curve: Curves.easeInOut,
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.brown,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: EdgeInsets.symmetric(vertical: 14),
              ),
              child: Text(
                currentPage == 2 ? 'Get Started' : 'Next',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildPage({
    required String image,
    required String title,
    required String description,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, Colors.brown.shade50],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(image, height: 250),
            SizedBox(height: 30),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.brown.shade800,
              ),
            ),
            SizedBox(height: 15),
            Text(
              description,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 17,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildDot(int index) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      margin: EdgeInsets.symmetric(horizontal: 6),
      width: currentPage == index ? 20 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: currentPage == index ? Colors.brown : Colors.grey.shade400,
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }
}
