import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'insights_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int currentIndex = 0;

  Map<String, double> categoryTotals = {};
  String topCategory = "";
  String weeklyInsight = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: currentIndex == 0
          ? HomeScreen()
          : InsightsScreen(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) {
          setState(() => currentIndex = index);
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.insights),
            label: "Insights",
          ),
        ],
      ),
    );
  }
}