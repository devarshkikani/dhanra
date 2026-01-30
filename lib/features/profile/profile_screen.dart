import 'package:dhanra/core/routing/route_names.dart';
import 'package:dhanra/core/services/local_storage_service.dart';
import 'package:dhanra/core/theme/gradients.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // bool _isLoading = false;
  final LocalStorageService _storage = LocalStorageService();

  void _showRateDialog() {
    showDialog(
      context: context,
      builder: (context) {
        double selected = 5;
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title:
              const Text('Rate Dhanra', style: TextStyle(color: Colors.white)),
          content: StatefulBuilder(
            builder: (context, setState) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (i) {
                    final isFilled = i < selected;
                    return IconButton(
                      onPressed: () => setState(() => selected = i + 1),
                      icon: Icon(
                        isFilled
                            ? Icons.star_rounded
                            : Icons.star_border_rounded,
                        color: Colors.amber,
                        size: 32,
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 8),
                const Text('Thanks for your feedback!',
                    style: TextStyle(color: Colors.white70)),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text('About Us', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Dhanra helps you track SMS-based transactions, accounts, and insights.\n\nVersion 1.0.0',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showInviteDialog() async {
    const referral = 'Use Dhanra with me! Code: DHANRA100';
    await Clipboard.setData(const ClipboardData(text: referral));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Invite text copied to clipboard')),
    );
  }

  void _showChatDialog() async {
    const supportEmail = 'support@dhanra.app';
    await Clipboard.setData(const ClipboardData(text: supportEmail));
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title:
            const Text('Chat with Us', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Email us at support@dhanra.app or paste in your mail client. The address has been copied to your clipboard.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text('Help & FAQ', style: TextStyle(color: Colors.white)),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('• Why permissions?', style: TextStyle(color: Colors.white)),
              SizedBox(height: 6),
              Text(
                  'We use SMS read permission to parse transaction alerts only.',
                  style: TextStyle(color: Colors.white70)),
              SizedBox(height: 12),
              Text('• How to refresh?', style: TextStyle(color: Colors.white)),
              SizedBox(height: 6),
              Text('Open the app; new messages are auto-parsed on launch.',
                  style: TextStyle(color: Colors.white70)),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> handleLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(true);
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      // setState(() => _isLoading = true);

      try {
        await FirebaseAuth.instance.signOut();

        await _storage.setUserLoggedOut();
        await _storage.clearSmsData();
        await _storage.clearUserData();

        if (mounted) {
          context.pushReplacement(AppRoute.signup.path);
          // Navigator.of(context).pushAndRemoveUntil(
          //   MaterialPageRoute(
          //     builder: (context) => const SignupScreen(),
          //   ),
          //   (route) => false,
          // );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error logging out: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          // setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topLeft,
      children: [
        Gradients.gradient(
          top: -MediaQuery.of(context).size.height,
          left: -MediaQuery.of(context).size.width,
          right: 0,
          context: context,
        ),
        Image.asset(
          "assets/images/circle_ui.png",
          opacity: const AlwaysStoppedAnimation(.8),
          fit: BoxFit.cover,
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: const Text('Profile', style: TextStyle(color: Colors.white)),
            centerTitle: true,
          ),
          body: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Profile Avatar
                  const CircleAvatar(
                    radius: 44,
                    backgroundColor: Colors.white12,
                    child: Icon(Icons.person, size: 60, color: Colors.white70),
                  ),
                  const SizedBox(height: 16),
                  // Name
                  Text(
                    _storage.userName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  // Mobile Number
                  Text(
                    _storage.userPhone,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 28),
                  // Profile Options
                  _ProfileOption(
                    icon: Icons.star_rate_rounded,
                    label: 'Rate Us',
                    onTap: _showRateDialog,
                  ),
                  _ProfileOption(
                    icon: Icons.info_outline_rounded,
                    label: 'About Us',
                    onTap: _showAboutDialog,
                  ),
                  _ProfileOption(
                    icon: Icons.group_add_rounded,
                    label: 'Invite',
                    onTap: _showInviteDialog,
                  ),
                  _ProfileOption(
                    icon: Icons.chat_bubble_outline_rounded,
                    label: 'Chat with Us',
                    onTap: _showChatDialog,
                  ),
                  _ProfileOption(
                    icon: Icons.help_outline_rounded,
                    label: 'Help & FAQ',
                    onTap: _showHelpDialog,
                  ),
                  const SizedBox(height: 8),
                  // Logout Option (highlighted)
                  _ProfileOption(
                    icon: Icons.logout_rounded,
                    label: 'Logout',
                    onTap: handleLogout,
                    color: Colors.redAccent,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// Widget for each profile option row
class _ProfileOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  const _ProfileOption({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(10),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Icon(icon, color: color ?? Colors.white70, size: 26),
              const SizedBox(width: 18),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: color ?? Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded,
                  color: Colors.white24, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}
