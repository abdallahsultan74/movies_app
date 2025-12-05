import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:movie/core/theme/app_colors.dart';
import 'package:movie/core/theme/app_assets.dart';
import 'package:movie/core/api/api_service.dart';
import 'package:movie/core/api/models/login_request.dart';
import 'package:movie/core/services/user_service.dart';
import 'package:movie/core/models/user_model.dart';
import 'package:movie/screens/auth/register_screen.dart';
import 'package:movie/screens/auth/reset_password_screen.dart';
import 'package:movie/screens/home/home_screen.dart';

class LoginScreen extends StatefulWidget {
  static const routeName = 'Login';
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isLoading = false;
  bool _isGoogleLoading = false;
  bool _isLiberiaSelected = true;
  final ApiService _apiService = ApiService();
  final UserService _userService = UserService();
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.Black,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                _buildLogo(),
                const SizedBox(height: 48),
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
                _buildPasswordField(),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, ResetPasswordScreen.routeName);
                    },
                    child: const Text(
                      'Forget Password?',
                      style: TextStyle(
                        color: AppColors.yellow,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleLogin,
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
                        : const Text('Login'),
                  ),
                ),
                const SizedBox(height: 24),
                _buildOrSeparator(),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isGoogleLoading ? null : _handleGoogleLogin,
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
                    child: _isGoogleLoading
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
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                AppAssets.googleIcon,
                                width: 24,
                                height: 24,
                              ),
                              const SizedBox(width: 12),
                              const Text('Login With Google'),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Don\'t Have Account ? ',
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 14,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, RegisterScreen.routeName);
                      },
                      child: const Text(
                        'Register',
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

  Widget _buildLogo() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.yellow,
          width: 2,
        ),
      ),
      child: Center(
        child: Image.asset(
          AppAssets.logo,
          width: 60,
          height: 60,
          fit: BoxFit.contain,
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

  Widget _buildPasswordField() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.grey,
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextFormField(
        controller: _passwordController,
        obscureText: !_isPasswordVisible,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter your password';
          }
          return null;
        },
        style: const TextStyle(
          color: AppColors.white,
          fontSize: 14,
        ),
        decoration: InputDecoration(
          hintText: 'Password',
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
            onPressed: () {
              setState(() {
                _isPasswordVisible = !_isPasswordVisible;
              });
            },
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

  Widget _buildOrSeparator() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            color: AppColors.yellow,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: const Text(
            'OR',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 1,
            color: AppColors.yellow,
          ),
        ),
      ],
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
                borderRadius: BorderRadius.circular((containerHeight - (borderWidth * 2)) / 2),
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

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final request = LoginRequest(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );

        final response = await _apiService.login(request);

        if (mounted) {
          setState(() {
            _isLoading = false;
          });

          String? token = response.data?.token;

          if (response.data != null) {
            final user = UserModel(
              id: response.data!.id ?? '',
              name: response.data!.name ?? '',
              email: _emailController.text.trim(),
              phone: response.data!.phone ?? '',
              avatarId: response.data!.avaterId ?? 1,
              token: token,
            );
            await _userService.saveUser(user);
          } else {
            final existingUser = await _userService.getUser();
            if (existingUser != null && existingUser.email == _emailController.text.trim()) {
              token = existingUser.token;
            } else {
              final user = UserModel(
                id: '',
                name: '',
                email: _emailController.text.trim(),
                phone: '',
                avatarId: 1,
                token: token,
              );
              await _userService.saveUser(user);
            }
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.message.isNotEmpty
                  ? response.message
                  : 'Login successful!'),
              backgroundColor: AppColors.yellow,
              behavior: SnackBarBehavior.floating,
            ),
          );

          Future.delayed(const Duration(seconds: 1), () {
            if (mounted) {
              Navigator.pushReplacementNamed(context, HomeScreen.routeName);
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

  Future<void> _handleGoogleLogin() async {
    setState(() {
      _isGoogleLoading = true;
    });

    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        if (mounted) {
          setState(() {
            _isGoogleLoading = false;
          });
        }
        return;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final user = UserModel(
        id: googleUser.id,
        name: googleUser.displayName ?? '',
        email: googleUser.email,
        phone: '',
        avatarId: 1,
        token: googleAuth.accessToken,
      );

      await _userService.saveUser(user);

      if (mounted) {
        setState(() {
          _isGoogleLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Google login successful!'),
            backgroundColor: AppColors.yellow,
            behavior: SnackBarBehavior.floating,
          ),
        );

        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            Navigator.pushReplacementNamed(context, HomeScreen.routeName);
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isGoogleLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e.toString().contains('sign_in_canceled')
                  ? 'Sign in cancelled'
                  : 'Error during Google login: ${e.toString().replaceAll('Exception: ', '')}',
            ),
            backgroundColor: AppColors.Red,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }
}
