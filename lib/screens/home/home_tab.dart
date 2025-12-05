import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:movie/core/theme/app_colors.dart';
import 'package:movie/core/theme/app_assets.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  final PageController _pageController = PageController(viewportFraction: 0.85);
  int _currentPage = 0;
  double _currentPageValue = 0.0;

  final List<Map<String, dynamic>> movies = [
    {'image': AppAssets.onBoarding1, 'rating': '7.7'},
    {'image': AppAssets.onBoarding2, 'rating': '7.7'},
    {'image': AppAssets.onBoarding3, 'rating': '7.7'},
    {'image': AppAssets.onBoarding4, 'rating': '7.7'},
    {'image': AppAssets.onBoarding5, 'rating': '7.7'},
    {'image': AppAssets.onBoarding6, 'rating': '7.7'},
  ];

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      setState(() {
        _currentPageValue = _pageController.page ?? 0.0;
        _currentPage = _currentPageValue.round();
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.Black,
      body: Stack(
        children: [
          _buildBackgroundWithBlur(),
          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildAvailableNowSection(context),
                  const SizedBox(height: 24),
                  _buildWatchNowSection(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackgroundWithBlur() {
    final currentIndex = _currentPageValue.round().clamp(0, movies.length - 1);
    final currentMovieImage = movies[currentIndex]['image'] as String;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: Positioned.fill(
        key: ValueKey<String>(currentMovieImage),
        child: ImageFiltered(
          imageFilter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(currentMovieImage),
                fit: BoxFit.cover,
                opacity: 0.7,
              ),
            ),
            child: Container(
              color: AppColors.Black.withOpacity(0.4),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvailableNowSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 81, top: 7),
          child: SizedBox(
            width: 267,
            height: 93,
            child: Image.asset(
              AppAssets.availableNowTxt,
              fit: BoxFit.contain,
            ),
          ),
        ),
        const SizedBox(height: 21),
        Padding(
          padding: const EdgeInsets.only(left: 98),
          child: SizedBox(
            width: 234,
            height: 351,
            child: PageView.builder(
              controller: _pageController,
              itemCount: movies.length,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: _buildCarouselMovieCard(context, movies[index], index),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            movies.length,
            (index) => Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color:
                    _currentPage == index ? AppColors.yellow : AppColors.grey,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCarouselMovieCard(
    BuildContext context,
    Map<String, dynamic> movie,
    int index,
  ) {
    return Container(
      width: 234,
      height: 351,
      decoration: BoxDecoration(
        color: AppColors.grey,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            Image.asset(
              movie['image'] as String,
              width: 234,
              height: 351,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 234,
                  height: 351,
                  color: AppColors.grey,
                  child: const Center(
                    child: Icon(
                      Icons.movie,
                      color: AppColors.white,
                      size: 64,
                    ),
                  ),
                );
              },
            ),
            Positioned(
              top: 16,
              left: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.Black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      AppAssets.rateIcon,
                      width: 16,
                      height: 16,
                      color: AppColors.yellow,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.star,
                          color: AppColors.yellow,
                          size: 16,
                        );
                      },
                    ),
                    const SizedBox(width: 4),
                    Text(
                      movie['rating'] as String,
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWatchNowSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Image.asset(
            AppAssets.watchNowTxt,
            fit: BoxFit.contain,
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Action',
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              TextButton(
                onPressed: () {},
                child: Text(
                  'See More →',
                  style: TextStyle(
                    color: AppColors.yellow,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 220,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(left: 178),
            itemCount: 5,
            itemBuilder: (context, index) {
              return _buildMovieCard(context, index);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMovieCard(BuildContext context, int index) {
    return Container(
      width: 146,
      height: 220,
      margin: const EdgeInsets.only(right: 12),
      child: Stack(
        children: [
          Container(
            width: 146,
            height: 220,
            decoration: BoxDecoration(
              color: AppColors.grey,
              borderRadius: BorderRadius.circular(8),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                'assets/images/onboarding${(index % 6) + 1}.png',
                width: 146,
                height: 220,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 146,
                    height: 220,
                    color: AppColors.grey,
                    child: Center(
                      child: Icon(
                        Icons.movie,
                        color: AppColors.white,
                        size: 32,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          // Rating badge
          Positioned(
            top: 8,
            left: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.Black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.star,
                    color: AppColors.yellow,
                    size: 12,
                  ),
                  const SizedBox(width: 2),
                  Text(
                    '7.7',
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
