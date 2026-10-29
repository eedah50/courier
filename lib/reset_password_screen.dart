import 'package:flutter/material.dart';
import 'otp_verification_screen.dart';
import 'theme.dart';

class ResetPasswordScreen extends StatefulWidget {
  final bool isCourier;
  const ResetPasswordScreen({super.key, this.isCourier = false});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _contactController = TextEditingController();
  final _newPassController = TextEditingController();
  final _confirmPassController = TextEditingController();

  bool _isOtpVerified = false;
  bool _loading = false;
  bool _hidePass = true;

  @override
  void dispose() {
    _contactController.dispose();
    _newPassController.dispose();
    _confirmPassController.dispose();
    super.dispose();
  }

  InputDecoration _pillInputDeco(String hint, IconData icon, {Widget? suffix}) {
    OutlineInputBorder border(Color c, [double w = 1]) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: c, width: w),
        );
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.black38, fontSize: 13.5),
      prefixIcon: Icon(icon, color: AppColors.orange, size: 20),
      suffixIcon: suffix,
      filled: true,
      fillColor: const Color(0xFFF6F8FA),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      enabledBorder: border(Colors.black12),
      focusedBorder: border(AppColors.orange, 1.8),
      errorBorder: border(Colors.redAccent),
      focusedErrorBorder: border(Colors.redAccent, 1.8),
    );
  }

  Future<void> _submitReset() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_isOtpVerified) {
      // Step 1: Open OTP verification screen matching the image design
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => OtpVerificationScreen(
            phoneNumber: _contactController.text.trim(),
            onVerified: () {
              Navigator.pop(context); // return to reset screen
              setState(() => _isOtpVerified = true);
            },
          ),
        ),
      );
      return;
    }

    // Step 2: Save new password & show Password Changed Success Modal
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 1400));
    if (!mounted) return;
    setState(() => _loading = false);

    _showPasswordChangedModal();
  }

  void _showPasswordChangedModal() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
        insetPadding: const EdgeInsets.all(24),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Serrated Lemon Yellow Checkmark Badge
              Container(
                width: 76,
                height: 76,
                decoration: const BoxDecoration(
                  color: AppColors.lemon,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: AppColors.black,
                  size: 44,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Password Changed!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: AppColors.black,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Your password has been changed\nsuccessfully',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 13.5,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 28),

              // Get Started Button
              GestureDetector(
                onTap: () {
                  Navigator.pop(ctx); // pop modal
                  Navigator.pop(context); // pop reset screen back to login
                },
                child: Container(
                  height: 52,
                  width: double.infinity,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.lemon,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.lemon.withValues(alpha: 0.45),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Text(
                    'Get started',
                    style: TextStyle(
                      color: AppColors.black,
                      fontWeight: FontWeight.w900,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Top Hero Header in Lemon Yellow & Orange Gradient
            Container(
              height: size.height * 0.38,
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.lemon, AppColors.orange],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Circled Back Button
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.25),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.chevron_left_rounded,
                            color: AppColors.black,
                            size: 28,
                          ),
                        ),
                      ),

                      const Spacer(),

                      // Top Title & Subtitle
                      Text(
                        _isOtpVerified
                            ? 'Reset Your Password'
                            : widget.isCourier
                                ? 'Driver Account Recovery'
                                : 'Reset Password & Stay Secure',
                        style: const TextStyle(
                          color: AppColors.black,
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Organize your deliveries easily in one simple, powerful app.',
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: 13,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
            ),

            // Overlapping Card
            Transform.translate(
              offset: const Offset(0, -24),
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _isOtpVerified ? 'Set New Password' : 'Reset Password',
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          color: AppColors.black,
                        ),
                      ),
                      const SizedBox(height: 6),

                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Text.rich(
                          TextSpan(
                            text: "Remembered your password? ",
                            style: const TextStyle(color: Colors.black54, fontSize: 13),
                            children: const [
                              TextSpan(
                                text: 'Log in',
                                style: TextStyle(
                                  color: AppColors.orange,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 28),

                      // Input Fields
                      if (!_isOtpVerified) ...[
                        TextFormField(
                          controller: _contactController,
                          style: const TextStyle(color: AppColors.black, fontSize: 14, fontWeight: FontWeight.w600),
                          keyboardType: TextInputType.emailAddress,
                          decoration: _pillInputDeco('Enter your email or phone', Icons.email_outlined),
                          validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter your email or phone' : null,
                        ),
                      ] else ...[
                        TextFormField(
                          controller: _newPassController,
                          style: const TextStyle(color: AppColors.black, fontSize: 14, fontWeight: FontWeight.w600),
                          obscureText: _hidePass,
                          decoration: _pillInputDeco(
                            'New Password',
                            Icons.lock_outline_rounded,
                            suffix: IconButton(
                              icon: Icon(
                                _hidePass ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                color: Colors.black45,
                                size: 20,
                              ),
                              onPressed: () => setState(() => _hidePass = !_hidePass),
                            ),
                          ),
                          validator: (v) => (v == null || v.length < 6) ? 'At least 6 characters' : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _confirmPassController,
                          style: const TextStyle(color: AppColors.black, fontSize: 14, fontWeight: FontWeight.w600),
                          obscureText: _hidePass,
                          decoration: _pillInputDeco('Confirm New Password', Icons.lock_outline_rounded),
                          validator: (v) => v != _newPassController.text ? 'Passwords do not match' : null,
                        ),
                      ],

                      const SizedBox(height: 32),

                      // Full-Width Stadium Lemon Yellow Action Button
                      GestureDetector(
                        onTap: _loading ? null : _submitReset,
                        child: Container(
                          height: 52,
                          width: double.infinity,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: AppColors.lemon,
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.lemon.withValues(alpha: 0.5),
                                blurRadius: 18,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: _loading
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: AppColors.black,
                                  ),
                                )
                              : Text(
                                  _isOtpVerified ? 'Save Password' : 'Send Code',
                                  style: const TextStyle(
                                    color: AppColors.black,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 15,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
