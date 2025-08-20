import 'package:dhanra/features/auth/data/auth_repository.dart';
import 'package:dhanra/features/permissions/presentation/screens/permission_flow_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_colors.dart';
import '../../core/services/local_storage_service.dart';

class OtpVerificationPage extends StatefulWidget {
  final String phoneNumber;
  final String? userName;
  final bool isSignup;
  final String verificationId;

  const OtpVerificationPage({
    Key? key,
    required this.phoneNumber,
    required this.userName,
    required this.isSignup,
    required this.verificationId,
  }) : super(key: key);

  @override
  State<OtpVerificationPage> createState() => _OtpVerificationPageState();
}

class _OtpVerificationPageState extends State<OtpVerificationPage> {
  final _otpControllers = List.generate(6, (_) => TextEditingController());
  final _focusNodes = List.generate(6, (_) => FocusNode());

  final LocalStorageService _storage = LocalStorageService();

  bool _isLoading = false;
  bool _isResending = false;
  int _resendTimer = 30;
  String _enteredOtp = '';

  @override
  void initState() {
    super.initState();
    _startResendTimer();
    _setupOtpListeners();
  }

  @override
  void dispose() {
    for (final controller in _otpControllers) {
      controller.dispose();
    }
    for (final node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _updateOtp() {
    setState(() {
      _enteredOtp = _otpControllers.map((c) => c.text).join();
    });
  }

  void _startResendTimer() {
    if (_resendTimer > 0) {
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          setState(() => _resendTimer--);
          _startResendTimer();
        }
      });
    }
  }

  Future<void> _verifyOtp() async {
    if (_enteredOtp.length != 6) {
      _showSnackBar('Please enter a valid 6-digit OTP', Colors.red);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final userCred = await AuthRepository().confirmOtp(
        widget.verificationId,
        _enteredOtp.trim(),
      );
      final user = userCred.user;

      if (widget.isSignup) {
        final names = (widget.userName ?? '').trim().split(' ');
        await AuthRepository().setUserProfile(
          uid: user?.uid ?? widget.phoneNumber,
          firstName: names.isNotEmpty ? names.first : '',
          lastName: names.length > 1 ? names.last : '',
          phoneNumber: widget.phoneNumber,
        );
      }

      final profile = await AuthRepository().getUserProfile(
        user?.uid ?? widget.phoneNumber,
      );

      await _storage.setUserLoggedIn(
        phone: widget.phoneNumber,
        name: profile?['firstName'] ?? '',
        userId: 'user_${widget.phoneNumber}',
      );

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const PermissionFlowScreen()),
        );
      }
    } catch (e) {
      _showSnackBar('Error: ${e.toString()}', Colors.red);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
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

        if (_enteredOtp.length == 6) {
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
      await Future.delayed(const Duration(seconds: 1));
      _showSnackBar('OTP resent successfully', Colors.green);
      setState(() {
        _resendTimer = 30;
        _isResending = false;
      });
      _startResendTimer();
    } catch (e) {
      _showSnackBar('Error resending OTP: ${e.toString()}', Colors.red);
      setState(() => _isResending = false);
    }
  }

  void _showSnackBar(String message, Color color) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: color),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.center,
          colors: [
            Theme.of(context).primaryColor.withAlpha(50),
            AppColors.background
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: SizedBox(
              height: MediaQuery.of(context).size.height - 132,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const SizedBox(height: 40),
                  Text(
                    'OTP Verification',
                    style: Theme.of(context)
                        .textTheme
                        .headlineMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.isSignup
                        ? 'We\'ve sent a verification code to'
                        : 'Enter the verification code sent to',
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.copyWith(color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '+91 ${widget.phoneNumber}',
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
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
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOtpField(int index) {
    return SizedBox(
      width: 45,
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
        decoration: InputDecoration(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.primary, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
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
}
