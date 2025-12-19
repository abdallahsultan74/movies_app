import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie/core/api/models/movie_model.dart';
import 'package:movie/core/bloc/movies/movies_bloc.dart';
import 'package:movie/core/bloc/movies/movies_event.dart';
import 'package:movie/core/bloc/movies/movies_state.dart';
import 'package:movie/core/theme/app_colors.dart';
import 'package:movie/core/theme/app_assets.dart';
import 'package:movie/core/utils/responsive.dart';
import 'package:movie/screens/home/movie_details_screen.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> with WidgetsBindingObserver {
  final PageController _pageController = PageController(viewportFraction: 0.85);
  int _currentPage = 0;
  double _currentPageValue = 0.0;
  bool _hasLoadedMovies = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _pageController.addListener(() {
      setState(() {
        _currentPageValue = _pageController.page ?? 0.0;
        _currentPage = _currentPageValue.round();
      });
    });
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadMovies();
      }
    });
  }

  void _loadMovies({bool force = false}) {
    if (force || !_hasLoadedMovies) {
      _hasLoadedMovies = true;
      context.read<MoviesBloc>().add(
        const LoadMoviesEvent(
          limit: 20,
          sortBy: 'rating',
        ),
      );
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed && mounted) {
      _hasLoadedMovies = false;
      _loadMovies();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.Black,
      body: BlocBuilder<MoviesBloc, MoviesState>(
        buildWhen: (previous, current) {
          return current is MoviesLoading ||
              current is MoviesLoaded ||
              current is MoviesError ||
              (previous is MoviesLoaded && current is! MoviesLoaded);
        },
        builder: (context, state) {
          if (state is MoviesLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.yellow,
              ),
            );
          }

          if (state is MoviesError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.wifi_off,
                      size: 64,
                      color: AppColors.white.withOpacity(0.5),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      state.message,
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: () {
                        context.read<MoviesBloc>().add(
                              const LoadMoviesEvent(
                                limit: 20,
                                sortBy: 'rating',
                              ),
                            );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.yellow,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Retry',
                        style: TextStyle(
                          color: AppColors.Black,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          if (state is MoviesLoaded) {
            final movies = state.movies;
            
            if (movies.isEmpty) {
              return const Center(
                child: Text(
                  'No movies available',
                  style: TextStyle(color: AppColors.white),
                ),
              );
            }

            final carouselMovies = movies.take(6).toList();
            final watchNowMovies = movies.skip(6).toList();

            return Stack(
              children: [
                _buildBackgroundWithBlur(carouselMovies),
                SafeArea(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildAvailableNowSection(context, carouselMovies),
                        const SizedBox(height: 24),
                        _buildWatchNowSection(context, watchNowMovies),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildBackgroundWithBlur(List<MovieModel> movies) {
    if (movies.isEmpty) return const SizedBox.shrink();
    
    final currentIndex = _currentPageValue.round().clamp(0, movies.length - 1);
    final currentMovie = movies[currentIndex];
    final imageUrl = currentMovie.mediumCoverImage;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: Positioned.fill(
        key: ValueKey<String>(imageUrl),
        child: ImageFiltered(
          imageFilter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(
            decoration: BoxDecoration(
              image: imageUrl.isNotEmpty
                  ? DecorationImage(
                      image: NetworkImage(imageUrl),
                      fit: BoxFit.cover,
                      opacity: 0.7,
                      onError: (_, __) {},
                    )
                  : null,
              color: AppColors.Black,
            ),
            child: Container(
              color: AppColors.Black.withOpacity(0.4),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvailableNowSection(
    BuildContext context,
    List<MovieModel> movies,
  ) {
    final screenWidth = Responsive.screenWidth(context);
    
    final imageWidth = Responsive.getResponsiveValue(
      context,
      mobile: 267.0,
      tablet: 350.0,
      desktop: 400.0,
    );
    
    final imageHeight = Responsive.getResponsiveValue(
      context,
      mobile: 93.0,
      tablet: 120.0,
      desktop: 140.0,
    );
    
    final carouselWidth = Responsive.getResponsiveValue(
      context,
      mobile: 234.0,
      tablet: 300.0,
      desktop: 350.0,
    );
    
    final carouselHeight = Responsive.getResponsiveValue(
      context,
      mobile: 351.0,
      tablet: 450.0,
      desktop: 525.0,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(
            left: Responsive.getResponsiveValue(
              context,
              mobile: 81.0,
              tablet: screenWidth * 0.2,
              desktop: screenWidth * 0.25,
            ),
            top: 7,
          ),
          child: SizedBox(
            width: imageWidth,
            height: imageHeight,
            child: Image.asset(
              AppAssets.availableNowTxt,
              fit: BoxFit.contain,
            ),
          ),
        ),
        const SizedBox(height: 21),
        Padding(
          padding: EdgeInsets.only(
            left: Responsive.getResponsiveValue(
              context,
              mobile: 98.0,
              tablet: screenWidth * 0.25,
              desktop: screenWidth * 0.3,
            ),
          ),
          child: SizedBox(
            width: carouselWidth,
            height: carouselHeight,
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
                  child: GestureDetector(
                    onTap: () async {
                      await Navigator.pushNamed(
                        context,
                        MovieDetailsScreen.routeName,
                        arguments: movies[index].id,
                      );
                      if (mounted) {
                        _hasLoadedMovies = false;
                        _loadMovies(force: true);
                      }
                    },
                    child: _buildCarouselMovieCard(
                      context,
                      movies[index],
                      carouselWidth,
                      carouselHeight,
                    ),
                  ),
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
    MovieModel movie,
    double width,
    double height,
  ) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.grey,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            movie.mediumCoverImage.isNotEmpty
                ? Image.network(
                    movie.mediumCoverImage,
                    width: width,
                    height: height,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return _buildErrorPlaceholder(width, height);
                    },
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                          color: AppColors.yellow,
                        ),
                      );
                    },
                  )
                : _buildErrorPlaceholder(width, height),
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
                      movie.rating.toStringAsFixed(1),
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

  Widget _buildErrorPlaceholder(double width, double height) {
    return Container(
      width: width,
      height: height,
      color: AppColors.grey,
      child: const Center(
        child: Icon(
          Icons.movie,
          color: AppColors.white,
          size: 64,
        ),
      ),
    );
  }

  Widget _buildWatchNowSection(
    BuildContext context,
    List<MovieModel> movies,
  ) {
    if (movies.isEmpty) {
      return const SizedBox.shrink();
    }

    final cardWidth = Responsive.getResponsiveValue(
      context,
      mobile: 146.0,
      tablet: 180.0,
      desktop: 200.0,
    );
    
    final cardHeight = Responsive.getResponsiveValue(
      context,
      mobile: 220.0,
      tablet: 270.0,
      desktop: 300.0,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: Responsive.getResponsiveValue(
              context,
              mobile: 16.0,
              tablet: 24.0,
              desktop: 32.0,
            ),
          ),
          child: Image.asset(
            AppAssets.watchNowTxt,
            fit: BoxFit.contain,
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: Responsive.getResponsiveValue(
              context,
              mobile: 16.0,
              tablet: 24.0,
              desktop: 32.0,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Action',
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: Responsive.getResponsiveFontSize(
                    context,
                    mobile: 16.0,
                    tablet: 18.0,
                    desktop: 20.0,
                  ),
                  fontWeight: FontWeight.w500,
                ),
              ),
              TextButton(
                onPressed: () {},
                child: Text(
                  'See More →',
                  style: TextStyle(
                    color: AppColors.yellow,
                    fontSize: Responsive.getResponsiveFontSize(
                      context,
                      mobile: 14.0,
                      tablet: 16.0,
                      desktop: 18.0,
                    ),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: cardHeight,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.only(
              left: Responsive.getResponsiveValue(
                context,
                mobile: 178.0,
                tablet: 24.0,
                desktop: 32.0,
              ),
            ),
            itemCount: movies.length > 10 ? 10 : movies.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () async {
                  await Navigator.pushNamed(
                    context,
                    MovieDetailsScreen.routeName,
                    arguments: movies[index].id,
                  );
                  if (mounted) {
                    _hasLoadedMovies = false;
                    _loadMovies(force: true);
                  }
                },
                child: _buildMovieCard(
                  context,
                  movies[index],
                  cardWidth,
                  cardHeight,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMovieCard(
    BuildContext context,
    MovieModel movie,
    double width,
    double height,
  ) {
    return Container(
      width: width,
      height: height,
      margin: const EdgeInsets.only(right: 12),
      child: Stack(
        children: [
          Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              color: AppColors.grey,
              borderRadius: BorderRadius.circular(8),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: movie.mediumCoverImage.isNotEmpty
                  ? Image.network(
                      movie.mediumCoverImage,
                      width: width,
                      height: height,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return _buildErrorPlaceholder(width, height);
                      },
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                            color: AppColors.yellow,
                          ),
                        );
                      },
                    )
                  : _buildErrorPlaceholder(width, height),
            ),
          ),
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
                  const Icon(
                    Icons.star,
                    color: AppColors.yellow,
                    size: 12,
                  ),
                  const SizedBox(width: 2),
                  Text(
                    movie.rating.toStringAsFixed(1),
                    style: const TextStyle(
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
