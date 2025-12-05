import 'package:flutter/material.dart';
import 'package:movie/core/theme/app_colors.dart';
import 'package:movie/screens/home/home_tab.dart';
import 'package:movie/screens/home/browse_tab.dart';
import 'package:movie/screens/home/search_tab.dart';
import 'package:movie/screens/home/profile_tab.dart';

class HomeScreen extends StatefulWidget {
  static const routeName = 'Home';
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _tabs = [
    const HomeTab(),
    const BrowseTab(),
    const SearchTab(),
    const ProfileTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.Black,
      body: _tabs[_currentIndex],
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.grey,
          border: Border(
            top: BorderSide(
              color: AppColors.Black,
              width: 1,
            ),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: AppColors.grey,
          selectedItemColor: AppColors.yellow,
          unselectedItemColor: AppColors.white,
          selectedFontSize: 12,
          unselectedFontSize: 12,
          items: [
            BottomNavigationBarItem(
              icon: ColorFiltered(
                colorFilter: ColorFilter.mode(
                  _currentIndex == 0 ? AppColors.yellow : AppColors.white,
                  BlendMode.srcIn,
                ),
                child: Image.asset(
                  'assets/icons/home tab.png',
                  width: 24,
                  height: 24,
                ),
              ),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: ColorFiltered(
                colorFilter: ColorFilter.mode(
                  _currentIndex == 1 ? AppColors.yellow : AppColors.white,
                  BlendMode.srcIn,
                ),
                child: Image.asset(
                  'assets/icons/search tab.png',
                  width: 24,
                  height: 24,
                ),
              ),
              label: 'Search',
            ),
            BottomNavigationBarItem(
              icon: ColorFiltered(
                colorFilter: ColorFilter.mode(
                  _currentIndex == 2 ? AppColors.yellow : AppColors.white,
                  BlendMode.srcIn,
                ),
                child: Image.asset(
                  'assets/icons/explore tab.png',
                  width: 24,
                  height: 24,
                ),
              ),
              label: 'Browse',
            ),
            BottomNavigationBarItem(
              icon: ColorFiltered(
                colorFilter: ColorFilter.mode(
                  _currentIndex == 3 ? AppColors.yellow : AppColors.white,
                  BlendMode.srcIn,
                ),
                child: Image.asset(
                  'assets/icons/Profie tab.png',
                  width: 24,
                  height: 24,
                ),
              ),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
