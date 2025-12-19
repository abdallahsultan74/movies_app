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

class SearchTab extends StatefulWidget {
  const SearchTab({super.key});

  @override
  State<SearchTab> createState() => _SearchTabState();
}

class _SearchTabState extends State<SearchTab> {
  final TextEditingController _searchController = TextEditingController();
  String _currentQuery = '';
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _performSearch(String query) {
    if (query.trim().isEmpty) {
      setState(() {
        _currentQuery = '';
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _currentQuery = query.trim();
      _isSearching = true;
    });

    context.read<MoviesBloc>().add(
          LoadMoviesEvent(
            limit: 50,
            queryTerm: _currentQuery,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.Black,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Text(
                    'Search',
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: Responsive.getResponsiveFontSize(
                        context,
                        mobile: 20.0,
                        tablet: 24.0,
                        desktop: 28.0,
                      ),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.grey,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: TextField(
                        controller: _searchController,
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 14,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Search',
                          hintStyle: const TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                          prefixIcon: const Padding(
                            padding: EdgeInsets.all(12.0),
                            child: Icon(
                              Icons.search,
                              color: Colors.grey,
                              size: 20,
                            ),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: AppColors.grey,
                        ),
                        onSubmitted: _performSearch,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () => _performSearch(_searchController.text),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.yellow,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                    ),
                    child: const Text(
                      'Search',
                      style: TextStyle(
                        color: AppColors.Black,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: BlocBuilder<MoviesBloc, MoviesState>(
                buildWhen: (previous, current) {
                  if (!_isSearching) return false;
                  return current is MoviesLoading ||
                      current is MoviesLoaded ||
                      current is MoviesError;
                },
                builder: (context, state) {
                  if (!_isSearching || _currentQuery.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            AppAssets.popcorn,
                            width: 200,
                            height: 200,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(
                                Icons.search,
                                size: 100,
                                color: Colors.grey,
                              );
                            },
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            'Search for movies',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  if (state is MoviesLoading) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.yellow,
                      ),
                    );
                  }

                  if (state is MoviesError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            color: Colors.grey,
                            size: 64,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            state.message,
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 16,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: () => _performSearch(_currentQuery),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.yellow,
                            ),
                            child: const Text(
                              'Retry',
                              style: TextStyle(color: AppColors.Black),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  if (state is MoviesLoaded) {
                    final movies = state.movies;

                    if (movies.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.search_off,
                              color: Colors.grey,
                              size: 64,
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'No movies found',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return _buildMoviesGrid(movies);
                  }

                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMoviesGrid(List<MovieModel> movies) {
    final cardWidth = Responsive.getResponsiveValue(
      context,
      mobile: (MediaQuery.of(context).size.width - 48) / 3,
      tablet: 150.0,
      desktop: 180.0,
    );

    final cardHeight = Responsive.getResponsiveValue(
      context,
      mobile: 220.0,
      tablet: 270.0,
      desktop: 300.0,
    );

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: cardWidth / cardHeight,
        ),
        itemCount: movies.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () async {
              await Navigator.pushNamed(
                context,
                MovieDetailsScreen.routeName,
                arguments: movies[index].id,
              );
            },
            child: _buildMovieCard(movies[index], cardWidth, cardHeight),
          );
        },
      ),
    );
  }

  Widget _buildMovieCard(MovieModel movie, double width, double height) {
    return Stack(
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
                Image.asset(
                  AppAssets.rateIcon,
                  width: 12,
                  height: 12,
                  color: AppColors.yellow,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(
                      Icons.star,
                      color: AppColors.yellow,
                      size: 12,
                    );
                  },
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
          size: 32,
        ),
      ),
    );
  }
}
