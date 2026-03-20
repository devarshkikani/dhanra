import 'package:dhanra/core/theme/app_colors.dart';
import 'package:dhanra/core/routing/route_names.dart';
import 'package:dhanra/features/auth/data/auth_repository.dart';
import 'package:dhanra/core/util/firebase_handler.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();

  bool _isLoading = false;
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
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

  Future<void> _handleSignup(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;

    FocusManager.instance.primaryFocus?.unfocus();

    setState(() => _isLoading = true);

    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final userName = _nameController.text.trim();

    try {
      final userCredential = await AuthRepository().signUpWithEmail(
        email: email,
        password: password,
      );

      await AuthRepository().handlePostSignIn(
        user: userCredential.user,
        isSignup: true,
        userName: userName,
      );

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (context.mounted) {
        context.go(AppRoute.home.path);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showError(FirebaseHandler.getReadableErrorMessage(e));
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
          'Your Personal Finance Manager',
          textAlign: TextAlign.center,
          style: Theme.of(context)
              .textTheme
              .bodyLarge
              ?.copyWith(color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildNameField() {
    return TextFormField(
      controller: _nameController,
      autofocus: true,
      textInputAction: TextInputAction.next,
      keyboardType: TextInputType.text,
      textCapitalization: TextCapitalization.words,
      decoration: _buildInputDecoration(
        label: 'Full Name',
        icon: Icons.person_outline,
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter your name';
        }
        if (value.trim().length < 2) {
          return 'Name must be at least 2 characters';
        }
        return null;
      },
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      textInputAction: TextInputAction.next,
      keyboardType: TextInputType.emailAddress,
      decoration: _buildInputDecoration(
        label: 'Email Address',
        icon: Icons.email_outlined,
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your email';
        }
        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
          return 'Please enter a valid email';
        }
        return null;
      },
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: !_isPasswordVisible,
      decoration: _buildInputDecoration(
        label: 'Password',
        icon: Icons.lock_outline,
        suffixIcon: IconButton(
          icon: Icon(
            _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
            color: Colors.grey,
          ),
          onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter a password';
        }
        if (value.length < 6) {
          return 'Password must be at least 6 characters';
        }
        return null;
      },
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

  Widget _buildSignupButton(BuildContext context) {
    return ElevatedButton(
      onPressed: _isLoading
          ? null
          : () {
              _handleSignup(context);
            },
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
              'Continue',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
    );
  }

  Widget _buildLoginPrompt() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Already have an account? ',
            style: TextStyle(color: Colors.grey[600])),
        TextButton(
          onPressed: () {
            // ✅ Replace with GoRouter navigation
            context.go(AppRoute.login.path);
          },
          child: const Text(
            'Login',
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTerms() {
    return Text(
      'By continuing, you agree to our Terms of Service and Privacy Policy',
      textAlign: TextAlign.center,
      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
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
                    _buildNameField(),
                    const SizedBox(height: 20),
                    _buildEmailField(),
                    const SizedBox(height: 20),
                    _buildPasswordField(),
                    const SizedBox(height: 32),
                    _buildSignupButton(context),
                    const SizedBox(height: 24),
                    _buildLoginPrompt(),
                    const SizedBox(height: 40),
                    _buildTerms(),
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
