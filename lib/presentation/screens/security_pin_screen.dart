import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

enum PinMode { setup, confirm, unlock }

class SecurityPinScreen extends StatefulWidget {
  final PinMode mode;
  final String? savedPin;

  const SecurityPinScreen({
    super.key,
    required this.mode,
    this.savedPin,
  });

  @override
  State<SecurityPinScreen> createState() => _SecurityPinScreenState();
}

class _SecurityPinScreenState extends State<SecurityPinScreen> {
  String _enteredPin = '';
  String _firstEnteredPin = '';
  late PinMode _currentMode;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _currentMode = widget.mode;
  }

  void _onKeyPress(String digit) {
    if (_enteredPin.length < 4) {
      setState(() {
        _enteredPin += digit;
        _errorMessage = '';
      });

      if (_enteredPin.length == 4) {
        _evaluatePin();
      }
    }
  }

  void _onDelete() {
    if (_enteredPin.isNotEmpty) {
      setState(() {
        _enteredPin = _enteredPin.substring(0, _enteredPin.length - 1);
        _errorMessage = '';
      });
    }
  }

  void _evaluatePin() {
    switch (_currentMode) {
      case PinMode.setup:
        _firstEnteredPin = _enteredPin;
        setState(() {
          _enteredPin = '';
          _currentMode = PinMode.confirm;
        });
        break;

      case PinMode.confirm:
        if (_enteredPin == _firstEnteredPin) {
          Navigator.pop(context, _enteredPin);
        } else {
          setState(() {
            _enteredPin = '';
            _firstEnteredPin = '';
            _currentMode = PinMode.setup;
            _errorMessage = 'PINs did not match. Start again.';
          });
        }
        break;

      case PinMode.unlock:
        if (_enteredPin == widget.savedPin) {
          Navigator.pop(context, true);
        } else {
          setState(() {
            _enteredPin = '';
            _errorMessage = 'Incorrect Security PIN';
          });
        }
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    String title;
    switch (_currentMode) {
      case PinMode.setup:
        title = 'Set 4-Digit Security PIN';
        break;
      case PinMode.confirm:
        title = 'Confirm Security PIN';
        break;
      case PinMode.unlock:
        title = 'Enter Security PIN';
        break;
    }

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.lock_rounded,
                size: 56,
                color: AppTheme.baseHighlightColor,
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(
                  color: AppTheme.textColor,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage.isNotEmpty
                    ? _errorMessage
                    : 'Protect your financial data',
                style: TextStyle(
                  color: _errorMessage.isNotEmpty
                      ? AppTheme.expenseColor
                      : AppTheme.textColor,
                  fontSize: 14,
                  fontWeight:
                      _errorMessage.isNotEmpty ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              const SizedBox(height: 32),

              // PIN Indicator Dots
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(4, (index) {
                  final isFilled = index < _enteredPin.length;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isFilled
                          ? AppTheme.baseHighlightColor
                          : AppTheme.cardBackgroundColor,
                      border: Border.all(
                        color: isFilled
                            ? AppTheme.baseHighlightColor
                            : AppTheme.textColor.withValues(alpha: 0.3),
                        width: 2,
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 48),

              // Custom Keypad (Numpad Grid)
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (var row in [
                      ['1', '2', '3'],
                      ['4', '5', '6'],
                      ['7', '8', '9'],
                      ['', '0', 'delete']
                    ])
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: row.map((key) {
                            if (key.isEmpty) {
                              return const SizedBox(width: 72, height: 72);
                            }
                            if (key == 'delete') {
                              return InkWell(
                                onTap: _onDelete,
                                borderRadius: BorderRadius.circular(36),
                                child: Container(
                                  width: 72,
                                  height: 72,
                                  alignment: Alignment.center,
                                  child: const Icon(
                                    Icons.backspace_rounded,
                                    color: AppTheme.textColor,
                                    size: 26,
                                  ),
                                ),
                              );
                            }
                            return InkWell(
                              onTap: () => _onKeyPress(key),
                              borderRadius: BorderRadius.circular(36),
                              child: Container(
                                width: 72,
                                height: 72,
                                decoration: BoxDecoration(
                                  color: AppTheme.cardBackgroundColor,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppTheme.textColor.withValues(alpha: 0.2),
                                    width: 1,
                                  ),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  key,
                                  style: const TextStyle(
                                    color: AppTheme.textColor,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
