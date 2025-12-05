import 'package:flutter/material.dart';
import 'package:movie/core/theme/app_colors.dart';
import 'package:movie/core/theme/app_assets.dart';
import 'package:movie/core/services/user_service.dart';
import 'package:movie/core/models/user_model.dart';
import 'package:movie/core/api/api_service.dart';
import 'package:movie/core/api/models/update_profile_request.dart';
import 'package:movie/screens/home/pick_avatar_screen.dart';
import 'package:movie/screens/auth/reset_password_screen.dart';

class UpdateProfileTab extends StatefulWidget {
  static const routeName = 'UpdateProfile';
  const UpdateProfileTab({super.key});

  @override
  State<UpdateProfileTab> createState() => _UpdateProfileTabState();
}

class _UpdateProfileTabState extends State<UpdateProfileTab> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final UserService _userService = UserService();
  final ApiService _apiService = ApiService();
  bool _isLoading = false;
  
  int _selectedAvatarIndex = 1;
  UserModel? _user;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = await _userService.getUser();
    if (mounted) {
      setState(() {
        _user = user;
        _nameController.text = user?.name ?? '';
        _phoneController.text = user?.phone ?? '';
        _selectedAvatarIndex = (user?.avatarId ?? 2) - 1;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.Black,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: AppColors.yellow,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PickAvatarScreen(
                  initialAvatarIndex: _selectedAvatarIndex,
                  onAvatarSelected: (index) {
                    setState(() {
                      _selectedAvatarIndex = index;
                    });
                  },
                ),
              ),
            );
          },
          child: const Text(
            'Pick Avatar',
            style: TextStyle(
              color: AppColors.yellow,
              fontSize: 16,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        centerTitle: true,
        backgroundColor: AppColors.Black,
        elevation: 0,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 32),
                      _buildAvatarDisplay(),
                      const SizedBox(height: 40),
                      _buildTextField(
                        controller: _nameController,
                        icon: AppAssets.nameIcon,
                        hintText: 'Name',
                        keyboardType: TextInputType.name,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _phoneController,
                        icon: AppAssets.phoneIcon,
                        hintText: 'Phone',
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your phone number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              ResetPasswordScreen.routeName,
                            );
                          },
                          child: const Text(
                            'Reset Password',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    _buildDeleteAccountButton(),
                    const SizedBox(height: 16),
                    _buildUpdateDataButton(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarDisplay() {
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

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PickAvatarScreen(
              initialAvatarIndex: _selectedAvatarIndex,
              onAvatarSelected: (index) {
                setState(() {
                  _selectedAvatarIndex = index;
                });
              },
            ),
          ),
        );
      },
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: AppColors.yellow,
            width: 3,
          ),
        ),
        child: ClipOval(
          child: Image.asset(
            avatars[_selectedAvatarIndex],
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: AppColors.grey,
                child: const Icon(
                  Icons.person,
                  size: 60,
                  color: AppColors.white,
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String icon,
    required String hintText,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.grey,
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator,
        style: const TextStyle(
          color: AppColors.white,
          fontSize: 14,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(
            color: Colors.grey,
            fontSize: 14,
          ),
          prefixIcon: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Image.asset(
              icon,
              width: 20,
              height: 20,
            ),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: AppColors.grey,
        ),
      ),
    );
  }

  Widget _buildDeleteAccountButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: () {
          _showDeleteAccountDialog();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.Red,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 0,
        ),
        child: const Text(
          'Delete Account',
          style: TextStyle(
            color: AppColors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildUpdateDataButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _isLoading ? null : () {
          if (_formKey.currentState!.validate()) {
            _handleUpdateData();
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.yellow,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 0,
        ),
        child: _isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.Black),
                ),
              )
            : const Text(
                'Update Data',
                style: TextStyle(
                  color: AppColors.Black,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
      ),
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.grey,
          title: const Text(
            'Delete Account',
            style: TextStyle(
              color: AppColors.white,
            ),
          ),
          content: const Text(
            'Are you sure you want to delete your account? This action cannot be undone.',
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
                Navigator.pop(context);
                await _handleDeleteAccount();
              },
              child: const Text(
                'Delete',
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

  Future<void> _handleUpdateData() async {
    if (_formKey.currentState!.validate()) {
      if (_user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('An error occurred. Please log in again.'),
            backgroundColor: AppColors.Red,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      final token = await _userService.getToken();
      
      if (token == null || token.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Authentication error. Please log in again.'),
            backgroundColor: AppColors.Red,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      try {
        final request = UpdateProfileRequest(
          name: _nameController.text.trim(),
          phone: _phoneController.text.trim(),
          avaterId: _selectedAvatarIndex + 1,
        );

        final response = await _apiService.updateProfile(request, token);

        final updatedUser = _user!.copyWith(
          name: _nameController.text.trim(),
          phone: _phoneController.text.trim(),
          avatarId: _selectedAvatarIndex + 1,
        );
        await _userService.updateUser(updatedUser);

        if (mounted) {
          setState(() {
            _isLoading = false;
            _user = updatedUser;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.message.isNotEmpty
                  ? response.message
                  : 'Data updated successfully!'),
              backgroundColor: AppColors.yellow,
              behavior: SnackBarBehavior.floating,
            ),
          );
          
          Future.delayed(const Duration(milliseconds: 500), () {
            Navigator.pop(context, true);
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.toString().replaceAll('Exception: ', '')),
              backgroundColor: AppColors.Red,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    }
  }

  Future<void> _handleDeleteAccount() async {
    final token = await _userService.getToken();
    if (token == null || token.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Authentication error. Please log in again.'),
            backgroundColor: AppColors.Red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _apiService.deleteProfile(token);
      
      await _userService.clearUser();

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Account deleted successfully'),
            backgroundColor: AppColors.yellow,
            behavior: SnackBarBehavior.floating,
          ),
        );

        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              'Login',
              (route) => false,
            );
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: AppColors.Red,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }
}

