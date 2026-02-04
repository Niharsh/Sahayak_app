# Sahayak App (Phase 1)

This workspace contains two folders:
- `backend` (Node.js + Express + MongoDB) — implements authentication and RBAC.
- `flutter_app` (Flutter) — implements login/register screens, secure token storage, and role-based routing.

Quick start:

1. Backend
   - Copy `backend/.env.example` to `backend/.env` and set `MONGODB_URI` (Atlas or local) and `JWT_SECRET`.
   - cd backend && npm install
   - cd backend && npm run dev
   - Optionally run `./test_auth.sh` to verify register/login/admin ping (requires `jq` for parsing the token)

2. Flutter
   - Update `flutter_app/lib/services/api.dart` BASE_URL if backend is not on `http://10.0.2.2:5000` (Android emulator default)
   - cd flutter_app && flutter pub get
   - flutter run

Phase 1 goal: register, login, get JWT, and be routed to role-specific placeholder screens in the Flutter app.

---

## Phase 5 — Polish, Stability & Demo Readiness ✅

This project has been hardened and visually polished for demo use. Key improvements:

- Booking lifecycle hardened: centralized state guards with atomic transitions and consistent error messages. Invalid booking ids return clear 400 responses.
- Chat & execution safety: chat is only active during `accepted` and `inProgress`; it's read-only afterwards. UI disables inputs and shows friendly messages when chat is locked.
- UI polish:
  - Small color system (Teal primary, Orange accent, light background) for consistent look-and-feel.
  - Status badges for bookings with colors (Pending, Accepted, In Progress, Completed, Cancelled).
  - Card-based layout for providers and bookings, meaningful icons, and friendly empty states.
  - Loading indicators and SnackBar-based errors for smooth demo experience.
- Backend reliability: ObjectId validation on booking routes, consistent error formats (`{ error: '...' }`) and role-based guards everywhere.

### Demo Flow (for an examiner)
1. Register a client and a provider (provider needs to apply and admin to approve).  
2. Client: Search providers → Create booking (optionally select provider).  
3. Provider: Accept booking (booking moves to `accepted`).  
4. Provider: Start job (moves to `inProgress`) → Provider: Mark completed (moves to `completed`).  
5. Client: Confirm completion (moves to `clientConfirmed`).  
6. Chat: available between `accepted` and `inProgress` only (disabled/read-only afterwards).

### UI decisions & accessibility
- Clear contrast and readable text sizes are used for badges and primary actions.
- Simple illustrative banner (in-app, lightweight) and empty states improve the perceived quality without heavy images.

---

Refer to the code for implementation details in `backend/controllers`, `backend/utils/bookingTransitions.js`, and Flutter screens in `flutter_app/lib/screens` (notably: `booking_detail.dart`, `client_bookings.dart`, `provider_bookings.dart`, `provider_list.dart`, `chat_screen.dart`).

