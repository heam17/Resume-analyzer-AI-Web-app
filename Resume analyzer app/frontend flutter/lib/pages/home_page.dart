import 'package:flutter/material.dart';

import '../main.dart';
import '../widgets/custom_button.dart';
import '../widgets/glass_card.dart';
import '../widgets/skill_input.dart';
import 'upload_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _jobRoleController = TextEditingController();
  final TextEditingController _vacancyController = TextEditingController(text: '1');

  List<String> _skills = [];
  String _experience = 'Fresher';

  static const Map<String, int> _experienceOptions = {
    'Fresher': 0,
    '1 Year': 1,
    '2 Years': 2,
    '3 Years': 3,
    '5+ Years': 5,
    '10+ Years': 10,
    '30 Years': 30,
  };

  @override
  void dispose() {
    _jobRoleController.dispose();
    _vacancyController.dispose();
    super.dispose();
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.errorContainer,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _goToUpload() {
    final jobRole = _jobRoleController.text.trim();
    if (jobRole.isEmpty) {
      _showSnack('Please enter a domain / job role.');
      return;
    }
    if (_skills.isEmpty) {
      _showSnack('Please add at least one required skill.');
      return;
    }
    final vacancy = int.tryParse(_vacancyController.text.trim());
    if (vacancy == null || vacancy < 1) {
      _showSnack('Please enter a valid vacancy count.');
      return;
    }
    final experience = _experienceOptions[_experience] ?? 0;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => UploadPage(
          jobRole: jobRole,
          skills: _skills,
          experience: experience,
          vacancy: vacancy,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceDim,
      body: Stack(
        children: [
          const FloatingBackground(),
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Create Analysis',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: AppColors.onSurface,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Fill in the job details to calibrate the AI scoring engine for your specific career path.',
                          style: TextStyle(fontSize: 14, color: AppColors.outline, height: 1.4),
                        ),
                        const SizedBox(height: 32),
                        _buildLabel('DOMAIN NAME'),
                        const SizedBox(height: 8),
                        _buildDomainField(),
                        const SizedBox(height: 24),
                        _buildLabel('REQUIRED SKILLS'),
                        const SizedBox(height: 8),
                        SkillInput(
                          initialSkills: _skills,
                          onChanged: (skills) => setState(() => _skills = skills),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: _buildExperiencePicker()),
                            const SizedBox(width: 16),
                            Expanded(child: _buildVacancyField()),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildHintCard(),
                        // Extra breathing room so content clears the fixed bottom bar.
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(left: 0, right: 0, bottom: 0, child: SafeArea(top: false, child: _buildBottomBar())),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) => Padding(
        padding: const EdgeInsets.only(left: 4),
        child: Text(
          text,
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 0.6, color: AppColors.outline),
        ),
      );

  Widget _buildHeader() {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.15))),
      ),
      child: Row(
        children: [
          Icon(Icons.hub_outlined, color: AppColors.primary, size: 26),
          const SizedBox(width: 8),
          Text('AI Resume Score', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.primary)),
          const Spacer(),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.05),
              border: Border.all(color: Colors.white.withOpacity(0.15)),
            ),
            child: Icon(Icons.person_outline, color: AppColors.onSurfaceVariant, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildDomainField() {
    return GlassCard(
      borderRadius: 12,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        height: 56,
        child: Row(
          children: [
            Icon(Icons.work_outline, color: AppColors.outline, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _jobRoleController,
                style: TextStyle(fontSize: 17, color: AppColors.onSurface),
                decoration: InputDecoration(
                  hintText: 'e.g. Senior Software Engineer',
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.2)),
                  border: InputBorder.none,
                  isDense: true,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExperiencePicker() {
    return GlassCard(
      borderRadius: 12,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        height: 56,
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: _experience,
            isExpanded: true,
            dropdownColor: AppColors.surfaceContainerHigh,
            icon: Icon(Icons.unfold_more, color: AppColors.outline),
            style: TextStyle(fontSize: 16, color: AppColors.onSurface),
            onChanged: (value) {
              if (value != null) setState(() => _experience = value);
            },
            items: _experienceOptions.keys
                .map((label) => DropdownMenuItem(value: label, child: Text(label)))
                .toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildVacancyField() {
    return GlassCard(
      borderRadius: 12,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        height: 56,
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _vacancyController,
                keyboardType: TextInputType.number,
                style: TextStyle(fontSize: 17, color: AppColors.onSurface),
                decoration: InputDecoration(
                  hintText: '1',
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.2)),
                  border: InputBorder.none,
                  isDense: true,
                ),
              ),
            ),
            Icon(Icons.groups_outlined, color: AppColors.outline, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildHintCard() {
    return GlassCard(
      borderRadius: 16,
      backgroundColor: AppColors.primary.withOpacity(0.05),
      border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, color: AppColors.primary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Accurate vacancy details help the AI understand competitive benchmarks for your industry.',
              style: TextStyle(fontSize: 14, color: AppColors.onSurfaceVariant, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.25))),
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('STEP 1 OF 2',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 0.6, color: AppColors.outline)),
                Text('Configuration', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.onSurface)),
              ],
            ),
          ),
          CustomButton(
            label: 'Next',
            trailingIcon: Icons.arrow_forward_ios,
            onPressed: _goToUpload,
            height: 56,
            width: 150,
          ),
        ],
      ),
    );
  }
}
