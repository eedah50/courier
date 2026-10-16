# Sekure Courier — Comprehensive System Documentation
**A Bolt Delivery, Couriers & Merchants Ecosystem Clone**

---

## 1. Executive Summary & Architecture

**Sekure Courier** is a fully-featured, multi-sided delivery and logistics platform connecting **Customers / Users**, **Courier / Delivery Drivers**, and **Platform Owners / Admins**. 

The application is built with a dual architecture:
1. **Cross-Platform Mobile & Web Client (Flutter)**: Supports Android, iOS, and Web. Handles Customer Dashboards, Multi-Step Courier Onboarding & Verification, Driver Consoles, Health & Fitness Tracking, Sekure AI Copilot, Event Reminders, and a built-in Flutter Admin Control Tower.
2. **Full-Stack Web Backend & Admin Control Center (Next.js App Router)**: Located in `nextjs-backend/`, providing REST API endpoints, real-time order dispatching, and a vibrant, colorful Executive Admin Web Dashboard.

---

## 2. Complete User Journey & App Flow

```
                                [ Splash Screen ]
                                        │
                                        ▼
                             [ Role Selection Screen ]
                                        │
        ┌───────────────────────────────┼───────────────────────────────┐
        ▼                               ▼                               ▼
[ Order a Delivery ]          [ Deliver With Us ]             [ Admin Control Tower ]
(Customer / User Flow)        (Courier Onboarding Flow)       (Platform Owner Portal)
        │                               │                               │
        ▼                               ▼                               ▼
  • Auth Screen                 • 5-Step Verification           • Live Metrics Bento Grid
  • Customer Dashboard            (ID, Selfie, Address,         • Live Fleet GPS & Surge Radar
  • Waybill & Tracking            Vehicle, Guarantor)           • Driver Verification Queue
  • Wallet & Top-up             • Courier Console & Wallet      • Live Orders Stream
  • Health & Eco Tracking       • Health & Safety Management
  • Sekure AI Copilot           • Sekure AI Copilot
  • Event Reminders             • Event Reminders
```

---

## 3. Detailed Feature Specifications

### A. Customer / User Interface (`lib/dashboard_screen.dart`)
- **Dashboard & Waybill Overview**: Real-time stats on total shipments, in-transit parcels, and delivered packages.
- **Wallet & Funding**: Digital wallet balance with instant "Add Money" modal supporting debit cards.
- **Health & Eco-Impact**: Tracks pickup walking steps (e.g. `3,420 steps`), active calorie burn, and carbon footprint reduction (`4.2 kg CO₂ saved`).
- **Sekure AI Copilot**: Conversational AI assistant for instant tracking, pricing quotes, and logistics advice.
- **Event & Delivery Reminders**: Schedule automated reminders for time-sensitive waybills, birthday gift deliveries, and merchant restocks.

### B. Courier / Driver Interface (`lib/courier_dashboard_screen.dart` & `lib/courier_auth_screen.dart`)
- **5-Step Onboarding & Verification**:
  1. *Full Legal Name & Account Info* (Matches official identification).
  2. *Home Address & Proof of Residence* (Utility bill or bank statement within 3-6 months).
  3. *Government ID & Live Selfie* (NIN/Passport upload + real-time liveness biometric scan).
  4. *Vehicle & Driver's License* (Vehicle category, plate number, photos, inspection certificate, and driver license).
  5. *Police Clearance & Guarantor* (Character check certificate + Next of Kin/Guarantor details).
- **Courier Console (Lemon Yellow Footer)**:
  - **Deliveries Tab**: Online/Offline toggle radar and available express delivery requests.
  - **Wallet Tab**: Driver earnings ledger, pending payout, and instant bank cashout.
  - **Health & Safety Tab**: Shift fatigue timer, 15-minute rest break toggle, step/calorie tracker, hydration logger (`+250ml`), and heavy lifting posture ergonomics.
  - **Profile Tab**: Vehicle info, payout settings, support, and admin portal shortcut.

### C. Platform Owner Admin Control Center (`lib/admin_dashboard_screen.dart` & `nextjs-backend/app/admin/page.jsx`)
- **Live Operations Dashboard**: KPI Bento grid tracking orders, net commission revenue (20%), active online fleet, and pending verifications.
- **Peak Surge Pricing Engine**: Real-time surge multiplier toggle (e.g., `1.2x` - `1.5x`).
- **Real-Time Fleet Radar**: Map simulator showing active riders and surge zones.
- **Document Verification Inspector**: Review and **APPROVE** or **REJECT** pending driver applications with detailed data inspection.

---

## 4. Backend & API Reference (`nextjs-backend/`)

Built with Next.js App Router API routes:
- `POST /api/auth/login`: Authenticates customers and couriers.
- `POST /api/auth/register-courier`: Submits courier verification documents.
- `GET /api/orders` & `POST /api/orders`: Retrieves and creates waybills.
- `GET /api/admin/metrics`: Fetches platform KPIs and pending driver verification queues.
- `POST /api/admin/verify-courier`: Approves or rejects courier verification applications.

---

## 5. How to Run & Build

### Running the Flutter App (Mobile / Web / Desktop)
1. Ensure Flutter SDK is installed.
2. Run the app on your connected device or emulator:
   ```bash
   flutter run
   ```
3. To open the **Admin Dashboard**, log into either the Customer or Courier dashboard, go to your **Account / Profile Tab**, and tap **"Platform Owner Control Tower"**.

### Running the Next.js Backend & Admin Web Portal
1. Navigate to the backend directory:
   ```bash
   cd nextjs-backend
   ```
2. Install dependencies:
   ```bash
   npm install
   ```
3. Start the development server:
   ```bash
   npm run dev
   ```
4. Open your browser:
   - **Admin Control Center**: `http://localhost:3000/admin`
   - **API Metrics**: `http://localhost:3000/api/admin/metrics`
