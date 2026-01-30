import 'package:dhanra/core/routing/route_names.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/services/local_storage_service.dart';
import 'package:dhanra/features/auth/data/auth_repository.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _storage = LocalStorageService();

  bool _isLoading = false;
  bool _isPhoneValid = false;
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    _phoneController.addListener(_validatePhone);
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _validatePhone() {
    final phone = _phoneController.text.trim();
    setState(() => _isPhoneValid = RegExp(r'^[6-9]\d{9}$').hasMatch(phone));
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error: $message'),
        backgroundColor: Colors.red,
      ),
    );
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final phoneNumber = '+91${_phoneController.text.trim()}';

    try {
      await AuthRepository().sendOtp(
        phoneNumber: phoneNumber,
        onAutoVerification: (credential) async {
          if (_navigated) return;
          _navigated = true;

          final userCredential =
              await FirebaseAuth.instance.signInWithCredential(credential);

          await _storage.setUserLoggedIn(
            phone: userCredential.user?.phoneNumber ?? "",
            name: userCredential.user?.displayName ?? "",
            userId: 'user_${userCredential.user?.phoneNumber ?? ""}',
          );

          if (!mounted) return;
          setState(() => _isLoading = false);
          context.pushReplacement(AppRoute.permission.path);
          // Navigator.of(context).pushReplacement(
          //   MaterialPageRoute(builder: (_) => const PermissionFlowScreen()),
          // );
        },
        onCodeSent: (verificationId) {
          if (_navigated) return;
          _navigated = true;

          if (!mounted) return;
          setState(() => _isLoading = false);
          context.push(AppRoute.otpVerification.path, extra: {
            'phoneNumber': _phoneController.text,
            'userName': null,
            'verificationId': verificationId,
            'isSignup': false,
          });
          // Navigator.of(context).push(
          //   MaterialPageRoute(
          //     builder: (_) => OtpVerificationScreen(
          //       phoneNumber: _phoneController.text,
          //       userName: null,
          //       verificationId: verificationId,
          //       isSignup: false,
          //     ),
          //   ),
          // );
        },
        onVerificationFailed: (ex) {
          setState(() => _isLoading = false);
          _showError(ex.toString());
        },
      );
    } catch (e) {
      setState(() => _isLoading = false);
      _showError(e.toString());
    }
  }

  Widget _buildLogoAndTitle() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 50.0),
          child: Image.asset("assets/images/dhanra.png"),
        ),
        const SizedBox(height: 20),
        Text(
          'Login to your account',
          textAlign: TextAlign.center,
          style: Theme.of(context)
              .textTheme
              .bodyLarge
              ?.copyWith(color: Colors.grey[600]),
        ),
      ],
    );
  }

  InputDecoration _buildInputDecoration({
    required String label,
    required IconData icon,
    String? prefixText,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      prefixText: prefixText,
      suffixIcon: suffixIcon,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary),
      ),
    );
  }

  Widget _buildPhoneField() {
    return TextFormField(
      controller: _phoneController,
      keyboardType: TextInputType.phone,
      autofocus: true,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(10),
      ],
      decoration: _buildInputDecoration(
        label: 'Mobile Number',
        icon: Icons.phone_outlined,
        prefixText: '+91 ',
        suffixIcon: _isPhoneValid
            ? const Icon(Icons.check_circle, color: Colors.green)
            : null,
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your mobile number';
        }
        if (!RegExp(r'^[6-9]\d{9}$').hasMatch(value)) {
          return 'Please enter a valid mobile number';
        }
        return null;
      },
    );
  }

  Widget _buildLoginButton() {
    return ElevatedButton(
      onPressed: _isLoading || !_isPhoneValid ? null : _handleLogin,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
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
              'Send OTP',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
    );
  }

  Widget _buildSignupPrompt() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Don\'t have an account? ',
            style: TextStyle(color: Colors.grey[600])),
        TextButton(
          onPressed: () {
            context.pushReplacement(AppRoute.signup.path);
            // Navigator.of(context).pushReplacement(
            //   MaterialPageRoute(builder: (_) => const SignupScreen()),
            // );
          },
          child: const Text(
            'Sign Up',
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
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
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Expanded(child: _buildLogoAndTitle()),
                    _buildPhoneField(),
                    const SizedBox(height: 32),
                    _buildLoginButton(),
                    const SizedBox(height: 24),
                    _buildSignupPrompt(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
