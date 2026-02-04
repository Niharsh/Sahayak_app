# Sahayak Flutter App (Phase 1)

Phase 1–5: Auth, Provider onboarding, Booking, Chat, Execution & Polish

This Flutter app now includes visual polish for demo readiness: consistent color palette (Teal primary, Orange accent), card-based lists, status badges for bookings, and friendly empty/loading states.

Notes:
- Update the base URL in `lib/services/api.dart` if backend is on a different host.
- Use Android emulator: the backend default is `http://10.0.2.2:5000`.

Provider flows:
- Providers can apply via `POST /providers/apply` (multipart/form-data). Use the "Apply / Edit Profile" button on Provider Home.
- Check status on Provider Status screen.

Admin flows:
- Admin can view pending providers via "Pending Providers" on Admin Home and approve/reject identity and skill stages.

Run:
- flutter pub get
- flutter run
