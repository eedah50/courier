import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'courier_dashboard_screen.dart';
import 'reset_password_screen.dart';
import 'theme.dart';

class CourierAuthScreen extends StatefulWidget {
  const CourierAuthScreen({super.key});

  @override
  State<CourierAuthScreen> createState() => _CourierAuthScreenState();
}

class _CourierAuthScreenState extends State<CourierAuthScreen> {
  bool _isLogin = false; // Default to sign up / onboarding flow
  bool _loading = false;
  bool _hidePass = true;
  bool _rememberMe = false;

  // Sign In Controllers
  final _loginEmailPhone = TextEditingController();
  final _loginPassword = TextEditingController();
  final _loginForm = GlobalKey<FormState>();

  // Multi-step Onboarding State
  int _currentStep = 0;
  final _signUpFormKey = GlobalKey<FormState>();

  // STEP 1: Personal Information
  final _legalNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // STEP 2: Residential Address & Proof of Residence
  final _homeAddressController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  String? _proofOfResidenceFileName;
  bool _hasUploadedProofOfResidence = false;

  // STEP 3: Identity & Live Selfie
  String _govIdType = 'National ID (NIN)';
  String? _govIdFileName;
  bool _hasUploadedGovId = false;
  bool _hasTakenLiveSelfie = false;

  // STEP 4: Vehicle & Driver's License
  String _vehicleType = 'Motorcycle / Bike';
  final _licensePlateController = TextEditingController();
  final _vehicleMakeModelController = TextEditingController();
  final _driverLicenseNumController = TextEditingController();
  final _licenseExpiryController = TextEditingController();

  String? _vehiclePhotoFileName;
  bool _hasUploadedVehiclePhotos = false;

  String? _vehicleInspectionFileName;
  bool _hasUploadedVehicleInspection = false;

  String? _driverLicenseFileName;
  bool _hasUploadedDriverLicense = false;

  // STEP 5: Police Clearance & Guarantor / Next of Kin
  String? _policeClearanceFileName;
  bool _hasUploadedPoliceClearance = false;

  final _guarantorNameController = TextEditingController();
  final _guarantorRelController = TextEditingController();
  final _guarantorPhoneController = TextEditingController();
  final _guarantorEmailController = TextEditingController();
  final _guarantorAddressController = TextEditingController();

  bool _acceptedTerms = false;

  @override
  void dispose() {
    _loginEmailPhone.dispose();
    _loginPassword.dispose();

    _legalNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();

    _homeAddressController.dispose();
    _cityController.dispose();
    _stateController.dispose();

    _licensePlateController.dispose();
    _vehicleMakeModelController.dispose();
    _driverLicenseNumController.dispose();
    _licenseExpiryController.dispose();

    _guarantorNameController.dispose();
    _guarantorRelController.dispose();
    _guarantorPhoneController.dispose();
    _guarantorEmailController.dispose();
    _guarantorAddressController.dispose();

    super.dispose();
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(msg, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w700)),
          backgroundColor: AppColors.yellow,
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  InputDecoration _inputDeco(String label, IconData icon, {Widget? suffix, String? hint}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600),
      hintStyle: const TextStyle(color: Colors.white38, fontSize: 13),
      prefixIcon: Icon(icon, color: AppColors.yellow, size: 20),
      suffixIcon: suffix,
      filled: true,
      fillColor: const Color(0xFF1E1E22),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFF2C2C32)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFF2C2C32)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.yellow, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.redAccent, width: 2),
      ),
    );
  }

  // File Picker Simulator Helper
  Future<void> _simulateFileUpload(
    String documentName,
    Function(String fileName) onUploaded,
  ) async {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF161518),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.cloud_upload_rounded, color: AppColors.yellow, size: 28),
                const SizedBox(width: 12),
                Text(
                  'Upload $documentName',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Select document file format (PDF, JPG, PNG under 10MB)',
              style: TextStyle(color: Colors.white70, fontSize: 13),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.camera_alt_rounded, color: AppColors.yellow),
              title: const Text('Take Photo / Scan Document', style: TextStyle(fontWeight: FontWeight.w700, color: Colors.white)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              tileColor: const Color(0xFF222228),
              onTap: () {
                Navigator.pop(ctx);
                final file = '${documentName.toLowerCase().replaceAll(' ', '_')}_scan.jpg';
                onUploaded(file);
                _toast('$documentName successfully scanned!');
              },
            ),
            const SizedBox(height: 10),
            ListTile(
              leading: const Icon(Icons.folder_open_rounded, color: AppColors.sky),
              title: const Text('Choose from Gallery / Files', style: TextStyle(fontWeight: FontWeight.w700, color: Colors.white)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              tileColor: const Color(0xFF222228),
              onTap: () {
                Navigator.pop(ctx);
                final file = '${documentName.toLowerCase().replaceAll(' ', '_')}_doc.pdf';
                onUploaded(file);
                _toast('$documentName uploaded successfully!');
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // Live Selfie Camera Simulator
  void _startLiveSelfieCheck() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          return AlertDialog(
            backgroundColor: const Color(0xFF141418),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
              side: const BorderSide(color: AppColors.yellow, width: 1.5),
            ),
            title: const Row(
              children: [
                Icon(Icons.face_retouching_natural_rounded, color: AppColors.yellow),
                SizedBox(width: 10),
                Text(
                  'Liveness Verification',
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Position your face inside the circle and blink slowly.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
                const SizedBox(height: 20),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 170,
                      height: 170,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.yellow, width: 4),
                        color: Colors.white10,
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.person_rounded,
                          size: 100,
                          color: Colors.white38,
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 180,
                      height: 180,
                      child: CircularProgressIndicator(
                        color: AppColors.yellow,
                        strokeWidth: 3,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.5)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 16),
                      SizedBox(width: 6),
                      Text(
                        'Face & Liveness Detected',
                        style: TextStyle(
                          color: Color(0xFF34D399),
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  setState(() => _hasTakenLiveSelfie = true);
                  Navigator.pop(ctx);
                  _toast('Live Selfie Liveness Check Verified!');
                },
                child: const Text(
                  'CAPTURE & CONFIRM',
                  style: TextStyle(color: AppColors.yellow, fontWeight: FontWeight.w900),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // Submit Driver Application
  Future<void> _submitDriverRegistration() async {
    if (!_acceptedTerms) {
      _toast('Please agree to Courier Terms & Driver Requirements');
      return;
    }

    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 2000));
    if (!mounted) return;
    setState(() => _loading = false);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF141418),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
          side: const BorderSide(color: AppColors.yellow, width: 1.5),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.yellow.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.task_alt_rounded,
                color: AppColors.yellow,
                size: 54,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Application Submitted!',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Thank you, ${_legalNameController.text.trim().isEmpty ? "Courier" : _legalNameController.text.trim()}.\nYour documents have been queued for verification.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF222228),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.yellow.withValues(alpha: 0.3)),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.confirmation_number_rounded, color: AppColors.yellow, size: 18),
                  SizedBox(width: 8),
                  Text(
                    'Ref No: SKR-DRIVER-9831',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: AppColors.yellow,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.yellow,
                foregroundColor: Colors.black,
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (_) => CourierDashboardScreen(
                      driverName: _legalNameController.text.trim().isEmpty
                          ? 'Delivery Partner'
                          : _legalNameController.text.trim(),
                      email: _emailController.text.trim(),
                      isVerified: false,
                    ),
                  ),
                );
              },
              child: const Text(
                'GO TO COURIER DASHBOARD',
                style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Social Sign-In Handler
  void _socialLogin(String provider) {
    _toast('Signing in with $provider...');
    Future.delayed(const Duration(milliseconds: 1400), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => CourierDashboardScreen(
            driverName: '$provider Driver',
            email: '${provider.toLowerCase()}driver@example.com',
            isVerified: true,
          ),
        ),
      );
    });
  }

  Widget _buildSocialSignInSection({String title = 'Or continue with'}) {
    return Column(
      children: [
        const SizedBox(height: 20),
        Row(
          children: [
            const Expanded(child: Divider(color: Color(0xFF2C2C32))),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                title,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.6),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Expanded(child: Divider(color: Color(0xFF2C2C32))),
          ],
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            Expanded(
              child: _SocialButton(
                icon: Icons.g_mobiledata_rounded,
                label: 'Google',
                iconColor: AppColors.yellow,
                onTap: () => _socialLogin('Google'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _SocialButton(
                icon: Icons.apple_rounded,
                label: 'Apple',
                iconColor: Colors.white,
                onTap: () => _socialLogin('Apple'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _SocialButton(
                icon: Icons.facebook_rounded,
                label: 'Facebook',
                iconColor: const Color(0xFF1877F2),
                onTap: () => _socialLogin('Facebook'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Driver Login Submit
  Future<void> _submitLogin() async {
    if (!_loginForm.currentState!.validate()) return;
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 1400));
    if (!mounted) return;
    setState(() => _loading = false);

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => CourierDashboardScreen(
          driverName: _loginEmailPhone.text.split('@').first,
          email: _loginEmailPhone.text.trim(),
          isVerified: true,
        ),
      ),
    );
  }

  Widget _buildStep1Personal() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Step 1: Legal Name & Account Info',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.yellow),
        ),
        const SizedBox(height: 4),
        const Text(
          'Enter your official name exactly as shown on government IDs.',
          style: TextStyle(color: Colors.white70, fontSize: 13),
        ),
        const SizedBox(height: 18),
        TextFormField(
          controller: _legalNameController,
          textCapitalization: TextCapitalization.words,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          decoration: _inputDeco('Full Legal Name (Must match ID)', Icons.person_rounded),
          validator: (v) => (v == null || v.trim().length < 3) ? 'Enter your full legal name' : null,
        ),
        const SizedBox(height: 14),
        TextFormField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          decoration: _inputDeco('Email Address', Icons.email_rounded),
          validator: (v) => RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v?.trim() ?? '')
              ? null
              : 'Enter a valid email address',
        ),
        const SizedBox(height: 14),
        TextFormField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9+\s]'))],
          decoration: _inputDeco('Phone Number', Icons.phone_rounded, hint: '+234 801 234 5678'),
          validator: (v) => (v ?? '').replaceAll(RegExp(r'\D'), '').length < 8 ? 'Enter valid phone number' : null,
        ),
        const SizedBox(height: 14),
        TextFormField(
          controller: _passwordController,
          obscureText: _hidePass,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          decoration: _inputDeco(
            'Create Password',
            Icons.lock_rounded,
            suffix: IconButton(
              icon: Icon(_hidePass ? Icons.visibility_off_rounded : Icons.visibility_rounded, color: Colors.white54),
              onPressed: () => setState(() => _hidePass = !_hidePass),
            ),
          ),
          validator: (v) => (v == null || v.length < 6) ? 'Password must be at least 6 characters' : null,
        ),
        const SizedBox(height: 14),
        TextFormField(
          controller: _confirmPasswordController,
          obscureText: _hidePass,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          decoration: _inputDeco('Confirm Password', Icons.lock_outline_rounded),
          validator: (v) => v != _passwordController.text ? 'Passwords do not match' : null,
        ),
        _buildSocialSignInSection(title: 'Or sign up with'),
      ],
    );
  }

  Widget _buildStep2Address() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Step 2: Home Address & Proof of Residence',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.yellow),
        ),
        const SizedBox(height: 4),
        const Text(
          'Provide your residential address and upload proof (utility bill or bank statement).',
          style: TextStyle(color: Colors.white70, fontSize: 13),
        ),
        const SizedBox(height: 18),
        TextFormField(
          controller: _homeAddressController,
          textCapitalization: TextCapitalization.words,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          decoration: _inputDeco('Street Address', Icons.home_rounded, hint: '14 Admiralty Way, Lekki'),
          validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter street address' : null,
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _cityController,
                textCapitalization: TextCapitalization.words,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                decoration: _inputDeco('City', Icons.location_city_rounded),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'City required' : null,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: _stateController,
                textCapitalization: TextCapitalization.words,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                decoration: _inputDeco('State', Icons.map_rounded),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'State required' : null,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        const Text(
          'Proof of Residence Document',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AppColors.yellow),
        ),
        const SizedBox(height: 10),
        _DocumentUploadTile(
          title: 'Upload Utility Bill / Bank Statement',
          subtitle: _hasUploadedProofOfResidence ? 'Uploaded: ${_proofOfResidenceFileName ?? "proof_of_address.pdf"}' : 'Required (PDF, JPG or PNG)',
          isUploaded: _hasUploadedProofOfResidence,
          icon: Icons.receipt_long_rounded,
          onTap: () {
            _simulateFileUpload('Proof of Residence', (filename) {
              setState(() {
                _proofOfResidenceFileName = filename;
                _hasUploadedProofOfResidence = true;
              });
            });
          },
        ),
      ],
    );
  }

  Widget _buildStep3Identity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Step 3: Identity ID & Live Selfie',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.yellow),
        ),
        const SizedBox(height: 4),
        const Text(
          'Verify your government photo ID and perform a biometric liveness check.',
          style: TextStyle(color: Colors.white70, fontSize: 13),
        ),
        const SizedBox(height: 18),
        DropdownButtonFormField<String>(
          initialValue: _govIdType,
          dropdownColor: const Color(0xFF18181E),
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          decoration: _inputDeco('Government ID Type', Icons.badge_rounded),
          borderRadius: BorderRadius.circular(16),
          items: const [
            DropdownMenuItem(value: 'National ID (NIN)', child: Text('National ID / NIN Slip', style: TextStyle(color: Colors.white))),
            DropdownMenuItem(value: 'International Passport', child: Text('International Passport', style: TextStyle(color: Colors.white))),
            DropdownMenuItem(value: 'Voter Card', child: Text('Voter’s Identification Card', style: TextStyle(color: Colors.white))),
          ],
          onChanged: (val) {
            if (val != null) setState(() => _govIdType = val);
          },
        ),
        const SizedBox(height: 14),
        _DocumentUploadTile(
          title: 'Upload $_govIdType (Front & Back)',
          subtitle: _hasUploadedGovId ? 'Uploaded: ${_govIdFileName ?? "gov_id_photo.jpg"}' : 'Clear photo of official ID document',
          isUploaded: _hasUploadedGovId,
          icon: Icons.credit_card_rounded,
          onTap: () {
            _simulateFileUpload('Government ID Photo', (filename) {
              setState(() {
                _govIdFileName = filename;
                _hasUploadedGovId = true;
              });
            });
          },
        ),
        const SizedBox(height: 20),
        const Text(
          'Live Selfie / Liveness Check',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AppColors.yellow),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _hasTakenLiveSelfie ? const Color(0xFF064E3B).withValues(alpha: 0.5) : const Color(0xFF1E1E22),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _hasTakenLiveSelfie ? const Color(0xFF10B981) : const Color(0xFF2C2C32),
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: _hasTakenLiveSelfie ? const Color(0xFF10B981) : AppColors.yellow,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _hasTakenLiveSelfie ? Icons.check_rounded : Icons.camera_front_rounded,
                  color: _hasTakenLiveSelfie ? Colors.white : Colors.black,
                  size: 26,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _hasTakenLiveSelfie ? 'Live Selfie Verified ★' : 'Live Selfie Required',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 15,
                        color: _hasTakenLiveSelfie ? const Color(0xFF34D399) : Colors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _hasTakenLiveSelfie ? 'Biometric liveness check passed successfully.' : 'Tap to open camera and scan your face.',
                      style: const TextStyle(fontSize: 12, color: Colors.white70),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _hasTakenLiveSelfie ? Colors.white24 : AppColors.yellow,
                  foregroundColor: _hasTakenLiveSelfie ? Colors.white : Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                onPressed: _startLiveSelfieCheck,
                child: Text(
                  _hasTakenLiveSelfie ? 'RE-TAKE' : 'START',
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStep4VehicleAndLicense() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Step 4: Vehicle & Driver’s License',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.yellow),
        ),
        const SizedBox(height: 4),
        const Text(
          'Enter vehicle plate number, photos, inspection certificate and driver license.',
          style: TextStyle(color: Colors.white70, fontSize: 13),
        ),
        const SizedBox(height: 18),
        DropdownButtonFormField<String>(
          initialValue: _vehicleType,
          dropdownColor: const Color(0xFF18181E),
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          decoration: _inputDeco('Vehicle Category', Icons.two_wheeler_rounded),
          borderRadius: BorderRadius.circular(16),
          items: const [
            DropdownMenuItem(value: 'Motorcycle / Bike', child: Text('Motorcycle / Courier Bike', style: TextStyle(color: Colors.white))),
            DropdownMenuItem(value: 'Car / Sedan', child: Text('Car / Sedan / Hatchback', style: TextStyle(color: Colors.white))),
            DropdownMenuItem(value: 'Cargo Van', child: Text('Delivery / Cargo Van', style: TextStyle(color: Colors.white))),
            DropdownMenuItem(value: 'Pickup / Truck', child: Text('Pickup Truck / Heavy Duty', style: TextStyle(color: Colors.white))),
            DropdownMenuItem(value: 'Bicycle', child: Text('Bicycle / E-Bike', style: TextStyle(color: Colors.white))),
          ],
          onChanged: (val) {
            if (val != null) setState(() => _vehicleType = val);
          },
        ),
        const SizedBox(height: 14),
        TextFormField(
          controller: _licensePlateController,
          textCapitalization: TextCapitalization.characters,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          decoration: _inputDeco('License Plate Number', Icons.subtitles_rounded, hint: 'e.g. LAG-492-IKJ'),
          validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter license plate number' : null,
        ),
        const SizedBox(height: 14),
        TextFormField(
          controller: _vehicleMakeModelController,
          textCapitalization: TextCapitalization.words,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          decoration: _inputDeco('Vehicle Make & Model', Icons.directions_car_rounded, hint: 'e.g. Honda Ace 125 (2022)'),
          validator: (v) => (v == null || v.trim().isEmpty) ? 'Vehicle make and model required' : null,
        ),
        const SizedBox(height: 16),
        _DocumentUploadTile(
          title: 'Clear Vehicle Photos (Front, Side, Plate)',
          subtitle: _hasUploadedVehiclePhotos ? 'Uploaded: ${_vehiclePhotoFileName ?? "vehicle_photos.jpg"}' : 'Clear photos of vehicle showing plate number',
          isUploaded: _hasUploadedVehiclePhotos,
          icon: Icons.add_a_photo_rounded,
          onTap: () {
            _simulateFileUpload('Clear Vehicle Photos', (filename) {
              setState(() {
                _vehiclePhotoFileName = filename;
                _hasUploadedVehiclePhotos = true;
              });
            });
          },
        ),
        const SizedBox(height: 12),
        _DocumentUploadTile(
          title: 'Vehicle Inspection Certificate',
          subtitle: _hasUploadedVehicleInspection ? 'Uploaded: ${_vehicleInspectionFileName ?? "roadworthiness_cert.pdf"}' : 'Valid Roadworthiness / Inspection Certificate',
          isUploaded: _hasUploadedVehicleInspection,
          icon: Icons.verified_rounded,
          onTap: () {
            _simulateFileUpload('Vehicle Inspection Certificate', (filename) {
              setState(() {
                _vehicleInspectionFileName = filename;
                _hasUploadedVehicleInspection = true;
              });
            });
          },
        ),
        const SizedBox(height: 20),
        const Text(
          'Driver’s License Information',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AppColors.yellow),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _driverLicenseNumController,
                textCapitalization: TextCapitalization.characters,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                decoration: _inputDeco('Driver License No.', Icons.drive_eta_rounded),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'License number required' : null,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: _licenseExpiryController,
                keyboardType: TextInputType.datetime,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                decoration: _inputDeco('Expiry Date', Icons.calendar_month_rounded, hint: 'MM/YY'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Expiry date required' : null,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _DocumentUploadTile(
          title: 'Upload Driver’s License Document',
          subtitle: _hasUploadedDriverLicense ? 'Uploaded: ${_driverLicenseFileName ?? "drivers_license.jpg"}' : 'Photo of official driver’s license card',
          isUploaded: _hasUploadedDriverLicense,
          icon: Icons.card_membership_rounded,
          onTap: () {
            _simulateFileUpload('Driver License Photo', (filename) {
              setState(() {
                _driverLicenseFileName = filename;
                _hasUploadedDriverLicense = true;
              });
            });
          },
        ),
      ],
    );
  }

  Widget _buildStep5ClearanceAndGuarantor() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Step 5: Police Clearance & Guarantor / Next of Kin',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.yellow),
        ),
        const SizedBox(height: 4),
        const Text(
          'Upload police clearance certificate and submit reliable guarantor/next of kin details.',
          style: TextStyle(color: Colors.white70, fontSize: 13),
        ),
        const SizedBox(height: 18),
        _DocumentUploadTile(
          title: 'Police Clearance Certificate',
          subtitle: _hasUploadedPoliceClearance ? 'Uploaded: ${_policeClearanceFileName ?? "police_clearance.pdf"}' : 'Official police character certificate or background check',
          isUploaded: _hasUploadedPoliceClearance,
          icon: Icons.security_rounded,
          onTap: () {
            _simulateFileUpload('Police Clearance Certificate', (filename) {
              setState(() {
                _policeClearanceFileName = filename;
                _hasUploadedPoliceClearance = true;
              });
            });
          },
        ),
        const SizedBox(height: 24),
        const Text(
          'Guarantor / Next of Kin Details',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: AppColors.yellow),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _guarantorNameController,
          textCapitalization: TextCapitalization.words,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          decoration: _inputDeco('Guarantor / Next of Kin Full Name', Icons.person_outline_rounded),
          validator: (v) => (v == null || v.trim().length < 3) ? 'Guarantor full name required' : null,
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _guarantorRelController,
                textCapitalization: TextCapitalization.words,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                decoration: _inputDeco('Relationship', Icons.people_outline_rounded, hint: 'Parent/Spouse/Relative'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Relationship required' : null,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: _guarantorPhoneController,
                keyboardType: TextInputType.phone,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9+\s]'))],
                decoration: _inputDeco('Phone Number', Icons.phone_iphone_rounded),
                validator: (v) => (v ?? '').replaceAll(RegExp(r'\D'), '').length < 8 ? 'Valid phone required' : null,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        TextFormField(
          controller: _guarantorEmailController,
          keyboardType: TextInputType.emailAddress,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          decoration: _inputDeco('Guarantor Email Address (Optional)', Icons.alternate_email_rounded),
        ),
        const SizedBox(height: 14),
        TextFormField(
          controller: _guarantorAddressController,
          textCapitalization: TextCapitalization.words,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          decoration: _inputDeco('Guarantor Residential / Office Address', Icons.pin_drop_rounded),
          validator: (v) => (v == null || v.trim().isEmpty) ? 'Guarantor address required' : null,
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Checkbox(
              value: _acceptedTerms,
              activeColor: AppColors.yellow,
              checkColor: Colors.black,
              side: const BorderSide(color: Colors.white54),
              onChanged: (val) => setState(() => _acceptedTerms = val ?? false),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _acceptedTerms = !_acceptedTerms),
                child: const Text(
                  'I certify that all documents and guarantor details provided are authentic and agree to Sekure Courier Driver Terms.',
                  style: TextStyle(fontSize: 12, color: Colors.white70, height: 1.3),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSignUpOnboardingStepper() {
    final steps = ['Account', 'Address', 'Identity', 'Vehicle', 'Guarantor'];

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(steps.length, (index) {
            final active = index <= _currentStep;
            final isCurrent = index == _currentStep;

            return Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        Container(
                          width: 30,
                          height: 30,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isCurrent
                                ? AppColors.yellow
                                : active
                                    ? AppColors.yellow.withValues(alpha: 0.3)
                                    : const Color(0xFF222228),
                            border: Border.all(
                              color: isCurrent ? AppColors.yellow : active ? AppColors.yellow.withValues(alpha: 0.5) : const Color(0xFF2C2C32),
                            ),
                          ),
                          child: Text(
                            '${index + 1}',
                            style: TextStyle(
                              color: isCurrent ? Colors.black : active ? AppColors.yellow : Colors.white54,
                              fontWeight: FontWeight.w900,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          steps[index],
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: isCurrent ? FontWeight.w900 : FontWeight.w600,
                            color: isCurrent ? AppColors.yellow : Colors.white54,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (index < steps.length - 1)
                    Container(
                      width: 10,
                      height: 2,
                      color: index < _currentStep ? AppColors.yellow : const Color(0xFF2C2C32),
                    ),
                ],
              ),
            );
          }),
        ),

        const SizedBox(height: 24),

        Form(
          key: _signUpFormKey,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: KeyedSubtree(
              key: ValueKey(_currentStep),
              child: [
                _buildStep1Personal(),
                _buildStep2Address(),
                _buildStep3Identity(),
                _buildStep4VehicleAndLicense(),
                _buildStep5ClearanceAndGuarantor(),
              ][_currentStep],
            ),
          ),
        ),

        const SizedBox(height: 24),

        Row(
          children: [
            if (_currentStep > 0) ...[
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 52),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    side: const BorderSide(color: AppColors.yellow, width: 1.5),
                  ),
                  onPressed: () => setState(() => _currentStep--),
                  child: const Text('BACK', style: TextStyle(color: AppColors.yellow, fontWeight: FontWeight.w800)),
                ),
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              flex: 2,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.yellow,
                  foregroundColor: Colors.black,
                  minimumSize: const Size(0, 52),
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: () {
                  if (_currentStep < 4) {
                    if (_signUpFormKey.currentState!.validate()) {
                      setState(() => _currentStep++);
                    } else {
                      _toast('Please fill required fields before proceeding');
                    }
                  } else {
                    if (_signUpFormKey.currentState!.validate()) {
                      _submitDriverRegistration();
                    } else {
                      _toast('Please complete all guarantor & verification fields');
                    }
                  }
                },
                child: Text(
                  _currentStep == 4 ? 'SUBMIT FOR VERIFICATION' : 'CONTINUE STEP ${_currentStep + 2}',
                  style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 0.8),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLoginView() {
    return Form(
      key: _loginForm,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _loginEmailPhone,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
            decoration: _inputDeco('Email Address or Phone', Icons.account_circle_rounded),
            validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter driver email or phone' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _loginPassword,
            obscureText: _hidePass,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
            decoration: _inputDeco(
              'Password',
              Icons.lock_rounded,
              suffix: IconButton(
                icon: Icon(_hidePass ? Icons.visibility_off_rounded : Icons.visibility_rounded, color: Colors.white54),
                onPressed: () => setState(() => _hidePass = !_hidePass),
              ),
            ),
            validator: (v) => (v == null || v.length < 6) ? 'Password required' : null,
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  SizedBox(
                    height: 24,
                    width: 24,
                    child: Checkbox(
                      value: _rememberMe,
                      activeColor: AppColors.yellow,
                      checkColor: Colors.black,
                      side: const BorderSide(color: Colors.white54),
                      onChanged: (val) => setState(() => _rememberMe = val ?? false),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text('Remember me', style: TextStyle(color: Colors.white70, fontSize: 12.5)),
                ],
              ),
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const ResetPasswordScreen(isCourier: true),
                    ),
                  );
                },
                child: const Text(
                  'Forgot Password?',
                  style: TextStyle(color: AppColors.yellow, fontWeight: FontWeight.w800, fontSize: 12.5),
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          DeliveryLoginButton(
            label: 'Login',
            loading: _loading,
            onPressed: _submitLogin,
          ),
          _buildSocialSignInSection(),
        ],
      ),
    );
  }

  Widget _toggleTab() {
    Widget tab(String label, bool isLoginTab) {
      final selected = _isLogin == isLoginTab;
      return Expanded(
        child: GestureDetector(
          onTap: () => setState(() => _isLogin = isLoginTab),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: selected ? AppColors.yellow : Colors.transparent,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w900,
                color: selected ? Colors.black : Colors.white70,
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E22),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF2C2C32)),
      ),
      child: Row(children: [tab('Driver Register', false), tab('Driver Login', true)]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _isLogin ? 'Courier Login' : 'Driver Registration',
                    style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -0.5),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _isLogin ? 'Access your driver console & deliveries.' : 'Join Sekure as a verified courier partner.',
                    style: const TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 28),
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: const Color(0xFF121216),
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(color: const Color(0xFF222228)),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withValues(alpha: 0.8), blurRadius: 30, offset: const Offset(0, 15)),
                      ],
                    ),
                    child: Column(
                      children: [
                        _toggleTab(),
                        const SizedBox(height: 24),
                        _isLogin ? _buildLoginView() : _buildSignUpOnboardingStepper(),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: GestureDetector(
                      onTap: () => setState(() => _isLogin = !_isLogin),
                      child: Text.rich(
                        TextSpan(
                          text: _isLogin ? "Don't have a driver account? " : "Already registered as courier? ",
                          style: const TextStyle(color: Colors.white70, fontSize: 13.5),
                          children: [
                            TextSpan(
                              text: _isLogin ? 'Register' : 'Login',
                              style: const TextStyle(color: AppColors.yellow, fontWeight: FontWeight.w900),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DocumentUploadTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isUploaded;
  final IconData icon;
  final VoidCallback onTap;

  const _DocumentUploadTile({
    required this.title,
    required this.subtitle,
    required this.isUploaded,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isUploaded ? const Color(0xFF064E3B).withValues(alpha: 0.45) : const Color(0xFF1E1E22),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isUploaded ? const Color(0xFF10B981) : const Color(0xFF2C2C32),
          width: isUploaded ? 1.5 : 1,
        ),
      ),
      child: ListTile(
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isUploaded ? const Color(0xFF10B981).withValues(alpha: 0.2) : AppColors.yellow.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(
            isUploaded ? Icons.check_circle_rounded : icon,
            color: isUploaded ? const Color(0xFF34D399) : AppColors.yellow,
            size: 22,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 13.5,
            color: Colors.white,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 12,
            color: isUploaded ? const Color(0xFF34D399) : Colors.white60,
            fontWeight: isUploaded ? FontWeight.w700 : FontWeight.normal,
          ),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: isUploaded ? const Color(0xFF10B981) : AppColors.yellow,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            isUploaded ? 'UPLOADED' : 'UPLOAD',
            style: TextStyle(
              color: isUploaded ? Colors.white : Colors.black,
              fontSize: 11,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color iconColor;
  final VoidCallback onTap;

  const _SocialButton({
    required this.icon,
    required this.label,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 46,
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E22),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2C2C32)),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          splashColor: AppColors.yellow.withValues(alpha: 0.2),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: iconColor, size: 22),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 12.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Login button with a tiny rider on a delivery bike.
class DeliveryLoginButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final bool loading;
  final String label;
  final Duration deliveryDuration;

  const DeliveryLoginButton({
    super.key,
    required this.onPressed,
    required this.loading,
    this.label = 'Login',
    this.deliveryDuration = const Duration(milliseconds: 2000),
  });

  @override
  State<DeliveryLoginButton> createState() => _DeliveryLoginButtonState();
}

class _DeliveryLoginButtonState extends State<DeliveryLoginButton>
    with TickerProviderStateMixin {
  late final AnimationController _idle;
  late final AnimationController _run;

  @override
  void initState() {
    super.initState();
    _idle = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))
      ..repeat();
    _run = AnimationController(vsync: this, duration: widget.deliveryDuration);
    if (widget.loading) _run.forward(from: 0);
  }

  @override
  void didUpdateWidget(covariant DeliveryLoginButton old) {
    super.didUpdateWidget(old);
    if (widget.loading && !old.loading) {
      _run.forward(from: 0);
    } else if (!widget.loading && old.loading) {
      _run.reset();
    }
  }

  @override
  void dispose() {
    _idle.dispose();
    _run.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_idle, _run]),
      builder: (context, _) {
        final t = _run.value;
        final delivering = widget.loading;
        final labelOpacity = delivering ? (1 - t * 8).clamp(0.0, 1.0) : 1.0;

        return Material(
          color: AppColors.yellow,
          elevation: 4,
          borderRadius: BorderRadius.circular(16),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: delivering ? null : widget.onPressed,
            child: SizedBox(
              height: 54,
              width: double.infinity,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _DeliveryPainter(
                        idle: _idle.value,
                        t: t,
                        delivering: delivering,
                      ),
                    ),
                  ),
                  Center(
                    child: Opacity(
                      opacity: labelOpacity,
                      child: Text(
                        widget.label,
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _DeliveryPainter extends CustomPainter {
  final double idle;
  final double t;
  final bool delivering;

  _DeliveryPainter({
    required this.idle,
    required this.t,
    required this.delivering,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (!delivering) return;
    final w = size.width;
    final h = size.height;
    final gy = h - 10;
    final stroke = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    final fill = Paint()..color = Colors.black;

    final x = w * t.clamp(0.0, 1.0);

    // Scooter wheels + rider
    canvas.drawCircle(Offset(x - 12, gy), 5, stroke);
    canvas.drawCircle(Offset(x + 12, gy), 5, stroke);
    canvas.drawLine(Offset(x - 12, gy), Offset(x + 12, gy), stroke);
    canvas.drawCircle(Offset(x, gy - 16), 5, fill);
  }

  @override
  bool shouldRepaint(covariant _DeliveryPainter old) =>
      old.idle != idle || old.t != t || old.delivering != delivering;
}
