import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie/core/api/models/movie_model.dart';
import 'package:movie/core/bloc/movies/movies_bloc.dart';
import 'package:movie/core/bloc/movies/movies_event.dart';
import 'package:movie/core/bloc/movies/movies_state.dart';
import 'package:movie/core/theme/app_colors.dart';
import 'package:movie/core/utils/responsive.dart';
import 'package:movie/core/api/api_service.dart';
import 'package:movie/core/services/user_service.dart';
import 'package:movie/core/services/history_service.dart';

class MovieDetailsScreen extends StatefulWidget {
  static const routeName = '/movie_details';

  const MovieDetailsScreen({super.key});

  @override
  State<MovieDetailsScreen> createState() => _MovieDetailsScreenState();
}

class _MovieDetailsScreenState extends State<MovieDetailsScreen> {
  int? _lastLoadedMovieId;
  MovieModel? _cachedMovie;
  bool _isFavorite = false;
  bool _isLoadingFavorite = false;
  final ApiService _apiService = ApiService();
  final UserService _userService = UserService();
  final HistoryService _historyService = HistoryService();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final movieId = ModalRoute.of(context)!.settings.arguments as int;
    if (_lastLoadedMovieId != movieId) {
      _lastLoadedMovieId = movieId;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          context.read<MoviesBloc>().add(LoadMovieDetailsEvent(movieId));
          context.read<MoviesBloc>().add(LoadMovieSuggestionsEvent(movieId));
          _checkFavoriteStatus(movieId);
        }
      });
    }
  }

  Future<void> _checkFavoriteStatus(int movieId) async {
    final user = await _userService.getUser();
    if (user == null) return;
    
    final token = user.token;
    if (token == null || token.isEmpty) return;

    try {
      final response = await _apiService.isFavorite(movieId, token);
      if (mounted) {
        setState(() {
          _isFavorite = response.isFavorite;
        });
      }
    } catch (e) {
      // Silent fail - user might not have favorites yet
    }
  }

  Future<void> _toggleFavorite(MovieModel movie) async {
    final user = await _userService.getUser();
    if (user == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please login to add favorites'),
            backgroundColor: AppColors.Red,
          ),
        );
      }
      return;
    }
    
    final token = user.token;
    if (token == null || token.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please login to add favorites'),
            backgroundColor: AppColors.Red,
          ),
        );
      }
      return;
    }

    setState(() {
      _isLoadingFavorite = true;
    });

    try {
      if (_isFavorite) {
        await _apiService.removeFavorite(movie.id, token);
      } else {
        await _apiService.addFavorite(movie, token);
      }

      if (mounted) {
        setState(() {
          _isFavorite = !_isFavorite;
          _isLoadingFavorite = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isFavorite
                ? 'Added to favorites'
                : 'Removed from favorites'),
            backgroundColor: AppColors.yellow,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingFavorite = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: AppColors.Red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final movieId = ModalRoute.of(context)!.settings.arguments as int;

    return Scaffold(
      backgroundColor: AppColors.Black,
      body: BlocBuilder<MoviesBloc, MoviesState>(
        buildWhen: (previous, current) {
          return current is MovieDetailsLoading ||
              current is MovieDetailsLoaded ||
              current is MovieDetailsError ||
              current is MovieSuggestionsLoading ||
              current is MovieSuggestionsLoaded ||
              current is MovieSuggestionsError;
        },
        builder: (context, state) {
          if (state is MovieDetailsLoaded && state.movie.id == movieId) {
            _cachedMovie = state.movie;
            _historyService.addToHistory(state.movie);
          }

          if (state is MovieDetailsLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.yellow,
              ),
            );
          }

          if (state is MovieDetailsError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    state.message,
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<MoviesBloc>().add(LoadMovieDetailsEvent(movieId));
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

          if (state is MovieDetailsLoaded && state.movie.id == movieId) {
            return _buildMovieDetailsContent(context, state.movie);
          }

          if (_cachedMovie != null && _cachedMovie!.id == movieId) {
            return _buildMovieDetailsContent(context, _cachedMovie!);
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildMovieDetailsContent(BuildContext context, MovieModel movie) {
    return CustomScrollView(
      slivers: [
        _buildAppBar(context, movie),
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.all(
              Responsive.getResponsiveValue(
                context,
                mobile: 16.0,
                tablet: 24.0,
                desktop: 32.0,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildMovieTitleAndYear(context, movie),
                const SizedBox(height: 24),
                _buildWatchButton(context),
                const SizedBox(height: 24),
                _buildEngagementStats(context, movie),
                const SizedBox(height: 24),
                _buildScreenShots(context, movie),
                const SizedBox(height: 24),
                _buildSuggestions(context, movie.id),
                const SizedBox(height: 24),
                _buildMovieDescription(context, movie),
                const SizedBox(height: 24),
                _buildGenres(context, movie),
                const SizedBox(height: 24),
                _buildCast(context, movie),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAppBar(BuildContext context, MovieModel movie) {
    final imageHeight = Responsive.getResponsiveValue(
      context,
      mobile: 400.0,
      tablet: 500.0,
      desktop: 600.0,
    );

    return SliverAppBar(
      expandedHeight: imageHeight,
      pinned: true,
      backgroundColor: AppColors.Black,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: AppColors.white),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: _isLoadingFavorite
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: AppColors.white,
                    strokeWidth: 2,
                  ),
                )
              : Icon(
                  _isFavorite ? Icons.bookmark : Icons.bookmark_border,
                  color: AppColors.white,
                ),
          onPressed: () => _toggleFavorite(movie),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        title: const Text(
          'Movie Details',
          style: TextStyle(
            color: AppColors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: false,
        titlePadding: const EdgeInsets.only(left: 56, bottom: 16),
        background: Stack(
          fit: StackFit.expand,
          children: [
            movie.largeCoverImage?.isNotEmpty == true
                ? Image.network(
                    movie.largeCoverImage!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
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
                : Container(
                    color: AppColors.grey,
                    child: const Center(
                      child: Icon(
                        Icons.movie,
                        color: AppColors.white,
                        size: 64,
                      ),
                    ),
                  ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    AppColors.Black.withOpacity(0.7),
                    AppColors.Black,
                  ],
                ),
              ),
            ),
            Center(
              child: Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.yellow,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.play_arrow,
                  color: AppColors.Black,
                  size: 40,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMovieTitleAndYear(BuildContext context, MovieModel movie) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          movie.title,
          style: TextStyle(
            color: AppColors.white,
            fontSize: Responsive.getResponsiveFontSize(
              context,
              mobile: 24.0,
              tablet: 28.0,
              desktop: 32.0,
            ),
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '${movie.year}',
          style: TextStyle(
            color: AppColors.white.withOpacity(0.7),
            fontSize: Responsive.getResponsiveFontSize(
              context,
              mobile: 16.0,
              tablet: 18.0,
              desktop: 20.0,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWatchButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: () {
          // Handle watch action
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.Red,
          foregroundColor: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: TextStyle(
            fontSize: Responsive.getResponsiveFontSize(
              context,
              mobile: 16.0,
              tablet: 18.0,
              desktop: 20.0,
            ),
            fontWeight: FontWeight.bold,
          ),
        ),
        child: const Text('Watch'),
      ),
    );
  }

  Widget _buildEngagementStats(BuildContext context, MovieModel movie) {
    final runtime = 90; // Default runtime, can be fetched from API if available

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildStatItem(
          context,
          icon: Icons.favorite,
          value: '15',
          color: AppColors.yellow,
        ),
        _buildStatItem(
          context,
          icon: Icons.access_time,
          value: '$runtime',
          color: AppColors.yellow,
        ),
        _buildStatItem(
          context,
          icon: Icons.star,
          value: movie.rating.toStringAsFixed(1),
          color: AppColors.yellow,
        ),
      ],
    );
  }

  Widget _buildStatItem(
    BuildContext context, {
    required IconData icon,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.grey,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Text(
            value,
            style: TextStyle(
              color: AppColors.white,
              fontSize: Responsive.getResponsiveFontSize(
                context,
                mobile: 14.0,
                tablet: 16.0,
                desktop: 18.0,
              ),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMovieDescription(BuildContext context, MovieModel movie) {
    final description = movie.descriptionFull ?? movie.summary;
    
    if (description.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Summary',
          style: TextStyle(
            color: AppColors.white,
            fontSize: Responsive.getResponsiveFontSize(
              context,
              mobile: 20.0,
              tablet: 22.0,
              desktop: 24.0,
            ),
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          description,
          style: TextStyle(
            color: AppColors.white.withOpacity(0.8),
            fontSize: Responsive.getResponsiveFontSize(
              context,
              mobile: 14.0,
              tablet: 16.0,
              desktop: 18.0,
            ),
            height: 1.6,
          ),
        ),
      ],
    );
  }

  Widget _buildCast(BuildContext context, MovieModel movie) {
    final List<Map<String, String>> castMembers = [
      {'name': 'Hayley Atwell', 'character': 'Captain Carter'},
      {'name': 'Elizabeth Olsen', 'character': 'Wanda Maximoff / The Scarlet Witch'},
      {'name': 'Rachel McAdams', 'character': 'Dr. Christine Palmer'},
      {'name': 'Charlize Theron', 'character': 'Clea'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Cast',
          style: TextStyle(
            color: AppColors.white,
            fontSize: Responsive.getResponsiveFontSize(
              context,
              mobile: 20.0,
              tablet: 22.0,
              desktop: 24.0,
            ),
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...castMembers.map((cast) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.grey,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: AppColors.Black,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.person,
                    color: AppColors.white,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Name : ${cast['name']}',
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: Responsive.getResponsiveFontSize(
                            context,
                            mobile: 14.0,
                            tablet: 16.0,
                            desktop: 18.0,
                          ),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Character : ${cast['character']}',
                        style: TextStyle(
                          color: AppColors.white.withOpacity(0.7),
                          fontSize: Responsive.getResponsiveFontSize(
                            context,
                            mobile: 12.0,
                            tablet: 14.0,
                            desktop: 16.0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildGenres(BuildContext context, MovieModel movie) {
    if (movie.genres.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Genres',
          style: TextStyle(
            color: AppColors.white,
            fontSize: Responsive.getResponsiveFontSize(
              context,
              mobile: 20.0,
              tablet: 22.0,
              desktop: 24.0,
            ),
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: movie.genres.map((genre) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.yellow.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.yellow, width: 1),
              ),
              child: Text(
                genre,
                style: TextStyle(
                  color: AppColors.yellow,
                  fontSize: Responsive.getResponsiveFontSize(
                    context,
                    mobile: 12.0,
                    tablet: 14.0,
                    desktop: 16.0,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildScreenShots(BuildContext context, MovieModel movie) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Screen Shots',
          style: TextStyle(
            color: AppColors.white,
            fontSize: Responsive.getResponsiveFontSize(
              context,
              mobile: 20.0,
              tablet: 22.0,
              desktop: 24.0,
            ),
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: Responsive.getResponsiveValue(
            context,
            mobile: 150.0,
            tablet: 200.0,
            desktop: 250.0,
          ),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 3,
            itemBuilder: (context, index) {
              return Container(
                width: Responsive.getResponsiveValue(
                  context,
                  mobile: 250.0,
                  tablet: 350.0,
                  desktop: 450.0,
                ),
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  color: AppColors.grey,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: movie.largeCoverImage?.isNotEmpty == true
                      ? Image.network(
                          movie.largeCoverImage!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: AppColors.grey,
                              child: const Center(
                                child: Icon(
                                  Icons.image,
                                  color: AppColors.white,
                                  size: 48,
                                ),
                              ),
                            );
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
                      : movie.mediumCoverImage.isNotEmpty
                          ? Image.network(
                              movie.mediumCoverImage,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: AppColors.grey,
                                  child: const Center(
                                    child: Icon(
                                      Icons.image,
                                      color: AppColors.white,
                                      size: 48,
                                    ),
                                  ),
                                );
                              },
                            )
                          : Container(
                              color: AppColors.grey,
                              child: const Center(
                                child: Icon(
                                  Icons.image,
                                  color: AppColors.white,
                                  size: 48,
                                ),
                              ),
                            ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSuggestions(BuildContext context, int movieId) {
    return BlocBuilder<MoviesBloc, MoviesState>(
      builder: (context, state) {
        if (state is MovieSuggestionsLoading) {
          return const Center(
            child: CircularProgressIndicator(
              color: AppColors.yellow,
            ),
          );
        }

        if (state is MovieSuggestionsError) {
          return const SizedBox.shrink();
        }

        if (state is MovieSuggestionsLoaded) {
          final suggestions = state.suggestions;
          
          if (suggestions.isEmpty) {
            return const SizedBox.shrink();
          }

          final cardWidth = Responsive.getResponsiveValue(
            context,
            mobile: 120.0,
            tablet: 150.0,
            desktop: 180.0,
          );
          
          final cardHeight = Responsive.getResponsiveValue(
            context,
            mobile: 180.0,
            tablet: 225.0,
            desktop: 270.0,
          );

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Similar',
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: Responsive.getResponsiveFontSize(
                    context,
                    mobile: 20.0,
                    tablet: 22.0,
                    desktop: 24.0,
                  ),
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: cardWidth / cardHeight,
                ),
                itemCount: suggestions.length > 4 ? 4 : suggestions.length,
                itemBuilder: (context, index) {
                  final suggestion = suggestions[index];
                  return GestureDetector(
                      onTap: () {
                        Navigator.pushReplacementNamed(
                          context,
                          MovieDetailsScreen.routeName,
                          arguments: suggestion.id,
                        );
                      },
                      child: Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: AppColors.grey,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: suggestion.mediumCoverImage.isNotEmpty
                                  ? Image.network(
                                      suggestion.mediumCoverImage,
                                      width: cardWidth,
                                      height: cardHeight,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Container(
                                          width: cardWidth,
                                          height: cardHeight,
                                          color: AppColors.grey,
                                          child: const Center(
                                            child: Icon(
                                              Icons.movie,
                                              color: AppColors.white,
                                              size: 32,
                                            ),
                                          ),
                                        );
                                      },
                                      loadingBuilder: (context, child, loadingProgress) {
                                        if (loadingProgress == null) return child;
                                        return Container(
                                          width: cardWidth,
                                          height: cardHeight,
                                          color: AppColors.grey,
                                          child: Center(
                                            child: CircularProgressIndicator(
                                              value: loadingProgress.expectedTotalBytes != null
                                                  ? loadingProgress.cumulativeBytesLoaded /
                                                      loadingProgress.expectedTotalBytes!
                                                  : null,
                                              color: AppColors.yellow,
                                            ),
                                          ),
                                        );
                                      },
                                    )
                                  : Container(
                                      width: cardWidth,
                                      height: cardHeight,
                                      color: AppColors.grey,
                                      child: const Center(
                                        child: Icon(
                                          Icons.movie,
                                          color: AppColors.white,
                                          size: 32,
                                        ),
                                      ),
                                    ),
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
                                    suggestion.rating.toStringAsFixed(1),
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
                },
              ),
            ],
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}
