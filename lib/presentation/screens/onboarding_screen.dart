import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../domain/entities/currency_item.dart';
import '../../domain/repositories/expense_repository.dart';
import '../state/currency/currency_cubit.dart';
import '../theme/app_theme.dart';
import '../widgets/currency_selector_dialog.dart';

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
  CurrencyItem _selectedCurrency = CurrencyItem.availableCurrencies.first;

  static const String githubUrl = 'https://github.com/jakegithub24/MoneyMan-App';

  @override
  void initState() {
    super.initState();
    _loadExistingProfile();
  }

  Future<void> _loadExistingProfile() async {
    final name = await widget.repository.getUserName();
    if (name != null && name.isNotEmpty) {
      _nameController.text = name;
    }
    final code = await widget.repository.getCurrencyCode();
    if (mounted) {
      setState(() {
        _selectedCurrency = CurrencyItem.getByCode(code);
      });
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

  Future<void> _openCurrencyPicker() async {
    final selected = await showDialog<CurrencyItem>(
      context: context,
      builder: (ctx) => CurrencySelectorDialog(
        initialCurrency: _selectedCurrency,
        onSelected: (item) {
          setState(() {
            _selectedCurrency = item;
          });
        },
      ),
    );
    if (selected != null) {
      setState(() {
        _selectedCurrency = selected;
      });
    }
  }

  Future<void> _submitProfileAndComplete() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter a username to continue.';
      });
      return;
    }

    if (RegExp(r'^[_0-9]').hasMatch(name)) {
      setState(() {
        _errorMessage = 'Username must not start with a number or underscore.';
      });
      return;
    }

    final validPattern = RegExp(r'^[a-zA-Z][a-zA-Z0-9_]{0,9}$');
    if (!validPattern.hasMatch(name)) {
      if (name.length > 10) {
        setState(() {
          _errorMessage = 'Username cannot exceed 10 characters.';
        });
      } else {
        setState(() {
          _errorMessage = 'Username can only contain letters, numbers, and underscores.';
        });
      }
      return;
    }

    setState(() {
      _errorMessage = null;
    });

    final selectedCode = _selectedCurrency.code;
    final selectedSymbol = _selectedCurrency.symbol;

    try {
      await widget.repository.setUserName(name);
      await widget.repository.setCurrency(selectedCode, selectedSymbol);
      await widget.repository.setOnboardingCompleted(true);

      try {
        if (mounted) {
          context.read<CurrencyCubit>().changeCurrency(_selectedCurrency);
        }
      } catch (_) {}

      if (mounted) {
        widget.onCompleted();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to save settings: $e';
        });
      }
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
                  _buildProfilePage(),
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
                _FeatureRow(icon: Icons.currency_exchange_rounded, text: 'Account Currency Setup (Fixed on Setup)'),
                SizedBox(height: 12),
                _FeatureRow(icon: Icons.lock_rounded, text: 'PIN Security Lock & Auto-Lock Controls'),
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

  Widget _buildProfilePage() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppTheme.baseHighlightColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.person_pin_rounded,
                      color: AppTheme.baseHighlightColor,
                      size: 40,
                    ),
                  ),
                  const SizedBox(height: 16),

                  const Text(
                    'Profile & Currency Setup',
                    style: TextStyle(
                      color: AppTheme.textColor,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Set your username and select your preferred account currency. Currency cannot be changed later.',
                    style: TextStyle(
                      color: AppTheme.textColor.withValues(alpha: 0.8),
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Username Section
                  const Text(
                    'USERNAME',
                    style: TextStyle(color: AppTheme.textColor, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _nameController,
                    maxLength: 10,
                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9_]'))],
                    style: const TextStyle(color: AppTheme.textColor, fontSize: 16, fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      hintText: 'Username (A-Z, a-z, 0-9, _, max 10 chars)',
                      prefixIcon: const Icon(Icons.person_outline_rounded, color: AppTheme.baseHighlightColor),
                      filled: true,
                      fillColor: AppTheme.cardBackgroundColor,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(
                          color: _errorMessage != null
                              ? AppTheme.expenseColor
                              : AppTheme.textColor.withValues(alpha: 0.3),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: AppTheme.baseHighlightColor, width: 2),
                      ),
                    ),
                    onChanged: (_) {
                      if (_errorMessage != null) {
                        setState(() {
                          _errorMessage = null;
                        });
                      }
                    },
                    onSubmitted: (_) => _submitProfileAndComplete(),
                  ),
                  const SizedBox(height: 16),

                  // Currency Selector Section
                  const Text(
                    'ACCOUNT CURRENCY (FIXED)',
                    style: TextStyle(color: AppTheme.textColor, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                  ),
                  const SizedBox(height: 8),
                  Card(
                    color: AppTheme.cardBackgroundColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                      side: BorderSide(color: AppTheme.textColor.withValues(alpha: 0.3)),
                    ),
                    child: ListTile(
                      leading: Text(
                        _selectedCurrency.flag,
                        style: const TextStyle(fontSize: 28),
                      ),
                      title: Text(
                        '${_selectedCurrency.name} (${_selectedCurrency.symbol})',
                        style: const TextStyle(color: AppTheme.textColor, fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      subtitle: Text(
                        'Code: ${_selectedCurrency.code}',
                        style: TextStyle(color: AppTheme.textColor.withValues(alpha: 0.7), fontSize: 12),
                      ),
                      trailing: const Icon(Icons.keyboard_arrow_down_rounded, color: AppTheme.textColor),
                      onTap: _openCurrencyPicker,
                    ),
                  ),

                  if (_errorMessage != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppTheme.expenseColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppTheme.expenseColor.withValues(alpha: 0.5)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline_rounded, color: AppTheme.expenseColor, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _errorMessage ?? '',
                              style: const TextStyle(color: AppTheme.expenseColor, fontSize: 13, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // Submit & Finish Button Always Visible
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.baseHighlightColor,
                foregroundColor: AppTheme.backgroundColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: _submitProfileAndComplete,
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
