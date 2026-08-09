import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../domain/repositories/expense_repository.dart';
import '../theme/app_theme.dart';

class OnboardingScreen extends StatefulWidget {
  final ExpenseRepository repository;
  final VoidCallback onCompleted;

  const OnboardingScreen({
    super.key,
    required this.repository,
    required this.onCompleted,
  });

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  final TextEditingController _nameController = TextEditingController();
  int _currentPage = 0;
  String? _errorMessage;

  static const String githubUrl = 'https://github.com/jakegithub24/MoneyMan-App';

  @override
  void initState() {
    super.initState();
    _loadExistingUserName();
  }

  Future<void> _loadExistingUserName() async {
    final name = await widget.repository.getUserName();
    if (name != null && name.isNotEmpty) {
      _nameController.text = name;
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _openGitHubLink() async {
    final Uri uri = Uri.parse(githubUrl);
    try {
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        await launchUrl(uri);
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not open link. Please visit: $githubUrl', style: TextStyle(color: AppTheme.textColor)),
            backgroundColor: AppTheme.cardBackgroundColor,
          ),
        );
      }
    }
  }

  Future<void> _submitNameAndComplete() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter your name to continue.';
      });
      return;
    }

    if (name.contains(' ') || RegExp(r'\s').hasMatch(name)) {
      setState(() {
        _errorMessage = 'Username must be a single word (no spaces allowed).';
      });
      return;
    }

    if (name.length > 30) {
      setState(() {
        _errorMessage = 'Username cannot exceed 30 characters.';
      });
      return;
    }

    await widget.repository.setUserName(name);
    await widget.repository.setOnboardingCompleted(true);

    if (mounted) {
      widget.onCompleted();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Top Indicator Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(2, (index) {
                  final isActive = index == _currentPage;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    height: 8,
                    width: isActive ? 28 : 8,
                    decoration: BoxDecoration(
                      color: isActive ? AppTheme.baseHighlightColor : AppTheme.textColor.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              ),
            ),

            // Page View
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (page) {
                  setState(() {
                    _currentPage = page;
                    _errorMessage = null;
                  });
                },
                children: [
                  _buildWelcomePage(),
                  _buildUserNamePage(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomePage() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // App Logo / Icon Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.baseHighlightColor.withValues(alpha: 0.15),
              shape: BoxShape.circle,
              border: Border.all(color: AppTheme.baseHighlightColor, width: 2),
            ),
            child: const Icon(
              Icons.account_balance_wallet_rounded,
              color: AppTheme.baseHighlightColor,
              size: 64,
            ),
          ),
          const SizedBox(height: 24),

          const Text(
            'Welcome to MoneyMan',
            style: TextStyle(
              color: AppTheme.textColor,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Your smart, private, and customizable personal finance tracker.',
            style: TextStyle(
              color: AppTheme.textColor.withValues(alpha: 0.8),
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 28),

          // Features List Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.cardBackgroundColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.textColor.withValues(alpha: 0.2)),
            ),
            child: const Column(
              children: [
                _FeatureRow(icon: Icons.pie_chart_rounded, text: 'Visual Spending Breakdown & Categories'),
                SizedBox(height: 12),
                _FeatureRow(icon: Icons.currency_exchange_rounded, text: 'Multi-Currency Support (INR, USD, EUR, JPY)'),
                SizedBox(height: 12),
                _FeatureRow(icon: Icons.lock_rounded, text: 'PIN Security Lock & Privacy Controls'),
                SizedBox(height: 12),
                _FeatureRow(icon: Icons.import_export_rounded, text: 'Custom Category Management & CSV Export/Import'),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Learn About MoneyMan GitHub Link Button
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.popHighlightColor,
              side: const BorderSide(color: AppTheme.popHighlightColor, width: 1.5),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            icon: const Icon(Icons.open_in_new_rounded, size: 20),
            label: const Text(
              'Learn About MoneyMan (GitHub)',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            onPressed: _openGitHubLink,
          ),

          const Spacer(),

          // Continue Button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.baseHighlightColor,
                foregroundColor: AppTheme.backgroundColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: () {
                _pageController.nextPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Next', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward_rounded, size: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserNamePage() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Spacer(),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.baseHighlightColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.badge_rounded,
              color: AppTheme.baseHighlightColor,
              size: 44,
            ),
          ),
          const SizedBox(height: 24),

          const Text(
            'What should we call you?',
            style: TextStyle(
              color: AppTheme.textColor,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Enter your name to personalize your MoneyMan dashboard.',
            style: TextStyle(
              color: AppTheme.textColor.withValues(alpha: 0.8),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 28),

          // Name Input Text Field
          TextField(
            controller: _nameController,
            maxLength: 30,
            inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r'\s'))],
            textCapitalization: TextCapitalization.words,
            style: const TextStyle(color: AppTheme.textColor, fontSize: 16, fontWeight: FontWeight.bold),
            decoration: InputDecoration(
              hintText: 'Enter single-word username (max 30 chars)',
              prefixIcon: const Icon(Icons.person_outline_rounded, color: AppTheme.baseHighlightColor),
              filled: true,
              fillColor: AppTheme.cardBackgroundColor,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: AppTheme.textColor.withValues(alpha: 0.3)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppTheme.baseHighlightColor, width: 2),
              ),
            ),
            onSubmitted: (_) => _submitNameAndComplete(),
          ),

          if (_errorMessage != null) ...[
            const SizedBox(height: 12),
            Text(
              _errorMessage!,
              style: const TextStyle(color: AppTheme.expenseColor, fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ],

          const Spacer(),

          // Submit & Finish Button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.baseHighlightColor,
                foregroundColor: AppTheme.backgroundColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: _submitNameAndComplete,
              child: const Text(
                'Get Started',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _FeatureRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.baseHighlightColor, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(color: AppTheme.textColor, fontSize: 13, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }
}
