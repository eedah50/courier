import 'package:flutter/material.dart';
import 'role_selection_screen.dart';
import 'theme.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _selectedNavIndex = 0;
  bool _isSurgeActive = false;
  final double _surgeMultiplier = 1.2;

  // Sample Live Orders Data
  final List<Map<String, dynamic>> _orders = [
    {
      'id': 'SKR-8842',
      'customer': 'Amara Okafor',
      'customerPhone': '+234 802 111 2233',
      'courier': 'Chukwuma Adebayo',
      'courierPhone': '+234 803 444 5566',
      'pickup': '12 Ikeja City Mall, Lagos',
      'dropoff': '45 Victoria Island, Lagos',
      'amount': '₦4,500',
      'commission': '₦900',
      'package': 'Electronics Box (2.5 kg)',
      'status': 'In Transit',
      'eta': '14 mins',
    },
    {
      'id': 'SKR-8845',
      'customer': 'David Mensah',
      'customerPhone': '+234 805 777 8899',
      'courier': 'Sani Ibrahim',
      'courierPhone': '+234 809 222 3344',
      'pickup': '8 Allen Avenue, Ikeja',
      'dropoff': '18 Maryland Estate, Lagos',
      'amount': '₦2,800',
      'commission': '₦560',
      'package': 'Legal Documents (0.4 kg)',
      'status': 'Delivered',
      'eta': 'Completed',
    },
    {
      'id': 'SKR-8849',
      'customer': 'Sade Williams',
      'customerPhone': '+234 812 333 4455',
      'courier': 'Unassigned',
      'courierPhone': 'N/A',
      'pickup': 'Lekki Phase 1, Gate 2',
      'dropoff': 'Chevron Drive, Lekki',
      'amount': '₦5,200',
      'commission': '₦1,040',
      'package': 'Gift Hamper (4.1 kg)',
      'status': 'Pending Assignment',
      'eta': 'Searching Driver',
    },
    {
      'id': 'SKR-8851',
      'customer': 'Emeka Nnamdi',
      'customerPhone': '+234 816 999 0011',
      'courier': 'Tunde Bakare',
      'courierPhone': '+234 807 555 6677',
      'pickup': 'Surulere Stadium, Lagos',
      'dropoff': 'Yaba Tech, Yaba',
      'amount': '₦3,100',
      'commission': '₦620',
      'package': 'Fashion Apparel Box',
      'status': 'Processing',
      'eta': '22 mins',
    },
  ];

  // Sample Pending Courier Verifications Queue
  final List<Map<String, dynamic>> _pendingCouriers = [
    {
      'id': 'CR-1042',
      'name': 'Kofi Mensah Annan',
      'email': 'kofi.m@sekure.com',
      'phone': '+234 801 987 6543',
      'submittedAt': '10 mins ago',
      'vehicle': 'Motorcycle (Honda Ace 125)',
      'plate': 'LAG-882-IKJ',
      'address': '22 Allen Avenue, Ikeja, Lagos',
      'govIdType': 'National ID (NIN)',
      'govIdStatus': 'Verified',
      'livenessScore': '99.4% Match',
      'proofAddress': 'Electricity_Bill_Sept2026.pdf',
      'vehiclePhoto': 'Honda_Ace_Front_Plate.jpg',
      'inspectionCert': 'Roadworthiness_2026.pdf',
      'driverLicense': 'DL_LA_883921.jpg',
      'policeClearance': 'Police_Character_Cert.pdf',
      'guarantorName': 'Chief Olabisi Annan',
      'guarantorRel': 'Father / Business Owner',
      'guarantorPhone': '+234 803 111 9900',
      'guarantorAddress': '45 Toyin Street, Ikeja, Lagos',
      'status': 'Pending Verification',
    },
    {
      'id': 'CR-1045',
      'name': 'Blessing Okon',
      'email': 'blessing.okon@gmail.com',
      'phone': '+234 808 321 4567',
      'submittedAt': '1 hour ago',
      'vehicle': 'Cargo Van (Toyota HiAce)',
      'plate': 'ABJ-491-GWD',
      'address': '14 Wuse Zone 4, Abuja',
      'govIdType': 'International Passport',
      'govIdStatus': 'Verified',
      'livenessScore': '98.8% Match',
      'proofAddress': 'Access_Bank_Statement.pdf',
      'vehiclePhoto': 'HiAce_Van_Photos.jpg',
      'inspectionCert': 'Abuja_VIO_Inspection.pdf',
      'driverLicense': 'DL_FC_990123.jpg',
      'policeClearance': 'Police_HQ_Clearance.pdf',
      'guarantorName': 'Pastor Peter Okon',
      'guarantorRel': 'Brother / Clergy',
      'guarantorPhone': '+234 802 888 7766',
      'guarantorAddress': '12 Garki Road, Abuja',
      'status': 'Pending Verification',
    },
  ];

  // Sample Registered Fleet
  final List<Map<String, dynamic>> _fleet = [
    {
      'name': 'Chukwuma Adebayo',
      'phone': '+234 803 444 5566',
      'vehicle': 'Honda Ace 125 • LA-492-IKJ',
      'rating': '4.9 ★',
      'trips': '142',
      'earnings': '₦185,400',
      'status': 'Online (In Trip)',
      'isBlocked': false,
    },
    {
      'name': 'Sani Ibrahim',
      'phone': '+234 809 222 3344',
      'vehicle': 'TVS Neo 110 • KAN-201-TR',
      'rating': '4.8 ★',
      'trips': '98',
      'earnings': '₦124,100',
      'status': 'Online (Available)',
      'isBlocked': false,
    },
    {
      'name': 'Tunde Bakare',
      'phone': '+234 807 555 6677',
      'vehicle': 'Suzuki Super Carry • LA-901-YY',
      'rating': '4.7 ★',
      'trips': '210',
      'earnings': '₦310,000',
      'status': 'Offline',
      'isBlocked': false,
    },
  ];

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

  // Document Inspector Modal for Owner Review
  void _openDocumentInspector(Map<String, dynamic> applicant) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(
                color: AppColors.orange,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.assignment_ind_rounded, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    applicant['name'],
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.black),
                  ),
                  Text(
                    'Application Ref: ${applicant['id']} • ${applicant['submittedAt']}',
                    style: const TextStyle(fontSize: 11, color: Colors.black54),
                  ),
                ],
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: 580,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _inspectorSectionTitle('1. PERSONAL & CONTACT DETAILS'),
                _inspectorField('Full Legal Name', applicant['name']),
                _inspectorField('Phone Number', applicant['phone']),
                _inspectorField('Email Address', applicant['email']),
                _inspectorField('Residential Address', applicant['address']),

                const SizedBox(height: 16),
                _inspectorSectionTitle('2. IDENTITY & LIVE SELFIE CHECK'),
                _inspectorField('Government ID Type', applicant['govIdType']),
                _inspectorField('ID Document Status', applicant['govIdStatus'], isSuccess: true),
                _inspectorField('Biometric Liveness Match Score', applicant['livenessScore'], isSuccess: true),

                const SizedBox(height: 16),
                _inspectorSectionTitle('3. RESIDENCE & CLEARANCE DOCUMENTS'),
                _inspectorFileTile('Proof of Address (Utility Bill)', applicant['proofAddress']),
                _inspectorFileTile('Police Clearance Certificate', applicant['policeClearance']),

                const SizedBox(height: 16),
                _inspectorSectionTitle('4. VEHICLE & DRIVER CREDENTIALS'),
                _inspectorField('Vehicle Type', applicant['vehicle']),
                _inspectorField('License Plate Number', applicant['plate']),
                _inspectorFileTile('Vehicle Inspection Certificate', applicant['inspectionCert']),
                _inspectorFileTile('Clear Vehicle Photos', applicant['vehiclePhoto']),
                _inspectorFileTile('Driver’s License Document', applicant['driverLicense']),

                const SizedBox(height: 16),
                _inspectorSectionTitle('5. GUARANTOR / NEXT OF KIN VERIFICATION'),
                _inspectorField('Guarantor Full Name', applicant['guarantorName']),
                _inspectorField('Relationship', applicant['guarantorRel']),
                _inspectorField('Guarantor Phone', applicant['guarantorPhone']),
                _inspectorField('Guarantor Address', applicant['guarantorAddress']),
              ],
            ),
          ),
        ),
        actions: [
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: const BorderSide(color: Colors.red, width: 1.5),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            onPressed: () {
              setState(() {
                applicant['status'] = 'Rejected';
                _pendingCouriers.remove(applicant);
              });
              Navigator.pop(ctx);
              _toast('Application ${applicant['id']} rejected.');
            },
            icon: const Icon(Icons.cancel_rounded, size: 18),
            label: const Text('REJECT', style: TextStyle(fontWeight: FontWeight.w900)),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            onPressed: () {
              setState(() {
                applicant['status'] = 'Approved';
                _pendingCouriers.remove(applicant);
                _fleet.add({
                  'name': applicant['name'],
                  'phone': applicant['phone'],
                  'vehicle': '${applicant['vehicle']} • ${applicant['plate']}',
                  'rating': '5.0 ★',
                  'trips': '0',
                  'earnings': '₦0',
                  'status': 'Online (Available)',
                  'isBlocked': false,
                });
              });
              Navigator.pop(ctx);
              _toast('★ Courier ${applicant['name']} APPROVED and activated!');
            },
            icon: const Icon(Icons.check_circle_rounded, size: 18),
            label: const Text('APPROVE & ACTIVATE COURIER', style: TextStyle(fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );
  }

  // View Order Details Modal
  void _openOrderInspector(Map<String, dynamic> order) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            const Icon(Icons.local_shipping_rounded, color: AppColors.orange, size: 28),
            const SizedBox(width: 12),
            Text('Order Control #${order['id']}', style: const TextStyle(fontWeight: FontWeight.w900)),
          ],
        ),
        content: SizedBox(
          width: 480,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _inspectorField('Customer Name', order['customer']),
              _inspectorField('Customer Contact', order['customerPhone']),
              _inspectorField('Assigned Driver', order['courier']),
              _inspectorField('Driver Contact', order['courierPhone']),
              _inspectorField('Pickup Location', order['pickup']),
              _inspectorField('Dropoff Destination', order['dropoff']),
              _inspectorField('Delivery Fee', order['amount']),
              _inspectorField('Platform Commission (20%)', order['commission'], isSuccess: true),
              _inspectorField('Status', order['status']),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('CLOSE', style: TextStyle(color: AppColors.black, fontWeight: FontWeight.w900)),
          ),
          if (order['courier'] == 'Unassigned')
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.black,
                foregroundColor: AppColors.yellow,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                setState(() {
                  order['courier'] = 'Chukwuma Adebayo';
                  order['courierPhone'] = '+234 803 444 5566';
                  order['status'] = 'In Transit';
                });
                Navigator.pop(ctx);
                _toast('Manually dispatched driver to order ${order['id']}');
              },
              child: const Text('DISPATCH NEAREST DRIVER', style: TextStyle(fontWeight: FontWeight.w900)),
            ),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // KPI Metric Header Grid
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 850;
              return Wrap(
                spacing: 20,
                runSpacing: 20,
                children: [
                  _AdminMetricCard(
                    title: "TOTAL ORDERS TODAY",
                    value: "1,420",
                    subtitle: "+18% vs yesterday",
                    icon: Icons.local_mall_rounded,
                    color: AppColors.orange,
                    width: isWide ? (constraints.maxWidth - 60) / 4 : (constraints.maxWidth - 20) / 2,
                  ),
                  _AdminMetricCard(
                    title: "NET COMMISSION (20%)",
                    value: "₦1,245,000",
                    subtitle: "Platform earnings today",
                    icon: Icons.account_balance_rounded,
                    color: const Color(0xFF10B981),
                    width: isWide ? (constraints.maxWidth - 60) / 4 : (constraints.maxWidth - 20) / 2,
                  ),
                  _AdminMetricCard(
                    title: "ACTIVE FLEET ONLINE",
                    value: "184 Riders",
                    subtitle: "142 currently in trip",
                    icon: Icons.two_wheeler_rounded,
                    color: AppColors.sky,
                    width: isWide ? (constraints.maxWidth - 60) / 4 : (constraints.maxWidth - 20) / 2,
                  ),
                  _AdminMetricCard(
                    title: "PENDING VERIFICATIONS",
                    value: "${_pendingCouriers.length} Applicants",
                    subtitle: "Awaiting owner review",
                    icon: Icons.assignment_turned_in_rounded,
                    color: AppColors.black,
                    width: isWide ? (constraints.maxWidth - 60) / 4 : (constraints.maxWidth - 20) / 2,
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 32),

          // Control Actions Banner
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.black, Color(0xFF1E1E2C)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: AppColors.black.withValues(alpha: 0.25),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.yellow.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.bolt_rounded, color: AppColors.yellow, size: 30),
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'PEAK SURGE PRICING ENGINE',
                        style: TextStyle(color: AppColors.yellow, fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1.2),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _isSurgeActive
                            ? 'Surge multiplier active (${_surgeMultiplier}x fare across high-demand zones).'
                            : 'Standard pricing active. Toggle surge during rain or traffic surges.',
                        style: const TextStyle(color: Colors.white, fontSize: 13.5, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
                Switch.adaptive(
                  value: _isSurgeActive,
                  activeThumbColor: AppColors.yellow,
                  activeTrackColor: AppColors.orange,
                  onChanged: (val) {
                    setState(() => _isSurgeActive = val);
                    _toast(val
                        ? 'Surge Pricing Enabled (${_surgeMultiplier}x fare active)'
                        : 'Surge Pricing Disabled (Standard fare restored)');
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Live Dispatch Map & Pending Approvals Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: Container(
                  height: 400,
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(26),
                    border: Border.all(color: Colors.black12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Real-Time Dispatch Map Control',
                            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: AppColors.black),
                          ),
                          Row(
                            children: [
                              Icon(Icons.circle, size: 10, color: Color(0xFF10B981)),
                              SizedBox(width: 6),
                              Text('184 Couriers Active', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E293B),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              CustomPaint(
                                size: Size.infinite,
                                painter: _MapSimulatorPainter(),
                              ),
                              Positioned(
                                top: 50,
                                left: 80,
                                child: _MapMarker(title: 'Rider #104 (In Trip)', color: AppColors.orange),
                              ),
                              Positioned(
                                top: 130,
                                right: 100,
                                child: _MapMarker(title: 'Rider #118 (Available)', color: const Color(0xFF10B981)),
                              ),
                              Positioned(
                                bottom: 70,
                                left: 160,
                                child: _MapMarker(title: 'Rider #092 (In Trip)', color: AppColors.sky),
                              ),
                              Positioned(
                                bottom: 24,
                                right: 24,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.redAccent.withValues(alpha: 0.95),
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 6)],
                                  ),
                                  child: const Text(
                                    '🔥 Surge Zone: Ikeja (1.4x)',
                                    style: TextStyle(color: Colors.white, fontSize: 11.5, fontWeight: FontWeight.w900),
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

              const SizedBox(width: 24),

              // Pending Approvals Quick Panel
              Expanded(
                flex: 2,
                child: Container(
                  height: 400,
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(26),
                    border: Border.all(color: Colors.black12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Pending Courier Approvals',
                            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: AppColors.black),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.orange.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${_pendingCouriers.length} Action Needed',
                              style: const TextStyle(color: AppColors.orange, fontSize: 11.5, fontWeight: FontWeight.w900),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: _pendingCouriers.isEmpty
                            ? const Center(
                                child: Text('All driver applications approved!'),
                              )
                            : ListView.separated(
                                itemCount: _pendingCouriers.length,
                                separatorBuilder: (_, __) => const SizedBox(height: 12),
                                itemBuilder: (ctx, idx) {
                                  final item = _pendingCouriers[idx];
                                  return Container(
                                    padding: const EdgeInsets.all(14),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF8FAFC),
                                      borderRadius: BorderRadius.circular(18),
                                      border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            color: AppColors.orange.withValues(alpha: 0.15),
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(Icons.badge_rounded, color: AppColors.orange, size: 22),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                item['name'],
                                                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: AppColors.black),
                                              ),
                                              Text(
                                                '${item['vehicle']} • ${item['govIdType']}',
                                                style: const TextStyle(fontSize: 11.5, color: Colors.black54),
                                              ),
                                            ],
                                          ),
                                        ),
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: AppColors.black,
                                            foregroundColor: AppColors.yellow,
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                          ),
                                          onPressed: () => _openDocumentInspector(item),
                                          child: const Text('REVIEW', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11.5)),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersTab() {
    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Live Order Management',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.black),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Monitor ongoing deliveries, dispatch drivers, and manage order lifecycles.',
                    style: TextStyle(color: Colors.black54, fontSize: 13),
                  ),
                ],
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.orange,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                ),
                onPressed: () => _toast('Exporting Order Logs (CSV/Excel)...'),
                icon: const Icon(Icons.download_rounded, size: 18),
                label: const Text('Export Order Logs', style: TextStyle(fontWeight: FontWeight.w900)),
              ),
            ],
          ),

          const SizedBox(height: 24),

          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.black12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                child: DataTable(
                  headingRowColor: WidgetStateProperty.all(const Color(0xFFF1F5F9)),
                  columns: const [
                    DataColumn(label: Text('ORDER ID', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12))),
                    DataColumn(label: Text('CUSTOMER', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12))),
                    DataColumn(label: Text('COURIER', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12))),
                    DataColumn(label: Text('PACKAGE', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12))),
                    DataColumn(label: Text('FEE', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12))),
                    DataColumn(label: Text('COMMISSION', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12))),
                    DataColumn(label: Text('STATUS', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12))),
                    DataColumn(label: Text('ACTION', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12))),
                  ],
                  rows: _orders.map((order) {
                    final isInTransit = order['status'] == 'In Transit';
                    final isDelivered = order['status'] == 'Delivered';

                    return DataRow(
                      cells: [
                        DataCell(
                          Text(order['id'], style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.black)),
                        ),
                        DataCell(Text(order['customer'], style: const TextStyle(fontWeight: FontWeight.w800))),
                        DataCell(Text(order['courier'], style: TextStyle(color: order['courier'] == 'Unassigned' ? Colors.redAccent : AppColors.black, fontWeight: FontWeight.w800))),
                        DataCell(Text(order['package'])),
                        DataCell(Text(order['amount'], style: const TextStyle(fontWeight: FontWeight.w900))),
                        DataCell(Text(order['commission'], style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF10B981)))),
                        DataCell(
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: isDelivered
                                  ? const Color(0xFFE8F5E9)
                                  : isInTransit
                                      ? AppColors.orange.withValues(alpha: 0.15)
                                      : const Color(0xFFFFF3E0),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              order['status'],
                              style: TextStyle(
                                color: isDelivered
                                    ? const Color(0xFF2E7D32)
                                    : isInTransit
                                        ? AppColors.orange
                                        : Colors.deepOrange,
                                fontWeight: FontWeight.w900,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ),
                        DataCell(
                          IconButton(
                            icon: const Icon(Icons.tune_rounded, color: AppColors.black),
                            onPressed: () => _openOrderInspector(order),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerificationsTab() {
    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Courier Document Verification Center',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.black),
          ),
          const SizedBox(height: 4),
          const Text(
            'Review uploaded Government IDs, Live Selfie, Proof of Residence, Driver Licenses, Inspection Certs & Guarantors.',
            style: TextStyle(color: Colors.black54, fontSize: 13),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: _pendingCouriers.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: const BoxDecoration(
                            color: Color(0xFFE8F5E9),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.verified_user_rounded, color: Color(0xFF2E7D32), size: 48),
                        ),
                        const SizedBox(height: 16),
                        const Text('No Pending Applications', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.black)),
                        const SizedBox(height: 4),
                        const Text('All courier driver verification queues are clear.', style: TextStyle(color: Colors.black54)),
                      ],
                    ),
                  )
                : ListView.separated(
                    itemCount: _pendingCouriers.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 16),
                    itemBuilder: (ctx, idx) {
                      final item = _pendingCouriers[idx];
                      return Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(color: Colors.black12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 14,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 52,
                                      height: 52,
                                      decoration: const BoxDecoration(
                                        color: AppColors.black,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Center(
                                        child: Text(
                                          item['name'][0],
                                          style: const TextStyle(color: AppColors.yellow, fontWeight: FontWeight.w900, fontSize: 22),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item['name'],
                                          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: AppColors.black),
                                        ),
                                        Text(
                                          'Submitted ${item['submittedAt']} • Ref: ${item['id']}',
                                          style: const TextStyle(fontSize: 12, color: Colors.black54),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.orange,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                                  ),
                                  onPressed: () => _openDocumentInspector(item),
                                  icon: const Icon(Icons.document_scanner_rounded, size: 18),
                                  label: const Text('INSPECT DOCUMENTS', style: TextStyle(fontWeight: FontWeight.w900)),
                                ),
                              ],
                            ),
                            const Divider(height: 28),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _CheckStatusBadge('Govt ID', item['govIdStatus']),
                                _CheckStatusBadge('Live Selfie', item['livenessScore']),
                                _CheckStatusBadge('Proof of Address', 'Uploaded'),
                                _CheckStatusBadge('Driver License', 'Uploaded'),
                                _CheckStatusBadge('Guarantor', 'Submitted'),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFleetTab() {
    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Active Courier Fleet Directory',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.black),
          ),
          const SizedBox(height: 4),
          const Text(
            'Manage registered couriers, view completion rates, ratings, and account status.',
            style: TextStyle(color: Colors.black54, fontSize: 13),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.black12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                child: DataTable(
                  headingRowColor: WidgetStateProperty.all(const Color(0xFFF1F5F9)),
                  columns: const [
                    DataColumn(label: Text('COURIER NAME', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12))),
                    DataColumn(label: Text('PHONE NUMBER', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12))),
                    DataColumn(label: Text('VEHICLE & PLATE', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12))),
                    DataColumn(label: Text('RATING', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12))),
                    DataColumn(label: Text('COMPLETED TRIPS', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12))),
                    DataColumn(label: Text('STATUS', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12))),
                    DataColumn(label: Text('ACTION', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12))),
                  ],
                  rows: _fleet.map((driver) {
                    final isOnline = driver['status'].toString().contains('Online');

                    return DataRow(
                      cells: [
                        DataCell(Text(driver['name'], style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.black))),
                        DataCell(Text(driver['phone'])),
                        DataCell(Text(driver['vehicle'])),
                        DataCell(Text(driver['rating'], style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.orange))),
                        DataCell(Text(driver['trips'], style: const TextStyle(fontWeight: FontWeight.w900))),
                        DataCell(
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: isOnline ? const Color(0xFFE8F5E9) : const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              driver['status'],
                              style: TextStyle(
                                color: isOnline ? const Color(0xFF2E7D32) : Colors.black54,
                                fontWeight: FontWeight.w900,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ),
                        DataCell(
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: driver['isBlocked'] == true ? const Color(0xFF10B981) : Colors.redAccent,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            ),
                            onPressed: () {
                              setState(() => driver['isBlocked'] = !(driver['isBlocked'] == true));
                              _toast(driver['isBlocked'] == true ? 'Driver account suspended' : 'Driver account unblocked');
                            },
                            child: Text(
                              driver['isBlocked'] == true ? 'UNBLOCK' : 'SUSPEND',
                              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11),
                            ),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Row(
        children: [
          // Admin Sidebar
          Container(
            width: 270,
            color: AppColors.black,
            child: Column(
              children: [
                const SizedBox(height: 28),
                // Logo Branding
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: AppColors.black,
                        shape: BoxShape.circle,
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          'images/logo1.png',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => const Icon(Icons.shield_rounded, color: AppColors.yellow, size: 24),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'SEKURE ADMIN',
                          style: TextStyle(color: AppColors.yellow, fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 1.5),
                        ),
                        Text('Control Tower Portal', style: TextStyle(color: Colors.white54, fontSize: 10)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                const Divider(color: Colors.white12),

                // Navigation Item List
                _SidebarNavTile(
                  title: 'Live Operations',
                  icon: Icons.dashboard_rounded,
                  selected: _selectedNavIndex == 0,
                  onTap: () => setState(() => _selectedNavIndex = 0),
                ),
                _SidebarNavTile(
                  title: 'Live Orders Stream',
                  icon: Icons.local_shipping_rounded,
                  selected: _selectedNavIndex == 1,
                  badge: '4 Active',
                  onTap: () => setState(() => _selectedNavIndex = 1),
                ),
                _SidebarNavTile(
                  title: 'Courier Verification',
                  icon: Icons.assignment_ind_rounded,
                  selected: _selectedNavIndex == 2,
                  badge: '${_pendingCouriers.length} Pending',
                  badgeColor: AppColors.orange,
                  onTap: () => setState(() => _selectedNavIndex = 2),
                ),
                _SidebarNavTile(
                  title: 'Fleet & Couriers',
                  icon: Icons.two_wheeler_rounded,
                  selected: _selectedNavIndex == 3,
                  onTap: () => setState(() => _selectedNavIndex = 3),
                ),

                const Spacer(),

                // System Status Indicator
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white10,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 20),
                      SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('System Operational', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w900)),
                          Text('WebSockets • FCM Live', style: TextStyle(color: Colors.white54, fontSize: 10)),
                        ],
                      ),
                    ],
                  ),
                ),

                // Exit / Return to App Role Chooser
                ListTile(
                  leading: const Icon(Icons.logout_rounded, color: Colors.white54),
                  title: const Text('Exit Admin Portal', style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w800)),
                  onTap: () {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const RoleSelectionScreen()),
                      (route) => false,
                    );
                  },
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),

          // Main Canvas View Area
          Expanded(
            child: Column(
              children: [
                // Top Admin Bar
                Container(
                  height: 68,
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border(bottom: BorderSide(color: Colors.black12)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.security_rounded, color: AppColors.orange, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            ['Live Operations Console', 'Live Orders Stream', 'Courier Document Verification', 'Active Courier Fleet Directory'][_selectedNavIndex],
                            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: AppColors.black),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.notifications_none_rounded, color: AppColors.black),
                            onPressed: () => _toast('No new admin system alerts'),
                          ),
                          const SizedBox(width: 12),
                          const CircleAvatar(
                            backgroundColor: AppColors.black,
                            radius: 16,
                            child: Icon(Icons.person, color: AppColors.yellow, size: 18),
                          ),
                          const SizedBox(width: 8),
                          const Text('Platform Owner', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: AppColors.black)),
                        ],
                      ),
                    ],
                  ),
                ),

                // Selected Tab Canvas Content
                Expanded(
                  child: IndexedStack(
                    index: _selectedNavIndex,
                    children: [
                      _buildOverviewTab(),
                      _buildOrdersTab(),
                      _buildVerificationsTab(),
                      _buildFleetTab(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminMetricCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;
  final double width;

  const _AdminMetricCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.black12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Colors.black54, letterSpacing: 0.8)),
              Icon(icon, color: color, size: 24),
            ],
          ),
          const SizedBox(height: 14),
          Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.black)),
          const SizedBox(height: 4),
          Text(subtitle, style: const TextStyle(fontSize: 11, color: Colors.black54, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _SidebarNavTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool selected;
  final String? badge;
  final Color? badgeColor;
  final VoidCallback onTap;

  const _SidebarNavTile({
    required this.title,
    required this.icon,
    required this.selected,
    required this.onTap,
    this.badge,
    this.badgeColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: selected ? AppColors.orange : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        leading: Icon(icon, color: selected ? AppColors.black : Colors.white70, size: 22),
        title: Text(
          title,
          style: TextStyle(
            color: selected ? AppColors.black : Colors.white,
            fontWeight: selected ? FontWeight.w900 : FontWeight.w700,
            fontSize: 13.5,
          ),
        ),
        trailing: badge != null
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: badgeColor ?? (selected ? AppColors.black : Colors.white24),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  badge!,
                  style: TextStyle(
                    color: selected ? AppColors.yellow : Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              )
            : null,
      ),
    );
  }
}

class _CheckStatusBadge extends StatelessWidget {
  final String label;
  final String status;

  const _CheckStatusBadge(this.label, this.status);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.black54, fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: const Color(0xFFE8F5E9),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            status,
            style: const TextStyle(color: Color(0xFF2E7D32), fontWeight: FontWeight.w900, fontSize: 11),
          ),
        ),
      ],
    );
  }
}

Widget _inspectorSectionTitle(String text) => Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: AppColors.orange, letterSpacing: 0.8),
      ),
    );

Widget _inspectorField(String label, String value, {bool isSuccess = false}) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.black54, fontWeight: FontWeight.w700)),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              color: isSuccess ? const Color(0xFF10B981) : AppColors.black,
            ),
          ),
        ],
      ),
    );

Widget _inspectorFileTile(String title, String filename) => Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.black12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.insert_drive_file_rounded, color: AppColors.orange, size: 18),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: AppColors.black)),
                  Text(filename, style: const TextStyle(fontSize: 10, color: Colors.black54)),
                ],
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: AppColors.black, borderRadius: BorderRadius.circular(6)),
            child: const Text('VIEW DOC', style: TextStyle(color: AppColors.yellow, fontSize: 10, fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );

class _MapMarker extends StatelessWidget {
  final String title;
  final Color color;

  const _MapMarker({required this.title, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8),
            boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
          ),
          child: Text(
            title,
            style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900),
          ),
        ),
        Icon(Icons.location_on_rounded, color: color, size: 24),
      ],
    );
  }
}

class _MapSimulatorPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white10
      ..strokeWidth = 1.5;

    // Draw grid map roads
    for (double x = 0; x < size.width; x += 60) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += 60) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_MapSimulatorPainter oldDelegate) => false;
}
