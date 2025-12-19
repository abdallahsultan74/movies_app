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

class BrowseTab extends StatefulWidget {
  const BrowseTab({super.key});

  @override
  State<BrowseTab> createState() => _BrowseTabState();
}

class _BrowseTabState extends State<BrowseTab> {
  Set<String> _genres = {};
  String? _selectedGenre;
  bool _isLoadingGenres = true;

  @override
  void initState() {
    super.initState();
    _loadGenres();
  }

  Future<void> _loadGenres() async {
    if (_genres.isNotEmpty) {
      return;
    }
    
    setState(() {
      _isLoadingGenres = true;
    });

    context.read<MoviesBloc>().add(const LoadMoviesEvent(limit: 50));
  }

  void _loadMoviesByGenre(String genre) {
    setState(() {
      _selectedGenre = genre;
    });
    context.read<MoviesBloc>().add(
          LoadMoviesEvent(
            limit: 50,
            genre: genre,
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
                    'Browse',
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
            if (_isLoadingGenres)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(
                  child: CircularProgressIndicator(
                    color: AppColors.yellow,
                  ),
                ),
              )
            else if (_genres.isEmpty)
              const Expanded(
                child: Center(
                  child: Text(
                    'No genres available',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              )
            else
              Column(
                children: [
                  SizedBox(
                    height: 50,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _genres.length,
                      itemBuilder: (context, index) {
                        final genre = _genres.elementAt(index);
                        final isSelected = _selectedGenre == genre;
                        return Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: ElevatedButton(
                            onPressed: () => _loadMoviesByGenre(genre),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isSelected
                                  ? AppColors.yellow
                                  : AppColors.grey,
                              foregroundColor: isSelected
                                  ? AppColors.Black
                                  : AppColors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                            ),
                            child: Text(
                              genre,
                              style: TextStyle(
                                fontSize: Responsive.getResponsiveFontSize(
                                  context,
                                  mobile: 14.0,
                                  tablet: 16.0,
                                  desktop: 18.0,
                                ),
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: BlocBuilder<MoviesBloc, MoviesState>(
                      buildWhen: (previous, current) {
                        return current is MoviesLoading ||
                            current is MoviesLoaded ||
                            current is MoviesError;
                      },
                      builder: (context, state) {
                        if (state is MoviesLoading && _isLoadingGenres) {
                          return const Center(
                            child: CircularProgressIndicator(
                              color: AppColors.yellow,
                            ),
                          );
                        }

                        if (state is MoviesLoaded) {
                          if (_isLoadingGenres) {
                            final genresSet = <String>{};
                            for (var movie in state.movies) {
                              genresSet.addAll(movie.genres);
                            }
                            
                            String? firstGenre;
                            if (genresSet.isNotEmpty && _selectedGenre == null) {
                              firstGenre = genresSet.first;
                            }
                            
                            if (firstGenre != null) {
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                if (mounted) {
                                  setState(() {
                                    _genres = genresSet;
                                    _selectedGenre = firstGenre;
                                    _isLoadingGenres = false;
                                  });
                                }
                              });
                              
                              final filteredMovies = state.movies.where((movie) => 
                                movie.genres.contains(firstGenre)
                              ).toList();
                              
                              if (filteredMovies.isEmpty) {
                                return Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.movie_outlined,
                                        color: Colors.grey,
                                        size: 64,
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        'No movies found in $firstGenre',
                                        style: const TextStyle(
                                          color: Colors.grey,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }
                              
                              return _buildMoviesGrid(filteredMovies);
                            } else {
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                if (mounted) {
                                  setState(() {
                                    _genres = genresSet;
                                    _isLoadingGenres = false;
                                  });
                                }
                              });
                              
                              return const Center(
                                child: CircularProgressIndicator(
                                  color: AppColors.yellow,
                                ),
                              );
                            }
                          }

                          final movies = _selectedGenre != null
                              ? state.movies.where((movie) => 
                                  movie.genres.contains(_selectedGenre)
                                ).toList()
                              : state.movies;

                          if (movies.isEmpty) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.movie_outlined,
                                    color: Colors.grey,
                                    size: 64,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No movies found in $_selectedGenre',
                                    style: const TextStyle(
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

                        if (state is MoviesError) {
                          if (_isLoadingGenres) {
                            setState(() {
                              _isLoadingGenres = false;
                            });
                          }
                          
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
                                  onPressed: () {
                                    if (_selectedGenre != null) {
                                      _loadMoviesByGenre(_selectedGenre!);
                                    } else {
                                      _loadGenres();
                                    }
                                  },
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

                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMoviesGrid(List<MovieModel> movies) {
    final screenWidth = MediaQuery.of(context).size.width;
    final padding = 32.0;
    final spacing = 12.0;
    final cardWidth = (screenWidth - padding - spacing) / 2;

    final cardHeight = Responsive.getResponsiveValue(
      context,
      mobile: 280.0,
      tablet: 320.0,
      desktop: 360.0,
    );

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: spacing,
          mainAxisSpacing: spacing,
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
