import 'dart:ui';

import 'package:another_telephony/telephony.dart';
import 'package:dhanra/features/dashboard/presentation/dashboard_screen.dart';
import 'package:dhanra/features/stats_screen/presentation/stats_screen.dart';
import 'package:dhanra/features/profile/profile_screen.dart';
import 'package:dhanra/features/investment/investment_screen.dart';
import 'package:dhanra/main.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _animationController;
  final Telephony telephony = Telephony.instance;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    telephony.listenIncomingSms(
      onNewMessage: onBackgroundMessage,
      onBackgroundMessage: onBackgroundMessage, // Register your callback
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    _animationController.forward().then((_) {
      _animationController.reverse();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          // Main page content
          IndexedStack(
            index: _currentIndex,
            children: <Widget>[
              DashboardScreen(),
              StatsScreen(),
              // InvestmentScreen(),
              Center(child: Image.asset('assets/images/maintainace.png')),
              ProfileScreen(),
            ],
          ),

          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(25),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                  child: Container(
                    height: 64,
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(15),
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(
                        color: Colors.white.withAlpha(20),
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.all(
                        Radius.circular(20),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildNavItem(
                              0, 'assets/images/dashboard.png', 'Dashboard'),
                          _buildNavItem(
                              1, 'assets/images/pie-chart.png', 'Messages'),
                          _buildNavItem(
                              2, 'assets/images/growth.png', 'Settings'),
                          _buildNavItem(3, 'assets/images/user.png', 'Profile'),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, String image, String label) {
    final isSelected = _currentIndex == index;

    return GestureDetector(
      onTap: () => _onTabTapped(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              padding: EdgeInsets.all(isSelected ? 8 : 4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: isSelected ? AppColors.primary : Colors.transparent,
              ),
              child: Image.asset(
                image,
                height: isSelected ? 24 : 22,
                color: isSelected ? Colors.white : Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }
}
