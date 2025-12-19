import 'package:flutter/material.dart';
import 'package:movie/core/theme/app_colors.dart';
import 'package:movie/core/theme/app_assets.dart';
import 'package:movie/core/services/user_service.dart';
import 'package:movie/core/models/user_model.dart';
import 'package:movie/core/api/api_service.dart';
import 'package:movie/core/api/models/movie_model.dart';
import 'package:movie/core/api/models/favorite_movie_model.dart';
import 'package:movie/core/services/history_service.dart';
import 'package:movie/core/utils/responsive.dart';
import 'package:movie/screens/home/update_profile_tab.dart';
import 'package:movie/screens/auth/login_screen.dart';
import 'package:movie/screens/home/movie_details_screen.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> with WidgetsBindingObserver {
  int _selectedTabIndex = 0;
  UserModel? _user;
  final UserService _userService = UserService();
  final ApiService _apiService = ApiService();
  final HistoryService _historyService = HistoryService();
  bool _isLoading = false;
  List<FavoriteMovieModel> _favorites = [];
  List<MovieModel> _history = [];
  bool _isLoadingFavorites = false;
  bool _isLoadingHistory = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadUserData();
    _loadFavorites();
    _loadHistory();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadFavorites();
      _loadHistory();
    }
  }

  Future<void> _loadFavorites() async {
    final token = await _userService.getToken();
    if (token == null || token.isEmpty) {
      return;
    }

    setState(() {
      _isLoadingFavorites = true;
    });

    try {
      final response = await _apiService.getFavorites(token);
      if (mounted) {
        setState(() {
          _favorites = response.favorites;
          _isLoadingFavorites = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingFavorites = false;
        });
      }
    }
  }

  Future<void> _loadHistory() async {
    setState(() {
      _isLoadingHistory = true;
    });

    try {
      final history = await _historyService.getHistory();
      if (mounted) {
        setState(() {
          _history = history;
          _isLoadingHistory = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingHistory = false;
        });
      }
    }
  }

  Future<void> _loadUserData() async {
    final localUser = await _userService.getUser();
    if (mounted) {
      setState(() {
        _user = localUser;
      });
    }

    final token = await _userService.getToken();
    if (token != null && token.isNotEmpty) {
      setState(() {
        _isLoading = true;
      });

      try {
        final response = await _apiService.getProfile(token);
        if (response.data != null) {
          final user = UserModel(
            id: response.data!.id,
            name: response.data!.name,
            email: response.data!.email,
            phone: response.data!.phone,
            avatarId: response.data!.avaterId,
            token: token,
          );
          await _userService.updateUser(user);

          if (mounted) {
            setState(() {
              _user = user;
              _isLoading = false;
            });
          }
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.Black,
        body: const Center(
          child: CircularProgressIndicator(
            color: AppColors.yellow,
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.Black,
      body: SafeArea(
        child: Column(
          children: [
            _buildProfileInfoSection(),
            const SizedBox(height: 16),
            _buildActionButtons(),
            const SizedBox(height: 16),
            _buildTabs(),
            Expanded(
                  child: _selectedTabIndex == 0
                      ? _buildWatchListContent()
                      : _buildHistoryContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileInfoSection() {
    final List<String> avatars = [
      AppAssets.avatar1,
      AppAssets.avatar2,
      AppAssets.avatar3,
      AppAssets.avatar4,
      AppAssets.avatar5,
      AppAssets.avatar6,
      AppAssets.avatar7,
      AppAssets.avatar8,
      AppAssets.avatar9,
    ];

    final avatarIndex = (_user?.avatarId ?? 1) - 1;
    final userName = _user?.name ?? 'User';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
            ),
            child: ClipOval(
              child: Image.asset(
                avatars[avatarIndex.clamp(0, avatars.length - 1)],
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: AppColors.grey,
                    child: const Icon(
                      Icons.person,
                      size: 40,
                      color: AppColors.white,
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userName,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildStatItem('${_favorites.length}', 'Wish List'),
                    const SizedBox(width: 16),
                    _buildStatItem('${_history.length}', 'History'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String number, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          number,
          style: const TextStyle(
            color: AppColors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: () async {
                final result = await Navigator.pushNamed(
                  context,
                  UpdateProfileTab.routeName,
                );
                // Reload data after returning if update was successful
                if (result == true) {
                  _loadUserData();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.yellow,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text(
                'Edit Profile',
                style: TextStyle(
                  color: AppColors.Black,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: () {
              _showExitDialog();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.Red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(
                  Icons.exit_to_app,
                  color: AppColors.white,
                  size: 20,
                ),
                SizedBox(width: 4),
                Text(
                  'Exit',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          Expanded(
            child: _buildTabButton(
              index: 0,
              label: 'Watch List',
              icon: Icons.list,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildTabButton(
              index: 1,
              label: 'History',
              icon: Icons.folder,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton({
    required int index,
    required String label,
    required IconData icon,
  }) {
    final isSelected = _selectedTabIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTabIndex = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? AppColors.yellow : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.yellow : Colors.grey,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppColors.yellow : Colors.grey,
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWatchListContent() {
    if (_isLoadingFavorites) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppColors.yellow,
        ),
      );
    }

    if (_favorites.isEmpty) {
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
                  Icons.local_movies,
                  size: 100,
                  color: Colors.grey,
                );
              },
            ),
            const SizedBox(height: 24),
            const Text(
              'Your watch list is empty',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

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
        itemCount: _favorites.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () async {
              final movieId = int.tryParse(_favorites[index].movieId);
              if (movieId != null) {
                await Navigator.pushNamed(
                  context,
                  MovieDetailsScreen.routeName,
                  arguments: movieId,
                );
                if (mounted) {
                  _loadFavorites();
                }
              }
            },
            child: _buildFavoriteMoviePoster(_favorites[index], cardWidth, cardHeight),
          );
        },
      ),
    );
  }

  Widget _buildHistoryContent() {
    if (_isLoadingHistory) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppColors.yellow,
        ),
      );
    }

    if (_history.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              AppAssets.historyFolderIcon,
              width: 200,
              height: 200,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(
                  Icons.history,
                  size: 100,
                  color: Colors.grey,
                );
              },
            ),
            const SizedBox(height: 24),
            const Text(
              'Your history is empty',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

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
        itemCount: _history.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () async {
              await Navigator.pushNamed(
                context,
                MovieDetailsScreen.routeName,
                arguments: _history[index].id,
              );
              if (mounted) {
                _loadHistory();
              }
            },
            child: _buildMoviePoster(_history[index], cardWidth, cardHeight),
          );
        },
      ),
    );
  }

  Widget _buildFavoriteMoviePoster(FavoriteMovieModel movie, double width, double height) {
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
            child: movie.imageURL.isNotEmpty
                ? Image.network(
                    movie.imageURL,
                    width: width,
                    height: height,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: AppColors.grey,
                        child: const Center(
                          child: Icon(
                            Icons.movie,
                            color: AppColors.white,
                            size: 40,
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
                        size: 40,
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

  Widget _buildMoviePoster(MovieModel movie, double width, double height) {
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
                      return Container(
                        color: AppColors.grey,
                        child: const Center(
                          child: Icon(
                            Icons.movie,
                            color: AppColors.white,
                            size: 40,
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
                        size: 40,
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

  void _showExitDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.grey,
          title: const Text(
            'Exit',
            style: TextStyle(
              color: AppColors.white,
            ),
          ),
          content: const Text(
            'Are you sure you want to exit?',
            style: TextStyle(
              color: AppColors.white,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: AppColors.white,
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                await _userService.clearUser();
                if (mounted) {
                  Navigator.pop(context);
                  Navigator.pushReplacementNamed(
                    context,
                    LoginScreen.routeName,
                  );
                }
              },
              child: const Text(
                'Exit',
                style: TextStyle(
                  color: AppColors.Red,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
