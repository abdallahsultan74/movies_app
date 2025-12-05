import 'package:flutter/material.dart';
import 'package:movie/core/theme/app_colors.dart';
import 'package:movie/core/theme/app_assets.dart';
import 'package:movie/core/api/api_service.dart';
import 'package:movie/core/api/models/register_request.dart';
import 'package:movie/core/services/user_service.dart';
import 'package:movie/core/models/user_model.dart';
import 'package:movie/screens/auth/login_screen.dart';

class RegisterScreen extends StatefulWidget {
  static const routeName = 'Register';
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _phoneController = TextEditingController();

  int _selectedAvatarIndex = 1;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLiberiaSelected = true;
  bool _isLoading = false;
  final ApiService _apiService = ApiService();
  final UserService _userService = UserService();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.Black,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Register',
          style: TextStyle(
            color: AppColors.yellow,
            fontSize: 16,
            fontWeight: FontWeight.w400,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppColors.Black,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 24),
                _buildAvatarSection(),
                const SizedBox(height: 32),
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
                  controller: _emailController,
                  icon: AppAssets.emailIcon,
                  hintText: 'Email',
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!value.contains('@')) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _buildPasswordField(
                  controller: _passwordController,
                  hintText: 'Password',
                  isVisible: _isPasswordVisible,
                  onToggleVisibility: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _buildPasswordField(
                  controller: _confirmPasswordController,
                  hintText: 'Confirm Password',
                  isVisible: _isConfirmPasswordVisible,
                  onToggleVisibility: () {
                    setState(() {
                      _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm your password';
                    }
                    if (value != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _phoneController,
                  icon: AppAssets.phoneIcon,
                  hintText: 'Phone Number',
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your phone number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleCreateAccount,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.yellow,
                      foregroundColor: AppColors.Black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.Black,
                              ),
                            ),
                          )
                        : const Text('Create Account'),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Already Have Account ? ',
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 14,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacementNamed(
                          context,
                          LoginScreen.routeName,
                        );
                      },
                      child: const Text(
                        'Login',
                        style: TextStyle(
                          color: AppColors.yellow,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                _buildLanguageToggle(),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarSection() {
    final List<String> avatars = [
      AppAssets.avatar1,
      AppAssets.avatar2,
      AppAssets.avatar3,
    ];

    return Column(
      children: [
        const Text(
          'Avatar',
          style: TextStyle(
            color: AppColors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(avatars.length, (index) {
            final isSelected = index == _selectedAvatarIndex;
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedAvatarIndex = index;
                });
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: isSelected ? 80 : 60,
                  height: isSelected ? 80 : 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: isSelected
                        ? Border.all(
                            color: AppColors.yellow,
                            width: 3,
                          )
                        : null,
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      avatars[index],
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ],
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

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String hintText,
    required bool isVisible,
    required VoidCallback onToggleVisibility,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.grey,
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: !isVisible,
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
              AppAssets.passwordIcon,
              width: 20,
              height: 20,
            ),
          ),
          suffixIcon: IconButton(
            icon: Image.asset(
              AppAssets.eyeVisibilityIcon,
              width: 20,
              height: 20,
            ),
            onPressed: onToggleVisibility,
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

  Widget _buildLanguageToggle() {
    const containerWidth = 92.10857391357422;
    const containerHeight = 37.89108657836914;
    const borderWidth = 2.0;
    const flagSize = 25.0;

    return Container(
      width: containerWidth,
      height: containerHeight,
      decoration: BoxDecoration(
        color: AppColors.grey,
        borderRadius: BorderRadius.circular(containerHeight / 2),
        border: Border.all(
          color: AppColors.grey,
          width: borderWidth,
        ),
      ),
      child: Stack(
        children: [
          AnimatedPositioned(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            left: _isLiberiaSelected ? borderWidth : containerWidth / 2,
            top: borderWidth,
            child: Container(
              width: (containerWidth / 2) - borderWidth,
              height: containerHeight - (borderWidth * 2),
              decoration: BoxDecoration(
                color: AppColors.grey,
                borderRadius: BorderRadius.circular(
                    (containerHeight - (borderWidth * 2)) / 2),
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _isLiberiaSelected = true;
                    });
                  },
                  child: Container(
                    alignment: Alignment.center,
                    child: ClipOval(
                      child: Image.asset(
                        AppAssets.usa,
                        width: flagSize,
                        height: flagSize,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _isLiberiaSelected = false;
                    });
                  },
                  child: Container(
                    alignment: Alignment.center,
                    child: ClipOval(
                      child: Image.asset(
                        AppAssets.egypt,
                        width: flagSize,
                        height: flagSize,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _handleCreateAccount() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final request = RegisterRequest(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
          confirmPassword: _confirmPasswordController.text,
          phone: _phoneController.text.trim(),
          avaterId: _selectedAvatarIndex + 1,
        );

        final response = await _apiService.register(request);

        if (mounted) {
          setState(() {
            _isLoading = false;
          });

          // Save user data if available
          if (response.data != null) {
            final user = UserModel(
              id: response.data!.id,
              name: response.data!.name,
              email: response.data!.email,
              phone: response.data!.phone,
              avatarId: response.data!.avaterId,
            );
            await _userService.saveUser(user);
          }

          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.message.isNotEmpty
                  ? response.message
                  : 'Account created successfully!'),
              backgroundColor: AppColors.yellow,
              behavior: SnackBarBehavior.floating,
            ),
          );

          // Navigate to login screen after successful registration
          Future.delayed(const Duration(seconds: 1), () {
            if (mounted) {
              Navigator.pushReplacementNamed(
                context,
                LoginScreen.routeName,
              );
            }
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });

          // Show error message
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
}
