import 'package:flutter/material.dart';
import 'package:movie/core/theme/app_colors.dart';
import 'package:movie/core/theme/app_assets.dart';

class PickAvatarScreen extends StatefulWidget {
  final int initialAvatarIndex;
  final Function(int) onAvatarSelected;

  const PickAvatarScreen({
    super.key,
    required this.initialAvatarIndex,
    required this.onAvatarSelected,
  });

  @override
  State<PickAvatarScreen> createState() => _PickAvatarScreenState();
}

class _PickAvatarScreenState extends State<PickAvatarScreen> {
  late int _selectedAvatarIndex;
  final _nameController = TextEditingController(text: 'John Safwat');
  final _phoneController = TextEditingController(text: '01200000000');

  @override
  void initState() {
    super.initState();
    _selectedAvatarIndex = widget.initialAvatarIndex;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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

    return Scaffold(
      backgroundColor: AppColors.Black,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: AppColors.yellow,
          ),
          onPressed: () {
            widget.onAvatarSelected(_selectedAvatarIndex);
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Pick Avatar',
          style: TextStyle(
            color: AppColors.yellow,
            fontSize: 16,
            fontWeight: FontWeight.w400,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppColors.Black,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 32),
              Container(
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
              const SizedBox(height: 32),
              _buildTextField(
                controller: _nameController,
                icon: AppAssets.nameIcon,
                hintText: 'Name',
                keyboardType: TextInputType.name,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _phoneController,
                icon: AppAssets.phoneIcon,
                hintText: 'Phone',
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerLeft,
                child: GestureDetector(
                  onTap: () {},
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
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.Black,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.yellow,
                    width: 2,
                  ),
                ),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: avatars.length,
                  itemBuilder: (context, index) {
                    final isSelected = index == _selectedAvatarIndex;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedAvatarIndex = index;
                        });
                        widget.onAvatarSelected(index);
                      },
                      child: Container(
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
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: AppColors.grey,
                                child: const Icon(
                                  Icons.person,
                                  size: 30,
                                  color: AppColors.white,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 32),
            ],
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
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.grey,
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
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
}
