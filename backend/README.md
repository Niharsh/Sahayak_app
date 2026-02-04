# Sahayak Backend (Phase 1)

Phase 1: Authentication + Role-based routing

Prerequisites:
- Create a MongoDB Atlas free-tier cluster and get the connection string (URI). Alternatively, run a local `mongod` on `mongodb://127.0.0.1:27017`.

Run:

1. Copy `.env.example` to `.env` and fill `MONGODB_URI` and `JWT_SECRET`.
2. cd backend && npm install
3. cd backend && npm run dev

APIs:
- POST /auth/register  { name, email, password, role }
- POST /auth/login     { email, password }
- GET /auth/me         (requires `Authorization: Bearer <token>`)

Provider endpoints:
- POST /providers/apply (provider role only, multipart/form-data fields: serviceCategory, serviceAreas(JSON array as string), experienceYears; files: identity, skill)
  Example:
  curl -X POST http://localhost:5000/providers/apply -H "Authorization: Bearer <TOKEN>" -F 'serviceCategory=plumber' -F 'serviceAreas=["Area1","Area2"]' -F 'experienceYears=5' -F 'identity=@/path/to/id.jpg' -F 'skill=@/path/to/cert.pdf'

- GET /providers/me (provider)
- PUT /providers/me (provider, same form-data format)

Admin endpoints:
- GET /admin/providers?status=pending (admin only)
- POST /admin/providers/:id/verify-identity { action: approve|reject, reason? } (admin only)
- POST /admin/providers/:id/verify-skill { action: approve|reject, reason? } (admin only)

Service & Booking endpoints:
- GET /services/categories (public) -> list of categories
- GET /providers/search?category=&area= (public) -> find eligible providers (verificationLevel >= 2)
- POST /bookings (client only) { serviceCategory, serviceArea, schedule, price?, providerId? }
- GET /bookings/me (client or provider depending on role)
- POST /bookings/:id/accept (provider only) — atomic transition from `pendingAcceptance` to `accepted`
- POST /bookings/:id/reject (provider only) — atomic transition from `pendingAcceptance` to `rejected`
- POST /bookings/:id/start (provider only) — atomic transition from `accepted` to `inProgress`
- POST /bookings/:id/complete (provider only) — atomic transition from `inProgress` to `completed`
- POST /bookings/:id/confirm (client only) — atomic transition from `completed` to `clientConfirmed`
- POST /bookings/:id/cancel (client only, only before acceptance)

Notes:
- Booking transitions are centralized with `backend/utils/bookingTransitions.js` to ensure atomic updates and prevent race conditions.
- All routes that accept a booking `:id` param validate ObjectId and return `400` for invalid ids.
- Messaging is allowed only during `accepted` and `inProgress` states; the server enforces this and blocks contact info in messages.

Sample curl flows:

Register:

curl -X POST http://localhost:5000/auth/register -H 'Content-Type: application/json' -d '{"name":"Alice","email":"alice@example.com","password":"password","role":"client"}'

Login:

curl -X POST http://localhost:5000/auth/login -H 'Content-Type: application/json' -d '{"email":"alice@example.com","password":"password"}'

Get profile:

curl -H "Authorization: Bearer <TOKEN>" http://localhost:5000/auth/me
