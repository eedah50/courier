import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dashboard_screen.dart';
import 'theme.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();
  final _pass = TextEditingController();
  final _confirm = TextEditingController();

  bool _isLogin = true;
  bool _loading = false;
  bool _hidePass = true;

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _email.dispose();
    _pass.dispose();
    _confirm.dispose();
    super.dispose();
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(msg),
        backgroundColor: AppColors.black,
        behavior: SnackBarBehavior.floating,
      ));
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _loading = true);

    // TODO: replace with your real login / signup API call.
    // On signup, send _name.text, _phone.text.trim(), email and password.
    await Future.delayed(const Duration(milliseconds: 1500));

    if (!mounted) return;
    setState(() => _loading = false);
    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (_) => DashboardScreen(
        name: _isLogin ? _email.text.trim() : _name.text.trim(),
        email: _email.text.trim(),
      ),
    ));
  }

  Widget _blob(Color c, double size) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      gradient: RadialGradient(
        colors: [c.withValues(alpha: .40), c.withValues(alpha: 0)],
      ),
    ),
  );

  InputDecoration _decoration(String label, IconData icon, {Widget? suffix}) {
    OutlineInputBorder border(Color c, [double w = 1]) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: c, width: w),
    );
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: AppColors.orange),
      suffixIcon: suffix,
      filled: true,
      fillColor: const Color(0xFFF4F7FA),
      enabledBorder: border(Colors.transparent),
      focusedBorder: border(AppColors.orange, 2),
      errorBorder: border(Colors.redAccent),
      focusedErrorBorder: border(Colors.redAccent, 2),
    );
  }

  Widget _logo() => Container(
    width: 76,
    height: 76,
    decoration: const BoxDecoration(
      shape: BoxShape.circle,
      color: AppColors.black,
    ),
    child: ClipOval(
      child: Image.asset(
        'images/logo1.png',
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Image.asset(
          'images/logo.png',
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => const Icon(
            Icons.shield_rounded,
            size: 42,
            color: AppColors.yellow,
          ),
        ),
      ),
    ),
  );

  Widget _toggle() {
    Widget tab(String label, bool login) {
      final selected = _isLogin == login;
      return Expanded(
        child: GestureDetector(
          onTap: () => setState(() => _isLogin = login),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            padding: const EdgeInsets.symmetric(vertical: 12),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: selected ? AppColors.black : Colors.transparent,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: selected ? AppColors.yellow : Colors.black54,
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFE6F4FC),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(children: [tab('Login', true), tab('Sign Up', false)]),
    );
  }

  Widget _signupFields() => Column(
    children: [
      TextFormField(
        controller: _name,
        textCapitalization: TextCapitalization.words,
        decoration: _decoration('Full name', Icons.person_rounded),
        validator: (v) =>
        (v == null || v.trim().length < 2) ? 'Enter your name' : null,
      ),
      const SizedBox(height: 14),
      TextFormField(
        controller: _phone,
        keyboardType: TextInputType.phone,
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'[0-9+\s]')),
        ],
        decoration: _decoration('Phone number', Icons.phone_rounded)
            .copyWith(hintText: '+234 801 234 5678'),
        validator: (v) {
          final digits = (v ?? '').replaceAll(RegExp(r'\D'), '');
          return (digits.length < 7 || digits.length > 15)
              ? 'Enter a valid phone number'
              : null;
        },
      ),
      const SizedBox(height: 14),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lemon,
      body: Stack(
        children: [
          Positioned(top: -90, right: -70, child: _blob(AppColors.orange, 280)),
          Positioned(top: 160, left: -110, child: _blob(Colors.white, 260)),
          Positioned(
              bottom: -110, right: -50, child: _blob(AppColors.sky, 280)),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: 1),
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.easeOutCubic,
                  builder: (context, t, child) => Opacity(
                    opacity: t,
                    child: Transform.translate(
                      offset: Offset(0, 40 * (1 - t)),
                      child: child,
                    ),
                  ),
                  child: Column(
                    children: [
                      _logo(),
                      const SizedBox(height: 14),
                      const Text(
                        'SEKURE COURIER',
                        style: TextStyle(
                          color: AppColors.black,
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 3,
                        ),
                      ),
                      const SizedBox(height: 6),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 250),
                        child: Text(
                          _isLogin
                              ? 'Welcome back! Sign in to continue.'
                              : 'Create your account to start shipping.',
                          key: ValueKey(_isLogin),
                          style: const TextStyle(
                            color: Colors.black87,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.all(22),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.orange.withValues(alpha: .25),
                              blurRadius: 40,
                              offset: const Offset(0, 16),
                            ),
                          ],
                        ),
                        child: Form(
                          key: _form,
                          child: Column(
                            children: [
                              _toggle(),
                              const SizedBox(height: 20),
                              AnimatedSize(
                                duration: const Duration(milliseconds: 250),
                                curve: Curves.easeOut,
                                child: _isLogin
                                    ? const SizedBox(width: double.infinity)
                                    : _signupFields(),
                              ),
                              TextFormField(
                                controller: _email,
                                keyboardType: TextInputType.emailAddress,
                                decoration:
                                _decoration('Email', Icons.email_rounded),
                                validator: (v) =>
                                RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                                    .hasMatch(v?.trim() ?? '')
                                    ? null
                                    : 'Enter a valid email',
                              ),
                              const SizedBox(height: 14),
                              TextFormField(
                                controller: _pass,
                                obscureText: _hidePass,
                                decoration: _decoration(
                                  'Password',
                                  Icons.lock_rounded,
                                  suffix: IconButton(
                                    icon: Icon(
                                      _hidePass
                                          ? Icons.visibility_off_rounded
                                          : Icons.visibility_rounded,
                                      color: Colors.black45,
                                    ),
                                    onPressed: () =>
                                        setState(() => _hidePass = !_hidePass),
                                  ),
                                ),
                                validator: (v) => (v == null || v.length < 6)
                                    ? 'At least 6 characters'
                                    : null,
                              ),
                              AnimatedSize(
                                duration: const Duration(milliseconds: 250),
                                curve: Curves.easeOut,
                                child: _isLogin
                                    ? const SizedBox(width: double.infinity)
                                    : Padding(
                                  padding: const EdgeInsets.only(top: 14),
                                  child: TextFormField(
                                    controller: _confirm,
                                    obscureText: _hidePass,
                                    decoration: _decoration(
                                      'Confirm password',
                                      Icons.lock_outline_rounded,
                                    ),
                                    validator: (v) => v != _pass.text
                                        ? 'Passwords do not match'
                                        : null,
                                  ),
                                ),
                              ),
                              if (_isLogin)
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton(
                                    onPressed: () => _toast(
                                        'Hook up password reset to your backend.'),
                                    child: const Text(
                                      'Forgot password?',
                                      style: TextStyle(color: AppColors.orange),
                                    ),
                                  ),
                                )
                              else
                                const SizedBox(height: 14),
                              const SizedBox(height: 4),
                              GestureDetector(
                                onTap: _loading ? null : _submit,
                                child: Container(
                                  height: 54,
                                  width: double.infinity,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    gradient: AppColors.brandGradient,
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.orange
                                            .withValues(alpha: .4),
                                        blurRadius: 16,
                                        offset: const Offset(0, 6),
                                      ),
                                    ],
                                  ),
                                  child: _loading
                                      ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 3,
                                      color: AppColors.black,
                                    ),
                                  )
                                      : Text(
                                    _isLogin ? 'LOGIN' : 'CREATE ACCOUNT',
                                    style: const TextStyle(
                                      color: AppColors.black,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 1.5,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              GestureDetector(
                                onTap: () =>
                                    setState(() => _isLogin = !_isLogin),
                                child: Text.rich(
                                  TextSpan(
                                    text: _isLogin
                                        ? "Don't have an account? "
                                        : 'Already have an account? ',
                                    style:
                                    const TextStyle(color: Colors.black54),
                                    children: [
                                      TextSpan(
                                        text: _isLogin ? 'Sign Up' : 'Login',
                                        style: const TextStyle(
                                          color: AppColors.sky,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}