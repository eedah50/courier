import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'courier_dashboard_screen.dart';
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
  bool _isSimulatingSelfie = false;

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
          content: Text(msg),
          backgroundColor: AppColors.black,
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  InputDecoration _inputDeco(String label, IconData icon, {Widget? suffix, String? hint}) {
    OutlineInputBorder border(Color c, [double w = 1]) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: c, width: w),
        );

    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon, color: AppColors.orange),
      suffixIcon: suffix,
      filled: true,
      fillColor: const Color(0xFFF6F8FA),
      enabledBorder: border(Colors.black12),
      focusedBorder: border(AppColors.orange, 2),
      errorBorder: border(Colors.redAccent),
      focusedErrorBorder: border(Colors.redAccent, 2),
    );
  }

  // File Picker Simulator Helper
  Future<void> _simulateFileUpload(
    String documentName,
    Function(String fileName) onUploaded,
  ) async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.cloud_upload_rounded, color: AppColors.orange, size: 28),
                const SizedBox(width: 12),
                Text(
                  'Upload $documentName',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: AppColors.black,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Select document file format (PDF, JPG, PNG under 10MB)',
              style: TextStyle(color: Colors.black54, fontSize: 13),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.camera_alt_rounded, color: AppColors.orange),
              title: const Text('Take Photo / Scan Document', style: TextStyle(fontWeight: FontWeight.w700)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              tileColor: const Color(0xFFF6F8FA),
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
              title: const Text('Choose from Gallery / Files', style: TextStyle(fontWeight: FontWeight.w700)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              tileColor: const Color(0xFFF6F8FA),
              onTap: () {
                Navigator.pop(ctx);
                final file = '${documentName.toLowerCase().replaceAll(' ', '_')}_doc.pdf';
                onUploaded(file);
                _toast('$documentName uploaded successfully!');
              },
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  // Live Selfie Camera Simulator
  void _startLiveSelfieCheck() {
    setState(() => _isSimulatingSelfie = true);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          return AlertDialog(
            backgroundColor: AppColors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
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
                        color: AppColors.orange,
                        strokeWidth: 3,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 16),
                      SizedBox(width: 6),
                      Text(
                        'Face & Liveness Detected',
                        style: TextStyle(
                          color: Color(0xFF10B981),
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
                  setState(() {
                    _hasTakenLiveSelfie = true;
                    _isSimulatingSelfie = false;
                  });
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

    // Show Success Modal
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color(0xFFE8F5E9),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.task_alt_rounded,
                color: Color(0xFF2E7D32),
                size: 54,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Application Submitted!',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: AppColors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Thank you, ${_legalNameController.text.trim().isEmpty ? "Courier" : _legalNameController.text.trim()}.\nYour documents have been queued for verification.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.black87, fontSize: 13, height: 1.4),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF6F8FA),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.black12),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.confirmation_number_rounded, color: AppColors.orange, size: 18),
                  SizedBox(width: 8),
                  Text(
                    'Ref No: SKR-DRIVER-9831',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: AppColors.black,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.black,
                foregroundColor: AppColors.yellow,
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
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.black),
        ),
        const SizedBox(height: 4),
        const Text(
          'Enter your official name exactly as shown on government IDs.',
          style: TextStyle(color: Colors.black54, fontSize: 13),
        ),
        const SizedBox(height: 18),
        TextFormField(
          controller: _legalNameController,
          textCapitalization: TextCapitalization.words,
          decoration: _inputDeco(
            'Full Legal Name (Must match ID)',
            Icons.person_rounded,
            hint: 'e.g. Chukwuma Emmanuel Adebayo',
          ),
          validator: (v) => (v == null || v.trim().length < 3) ? 'Enter your full legal name' : null,
        ),
        const SizedBox(height: 14),
        TextFormField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: _inputDeco('Email Address', Icons.email_rounded),
          validator: (v) => RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v?.trim() ?? '')
              ? null
              : 'Enter a valid email address',
        ),
        const SizedBox(height: 14),
        TextFormField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9+\s]'))],
          decoration: _inputDeco('Phone Number', Icons.phone_rounded, hint: '+234 801 234 5678'),
          validator: (v) => (v ?? '').replaceAll(RegExp(r'\D'), '').length < 8
              ? 'Enter valid phone number'
              : null,
        ),
        const SizedBox(height: 14),
        TextFormField(
          controller: _passwordController,
          obscureText: _hidePass,
          decoration: _inputDeco(
            'Create Password',
            Icons.lock_rounded,
            suffix: IconButton(
              icon: Icon(
                _hidePass ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                color: Colors.black45,
              ),
              onPressed: () => setState(() => _hidePass = !_hidePass),
            ),
          ),
          validator: (v) => (v == null || v.length < 6) ? 'Password must be at least 6 characters' : null,
        ),
        const SizedBox(height: 14),
        TextFormField(
          controller: _confirmPasswordController,
          obscureText: _hidePass,
          decoration: _inputDeco('Confirm Password', Icons.lock_outline_rounded),
          validator: (v) => v != _passwordController.text ? 'Passwords do not match' : null,
        ),
      ],
    );
  }

  Widget _buildStep2Address() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Step 2: Home Address & Proof of Residence',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.black),
        ),
        const SizedBox(height: 4),
        const Text(
          'Provide your residential address and upload proof (utility bill or bank statement within 3–6 months).',
          style: TextStyle(color: Colors.black54, fontSize: 13),
        ),
        const SizedBox(height: 18),
        TextFormField(
          controller: _homeAddressController,
          textCapitalization: TextCapitalization.words,
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
                decoration: _inputDeco('City', Icons.location_city_rounded),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'City required' : null,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: _stateController,
                textCapitalization: TextCapitalization.words,
                decoration: _inputDeco('State', Icons.map_rounded),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'State required' : null,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        const Text(
          'Proof of Residence Document',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AppColors.black),
        ),
        const SizedBox(height: 4),
        const Text(
          'Utility bill (Electricity, Water) or official Bank Statement (Issued within last 3-6 months).',
          style: TextStyle(color: Colors.black54, fontSize: 12),
        ),
        const SizedBox(height: 10),
        _DocumentUploadTile(
          title: 'Upload Utility Bill / Bank Statement',
          subtitle: _hasUploadedProofOfResidence
              ? 'Uploaded: ${_proofOfResidenceFileName ?? "proof_of_address.pdf"}'
              : 'Required (PDF, JPG or PNG)',
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
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.black),
        ),
        const SizedBox(height: 4),
        const Text(
          'Verify your government photo ID and perform a quick biometric liveness check.',
          style: TextStyle(color: Colors.black54, fontSize: 13),
        ),
        const SizedBox(height: 18),
        DropdownButtonFormField<String>(
          value: _govIdType,
          decoration: _inputDeco('Government ID Type', Icons.badge_rounded),
          borderRadius: BorderRadius.circular(16),
          items: const [
            DropdownMenuItem(value: 'National ID (NIN)', child: Text('National ID / NIN Slip')),
            DropdownMenuItem(value: 'International Passport', child: Text('International Passport')),
            DropdownMenuItem(value: 'Voter Card', child: Text('Voter’s Identification Card')),
          ],
          onChanged: (val) {
            if (val != null) setState(() => _govIdType = val);
          },
        ),
        const SizedBox(height: 14),
        _DocumentUploadTile(
          title: 'Upload $_govIdType (Front & Back)',
          subtitle: _hasUploadedGovId
              ? 'Uploaded: ${_govIdFileName ?? "gov_id_photo.jpg"}'
              : 'Clear photo of official ID document',
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
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AppColors.black),
        ),
        const SizedBox(height: 4),
        const Text(
          'Take a real-time live selfie to confirm your identity against your uploaded ID photo.',
          style: TextStyle(color: Colors.black54, fontSize: 12),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _hasTakenLiveSelfie ? const Color(0xFFE8F5E9) : const Color(0xFFFFF7EB),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _hasTakenLiveSelfie ? const Color(0xFF2E7D32) : AppColors.orange,
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: _hasTakenLiveSelfie ? const Color(0xFF2E7D32) : AppColors.orange,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _hasTakenLiveSelfie ? Icons.check_rounded : Icons.camera_front_rounded,
                  color: Colors.white,
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
                        color: _hasTakenLiveSelfie ? const Color(0xFF2E7D32) : AppColors.black,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _hasTakenLiveSelfie
                          ? 'Biometric liveness check passed successfully.'
                          : 'Tap to open camera and scan your face.',
                      style: const TextStyle(fontSize: 12, color: Colors.black87),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _hasTakenLiveSelfie ? AppColors.black : AppColors.orange,
                  foregroundColor: Colors.white,
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
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.black),
        ),
        const SizedBox(height: 4),
        const Text(
          'Enter vehicle plate number, photos, inspection certificate and driver license.',
          style: TextStyle(color: Colors.black54, fontSize: 13),
        ),
        const SizedBox(height: 18),
        DropdownButtonFormField<String>(
          value: _vehicleType,
          decoration: _inputDeco('Vehicle Category', Icons.two_wheeler_rounded),
          borderRadius: BorderRadius.circular(16),
          items: const [
            DropdownMenuItem(value: 'Motorcycle / Bike', child: Text('Motorcycle / Courier Bike')),
            DropdownMenuItem(value: 'Car / Sedan', child: Text('Car / Sedan / Hatchback')),
            DropdownMenuItem(value: 'Cargo Van', child: Text('Delivery / Cargo Van')),
            DropdownMenuItem(value: 'Pickup / Truck', child: Text('Pickup Truck / Heavy Duty')),
            DropdownMenuItem(value: 'Bicycle', child: Text('Bicycle / E-Bike')),
          ],
          onChanged: (val) {
            if (val != null) setState(() => _vehicleType = val);
          },
        ),
        const SizedBox(height: 14),
        TextFormField(
          controller: _licensePlateController,
          textCapitalization: TextCapitalization.characters,
          decoration: _inputDeco('License Plate Number', Icons.subtitles_rounded, hint: 'e.g. LAG-492-IKJ'),
          validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter license plate number' : null,
        ),
        const SizedBox(height: 14),
        TextFormField(
          controller: _vehicleMakeModelController,
          textCapitalization: TextCapitalization.words,
          decoration: _inputDeco('Vehicle Make & Model', Icons.directions_car_rounded, hint: 'e.g. Honda Ace 125 (2022)'),
          validator: (v) => (v == null || v.trim().isEmpty) ? 'Vehicle make and model required' : null,
        ),
        const SizedBox(height: 16),
        _DocumentUploadTile(
          title: 'Clear Vehicle Photos (Front, Side, Plate)',
          subtitle: _hasUploadedVehiclePhotos
              ? 'Uploaded: ${_vehiclePhotoFileName ?? "vehicle_photos.jpg"}'
              : 'Clear photos of vehicle showing plate number',
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
          subtitle: _hasUploadedVehicleInspection
              ? 'Uploaded: ${_vehicleInspectionFileName ?? "roadworthiness_cert.pdf"}'
              : 'Valid Roadworthiness / Inspection Certificate',
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
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AppColors.black),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _driverLicenseNumController,
                textCapitalization: TextCapitalization.characters,
                decoration: _inputDeco('Driver License No.', Icons.drive_eta_rounded),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'License number required' : null,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: _licenseExpiryController,
                keyboardType: TextInputType.datetime,
                decoration: _inputDeco('Expiry Date', Icons.calendar_month_rounded, hint: 'MM/YY'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Expiry date required' : null,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _DocumentUploadTile(
          title: 'Upload Driver’s License Document',
          subtitle: _hasUploadedDriverLicense
              ? 'Uploaded: ${_driverLicenseFileName ?? "drivers_license.jpg"}'
              : 'Photo of official driver’s license card',
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
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.black),
        ),
        const SizedBox(height: 4),
        const Text(
          'Upload police clearance certificate and submit reliable guarantor/next of kin details.',
          style: TextStyle(color: Colors.black54, fontSize: 13),
        ),
        const SizedBox(height: 18),
        _DocumentUploadTile(
          title: 'Police Clearance Certificate',
          subtitle: _hasUploadedPoliceClearance
              ? 'Uploaded: ${_policeClearanceFileName ?? "police_clearance.pdf"}'
              : 'Official police character certificate or background check',
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
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: AppColors.black),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _guarantorNameController,
          textCapitalization: TextCapitalization.words,
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
                decoration: _inputDeco('Relationship', Icons.people_outline_rounded, hint: 'Parent/Spouse/Relative'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Relationship required' : null,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: _guarantorPhoneController,
                keyboardType: TextInputType.phone,
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
          decoration: _inputDeco('Guarantor Email Address (Optional)', Icons.alternate_email_rounded),
        ),
        const SizedBox(height: 14),
        TextFormField(
          controller: _guarantorAddressController,
          textCapitalization: TextCapitalization.words,
          decoration: _inputDeco('Guarantor Residential / Office Address', Icons.pin_drop_rounded),
          validator: (v) => (v == null || v.trim().isEmpty) ? 'Guarantor address required' : null,
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Checkbox(
              value: _acceptedTerms,
              activeColor: AppColors.orange,
              onChanged: (val) => setState(() => _acceptedTerms = val ?? false),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _acceptedTerms = !_acceptedTerms),
                child: const Text(
                  'I certify that all documents and guarantor details provided are authentic and agree to Sekure Courier Driver Terms.',
                  style: TextStyle(fontSize: 12, color: Colors.black87, height: 1.3),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSignUpOnboardingStepper() {
    final steps = [
      'Account',
      'Address',
      'Identity',
      'Vehicle',
      'Guarantor',
    ];

    return Column(
      children: [
        // Stepper Header
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
                          width: 32,
                          height: 32,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isCurrent
                                ? AppColors.orange
                                : active
                                    ? AppColors.black
                                    : Colors.black12,
                          ),
                          child: Text(
                            '${index + 1}',
                            style: TextStyle(
                              color: (isCurrent || active) ? Colors.white : Colors.black54,
                              fontWeight: FontWeight.w900,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          steps[index],
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: isCurrent ? FontWeight.w900 : FontWeight.w600,
                            color: isCurrent ? AppColors.orange : Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (index < steps.length - 1)
                    Container(
                      width: 12,
                      height: 2,
                      color: index < _currentStep ? AppColors.black : Colors.black12,
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

        // Navigation Buttons
        Row(
          children: [
            if (_currentStep > 0) ...[
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 52),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    side: const BorderSide(color: AppColors.black, width: 1.5),
                  ),
                  onPressed: () => setState(() => _currentStep--),
                  child: const Text(
                    'BACK',
                    style: TextStyle(color: AppColors.black, fontWeight: FontWeight.w800),
                  ),
                ),
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              flex: 2,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.black,
                  foregroundColor: AppColors.yellow,
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
                child: _loading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          color: AppColors.yellow,
                        ),
                      )
                    : Text(
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Courier Driver Sign In',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.black),
          ),
          const SizedBox(height: 4),
          const Text(
            'Enter your registered driver phone or email to access your console.',
            style: TextStyle(color: Colors.black54, fontSize: 13),
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _loginEmailPhone,
            decoration: _inputDeco('Driver Email or Phone', Icons.account_circle_rounded),
            validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter driver email or phone' : null,
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _loginPassword,
            obscureText: _hidePass,
            decoration: _inputDeco(
              'Password',
              Icons.lock_rounded,
              suffix: IconButton(
                icon: Icon(_hidePass ? Icons.visibility_off_rounded : Icons.visibility_rounded, color: Colors.black45),
                onPressed: () => setState(() => _hidePass = !_hidePass),
              ),
            ),
            validator: (v) => (v == null || v.length < 6) ? 'Password required' : null,
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => _toast('Password reset link sent to your registered contact.'),
              child: const Text('Forgot password?', style: TextStyle(color: AppColors.orange, fontWeight: FontWeight.w700)),
            ),
          ),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: _loading ? null : _submitLogin,
            child: Container(
              height: 54,
              width: double.infinity,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                gradient: AppColors.brandGradient,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.orange.withValues(alpha: .4),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: _loading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 3, color: AppColors.black),
                    )
                  : const Text(
                      'DRIVER SIGN IN',
                      style: TextStyle(color: AppColors.black, fontWeight: FontWeight.w900, letterSpacing: 1.5),
                    ),
            ),
          ),
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
                fontWeight: FontWeight.w800,
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
      child: Row(children: [tab('Driver Registration', false), tab('Driver Sign In', true)]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lemon,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Deliver With Us',
          style: TextStyle(color: AppColors.black, fontWeight: FontWeight.w900),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.orange.withValues(alpha: 0.2),
                      blurRadius: 30,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _toggleTab(),
                    const SizedBox(height: 20),
                    _isLogin ? _buildLoginView() : _buildSignUpOnboardingStepper(),
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
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isUploaded ? const Color(0xFFF0FDF4) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isUploaded ? const Color(0xFF10B981) : Colors.black12,
          width: isUploaded ? 1.5 : 1,
        ),
      ),
      child: ListTile(
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isUploaded
                ? const Color(0xFF10B981).withValues(alpha: 0.15)
                : AppColors.orange.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(
            isUploaded ? Icons.check_circle_rounded : icon,
            color: isUploaded ? const Color(0xFF10B981) : AppColors.orange,
            size: 22,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 13.5,
            color: AppColors.black,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 12,
            color: isUploaded ? const Color(0xFF15803D) : Colors.black54,
            fontWeight: isUploaded ? FontWeight.w700 : FontWeight.normal,
          ),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: isUploaded ? const Color(0xFF10B981) : AppColors.black,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            isUploaded ? 'UPLOADED' : 'UPLOAD',
            style: TextStyle(
              color: isUploaded ? Colors.white : AppColors.yellow,
              fontSize: 11,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ),
    );
  }
}
