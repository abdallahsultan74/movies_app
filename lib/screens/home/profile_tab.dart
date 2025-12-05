import 'package:flutter/material.dart';
import 'package:movie/core/theme/app_colors.dart';
import 'package:movie/core/theme/app_assets.dart';
import 'package:movie/core/services/user_service.dart';
import 'package:movie/core/models/user_model.dart';
import 'package:movie/core/api/api_service.dart';
import 'package:movie/screens/home/update_profile_tab.dart';
import 'package:movie/screens/auth/login_screen.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  int _selectedTabIndex = 0;
  UserModel? _user;
  final UserService _userService = UserService();
  final ApiService _apiService = ApiService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
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
                    _buildStatItem('12', 'Wish List'),
                    const SizedBox(width: 16),
                    _buildStatItem('10', 'History'),
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

  Widget _buildHistoryContent() {
    final List<Map<String, dynamic>> movies = [
      {'name': 'Black Widow', 'rating': '7.7'},
      {'name': 'Hobbs & Shaw', 'rating': '7.7'},
      {'name': '1917', 'rating': '7.7'},
      {'name': 'Avengers', 'rating': '7.7'},
      {'name': 'Avengers', 'rating': '7.7'},
      {'name': 'Black Widow', 'rating': '7.7'},
      {'name': 'Black Panther', 'rating': '7.7'},
      {'name': 'Doctor Strange', 'rating': '7.7'},
      {'name': 'Doctor Who', 'rating': '7.7'},
      {'name': 'Godzilla', 'rating': '7.7'},
      {'name': 'Wednesday', 'rating': '7.7'},
      {'name': 'Movie', 'rating': '7.7'},
    ];

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.7,
        ),
        itemCount: movies.length,
        itemBuilder: (context, index) {
          return _buildMoviePoster(movies[index], index);
        },
      ),
    );
  }

  Widget _buildMoviePoster(Map<String, dynamic> movie, int index) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            color: AppColors.grey,
            borderRadius: BorderRadius.circular(8),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              'assets/images/onboarding${(index % 6) + 1}.png',
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
                  movie['rating'] ?? '7.7',
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
