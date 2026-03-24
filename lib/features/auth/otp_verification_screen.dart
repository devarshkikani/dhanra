import 'dart:async';
import 'dart:io';
import 'package:dhanra/core/routing/route_names.dart';
import 'package:dhanra/features/auth/data/auth_repository.dart';
import 'package:dhanra/core/util/firebase_handler.dart';
import 'package:dhanra/core/constants/app_regexp.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:another_telephony/telephony.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String phoneNumber;
  final String? userName;
  final bool isSignup;
  final String verificationId;

  const OtpVerificationScreen({
    super.key,
    required this.phoneNumber,
    required this.userName,
    required this.isSignup,
    required this.verificationId,
  });

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final _otpControllers = List.generate(6, (_) => TextEditingController());
  final _focusNodes = List.generate(6, (_) => FocusNode());

  bool _isLoading = false;
  bool _isResending = false;
  bool _isVerifying = false; // Guard against double verify
  int _resendTimer = 30;
  Timer? _countdownTimer;
  final Telephony telephony = Telephony.instance;
  String _enteredOtp = '';

  @override
  void initState() {
    super.initState();
    _startResendTimer();
    _setupOtpListeners();
    _initSmsListener();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    for (final c in _otpControllers) {
      c.dispose();
    }
    for (final n in _focusNodes) {
      n.dispose();
    }
    super.dispose();
  }

  void _updateOtp() {
    setState(() {
      _enteredOtp = _otpControllers.map((c) => c.text).join();
    });
  }

  void _startResendTimer() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        if (_resendTimer > 0) {
          _resendTimer--;
        } else {
          timer.cancel();
        }
      });
    });
  }

  Future<void> _verifyOtp() async {
    // Guard: prevent double-verification from multiple triggers
    if (_isVerifying || _isLoading) return;

    final otp = _otpControllers.map((c) => c.text).join();
    if (otp.length != 6) {
      _showSnackBar('Please enter a valid 6-digit OTP', Colors.red);
      return;
    }

    FocusManager.instance.primaryFocus?.unfocus();

    setState(() {
      _isVerifying = true;
      _isLoading = true;
    });

    try {
      final userCred = await AuthRepository().confirmOtp(
        widget.verificationId,
        otp.trim(),
      );

      await AuthRepository().handlePostSignIn(
        user: userCred.user,
        phoneNumber: widget.phoneNumber,
        isSignup: widget.isSignup,
        userName: widget.userName,
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
          _isVerifying = false;
        });
        context.pushReplacement(AppRoute.permission.path);
      }
    } catch (e) {
      _showSnackBar(FirebaseHandler.getReadableErrorMessage(e), Colors.red);
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isVerifying = false;
        });
      }
    }
  }

  Future<void> _initSmsListener() async {
    // SMS listener only works on Android — skip on iOS to avoid crashes
    if (!Platform.isAndroid) return;

    bool? permissionsGranted = await telephony.requestPhoneAndSmsPermissions;
    if (permissionsGranted != null && permissionsGranted) {
      telephony.listenIncomingSms(
        onNewMessage: (SmsMessage message) {
          final String? body = message.body;
          if (body != null) {
            final match = AppRegexp.otpRegex.firstMatch(body);
            if (match != null) {
              final otp = match.group(1);
              if (otp != null && otp.length == 6) {
                _fillOtp(otp);
              }
            }
          }
        },
        listenInBackground: false,
      );
    }
  }

  void _fillOtp(String otp) {
    if (!mounted) return;
    for (int i = 0; i < 6; i++) {
      _otpControllers[i].text = otp[i];
    }
    setState(() {
      _enteredOtp = otp;
    });
    _verifyOtp();
  }

  void _setupOtpListeners() {
    for (int i = 0; i < 6; i++) {
      _otpControllers[i].addListener(() {
        final text = _otpControllers[i].text;

        if (text.length > 1) {
          _setOtpFromPaste(text);
          return;
        }

        if (text.isNotEmpty && i < 5) {
          _focusNodes[i + 1].requestFocus();
        } else if (text.isEmpty && i > 0) {
          _focusNodes[i - 1].requestFocus();
        }

        _updateOtp();

        // Read directly from controllers to avoid stale setState value
        final currentOtp = _otpControllers.map((c) => c.text).join();
        if (currentOtp.length == 6) {
          _verifyOtp();
        }
      });
    }
  }

  void _setOtpFromPaste(String value) {
    final digits = value.replaceAll(RegExp(r'\D'), '');
    if (digits.length == 6) {
      for (int i = 0; i < 6; i++) {
        _otpControllers[i].text = digits[i];
      }
      _focusNodes[5].requestFocus();
      _updateOtp();
      _verifyOtp();
    }
  }

  Future<void> _resendOtp() async {
    setState(() => _isResending = true);
    try {
      await AuthRepository().sendOtp(
        phoneNumber: '+91${widget.phoneNumber}',
        onAutoVerification: (credential) {
          // Android auto-verified — fill & verify automatically
          _showSnackBar('OTP auto-verified!', Colors.green);
        },
        onCodeSent: (verificationId) {
          _showSnackBar('OTP resent successfully', Colors.green);
          if (mounted) {
            setState(() {
              _resendTimer = 30;
              _isResending = false;
              _isVerifying = false;
            });
            _startResendTimer();
          }
        },
        onVerificationFailed: (e) {
          _showSnackBar(FirebaseHandler.getReadableErrorMessage(e), Colors.red);
          if (mounted) setState(() => _isResending = false);
        },
      );
    } catch (e) {
      _showSnackBar(FirebaseHandler.getReadableErrorMessage(e), Colors.red);
      if (mounted) setState(() => _isResending = false);
    }
  }

  void _showSnackBar(String message, Color color) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: color),
      );
    }
  }

  InputDecoration _otpDecoration() {
    return InputDecoration(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 12),
    );
  }

  Widget _buildOtpField(int index) {
    return SizedBox(
      width: 48,
      child: TextFormField(
        controller: _otpControllers[index],
        focusNode: _focusNodes[index],
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        autofocus: index == 0,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(1),
        ],
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        decoration: _otpDecoration(),
        onChanged: (value) {
          if (value.length > 1) {
            _setOtpFromPaste(value);
          } else {
            _updateOtp();
            if (value.isNotEmpty && index < 5) {
              Future.microtask(() {
                _focusNodes[index + 1].requestFocus();
              });
            }
            if (_enteredOtp.length == 6) {
              _verifyOtp();
            }
          }
        },
      ),
    );
  }

  Widget _buildVerifyButton() {
    return ElevatedButton(
      onPressed: _isLoading ? null : _verifyOtp,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
      ),
      child: _isLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : const Text(
              'Verify OTP',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
    );
  }

  Widget _buildResendSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Didn\'t receive the code? ',
          style: TextStyle(color: Colors.grey[600]),
        ),
        if (_resendTimer > 0)
          Text(
            'Resend in $_resendTimer s',
            style:
                TextStyle(color: Colors.grey[500], fontWeight: FontWeight.w500),
          )
        else
          TextButton(
            onPressed: _isResending ? null : _resendOtp,
            child: _isResending
                ? const SizedBox(
                    height: 16,
                    width: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text(
                    'Resend OTP',
                    style: TextStyle(
                        color: AppColors.primary, fontWeight: FontWeight.bold),
                  ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.center,
            colors: [
              Theme.of(context).primaryColor.withAlpha(50),
              AppColors.background,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: SizedBox(
              height: height - 96,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const SizedBox(height: 40),
                  Text(
                    'OTP Verification',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.isSignup
                        ? 'We\'ve sent a verification code to'
                        : 'Enter the verification code sent to',
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.copyWith(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '+91 ${widget.phoneNumber}',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 60),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children:
                        List.generate(6, (index) => _buildOtpField(index)),
                  ),
                  const SizedBox(height: 40),
                  _buildVerifyButton(),
                  const SizedBox(height: 32),
                  _buildResendSection(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
