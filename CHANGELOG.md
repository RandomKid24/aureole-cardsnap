# Changelog

All notable changes to CardSnap. Dates are `YYYY-MM-DD`.

---

## [Unreleased] — 2026-08-30

A large stabilisation + integration pass. Test suite grew from 8 → 49 tests;
`flutter analyze` clean throughout. Schema migrated v4 → v8.

### 🐛 Critical fixes

- **Contacts could never be saved.** `contact_fts` was registered as a normal
  Drift table, so `createAll()` built a plain table that shadowed the FTS5
  virtual table, and the sync triggers referenced columns that don't exist
  (`new.emailsJson` vs the real `emails_json`). Every `INSERT`/`UPDATE`/`DELETE`
  on `contacts` threw → "Failed to save contact" for every scan. Rebuilt as a
  standalone FTS5 table with corrected triggers; migration **v5** drops the
  broken objects and recreates them. Search now works too.
- **Reminders fired at the wrong wall-clock time.** `tz.local` was never set, so
  it stayed UTC. Now resolved from the device with `flutter_timezone`, using the
  `latest_all` tz database so legacy zone IDs some Android devices still report
  (`Asia/Calcutta`, `Asia/Rangoon`, …) resolve instead of throwing.
- **Duplicate detector merged unrelated people.** It matched on name Soundex
  *alone* and company *alone*, so a second coworker (or any two "John"s) collapsed
  into one contact. Now a shared phone/email is a duplicate on its own; a name
  match requires company **or** website to also agree. Phone comparison is
  country-agnostic (last 9 digits), dropping the `^91` strip.
- **Release build (R8) failed.** `google_mlkit_text_recognition` references the
  Chinese/Devanagari/Japanese/Korean recognizers we don't bundle. Added
  `android/app/proguard-rules.pro` with the `-dontwarn` rules plus GSON / keep
  rules for `flutter_local_notifications` (needed for reboot rescheduling under
  R8). Flutter auto-applies the file.
- **Unguarded startup.** `main()` now runs inside `runZonedGuarded` with
  per-step `try/catch` — only a DB failure hard-stops; a broken notification
  plugin or unreadable prefs no longer shows a blank screen.
- Crash guards for empty `name` / `phones` / `emails` (list avatar, detail
  Call/Email buttons, share text).

### ✨ Added

#### HRMS RBAC login
- Login screen (username **or** Employee ID + password) gating the whole app.
- Token stored in the OS secure store (Keychain / Keystore) — not shared-prefs,
  not `localStorage`. The whole session is cached for offline use.
- `Authorization: Token <token>` on every RBAC call (not `Bearer`).
- Route guard in `app.dart`: splash → `/login` if no valid token → app.
- Defensive: a request is treated as **not authorized** on 401/403, empty body,
  non-JSON, `success:false`, missing token, or any non-2xx — not just 401.
  Transport failures keep the cached session and flag "offline".
- `AuthService.revalidate()` for other APIs to re-check the token.
- Settings → **ACCOUNT**: name, Employee ID, role chips, offline indicator,
  Sign out (local contacts are kept).
- Config: `--dart-define=HRMS_BASE_URL=…` (default `https://hrms.encryptedbar.com`).

#### Marketing API integration
- Saved contacts are pushed to `POST {MARKETING_API_BASE}/api/visiting-card-contacts/`
  as "Visiting Card Contacts" using the HRMS token as `Authorization: Bearer`.
- **Durable outbox** (`marketing_sync_queue` table, migration **v7**): `enqueue()`
  never blocks the capture flow; a background `flush()` does the POSTs. A
  Marketing outage leaves rows `pending` for retry (on save / login / app start;
  5-attempt cap).
- 401 → `revalidate()` then retry once; dead session → login, row survives.
- 403 (missing `marketing.create_visiting_card_contact`) and 422 (validation)
  → row marked `failed`, surfaced in Settings → **MARKETING SYNC** with the
  message + "Retry failed" + per-item discard.
- On 201 the returned `id` is stored on the contact (`marketingContactId`);
  already-synced contacts aren't re-enqueued.
- Payload is exactly the 11 documented fields — plain string arrays, `address`
  as one line, `source: "card-scanner-app"`, no internal Marketing IDs.
- Config: `--dart-define=MARKETING_API_BASE=…`
  (default `https://api-marketing.encryptedbar.com`).

#### Marketing reference data (exhibitions)
- `GET /api/auth/scope` (employee domain/region) and
  `GET /api/exhibitions/active` (cached ~10 min) via
  `MarketingSyncService.loadCaptureContext()`.
- **"Set current exhibition"** banner on the main contacts screen — pick once,
  persisted across restarts; every scan defaults to it.
- Exhibition picker on the review/save screen (per-card override, pre-selected
  to the active one) plus a Domain/Region/role chip row.
- Picked exhibition stored on the contact (`exhibitionId` / `exhibitionName`,
  migration **v8**), shown as "Captured at" on the detail screen, and carried
  into the push as an `Exhibition: …` line in `notes` (the API has no exhibition
  field by design).
- 403 → "grant `marketing.view_events`" notice; other failures show the error +
  the resolved API URL for diagnosis. Accepts a bare array or a
  `data`/`results`/`exhibitions`/`items` wrapper.

#### Notes field
- New free-text `notes` field on the contact record (migration **v6**), separate
  from the timestamped notes timeline (relabelled **TIMELINE**).
- Editable in the review screen and inline on the detail screen (**NOTES** card).
- Included in CSV export/import (`notes` column), vCard (`NOTE:`), and
  "Save to phone contacts". Appended (not overwritten) when merging a re-scan.

#### Other
- Reminders, end to end: set a follow-up (date + time + note) on the detail
  screen → schedules a local notification → **REMINDERS** screen lists pending +
  overdue → tapping the notification opens the contact (foreground / background /
  cold start).
- Back-of-card OCR: the second captured image is now OCR'd and field-merged
  (previously stored and ignored).
- Correction-learning loop wired: review edits to name/company/designation are
  recorded **and replayed** on future scans (was write-only).
- OCR: Devanagari script model auto-selected for Hindi/Marathi/etc. locales
  (also reads Latin).
- Multi-value phone/email in the review screen (add/remove rows) instead of
  collapsing to the first.
- `AppDatabase.forTesting()` constructor; `SessionStore` abstraction for
  testable auth.

### ♻️ Changed

- **AI settings, drastically simplified.** For OpenAI / Gemini / xAI / Groq the
  screen is now just a provider dropdown + one API key field + Save/Test. Removed
  the separate text/vision model fields, "Supports Vision" toggle, API-format
  dropdown, and base-URL field (Custom only). One multimodal model per provider,
  shown pre-filled and editable (defaults refreshed: `gpt-5-mini`,
  `gemini-2.5-flash`, `grok-4`, `qwen/qwen3.6-27b`). Auto-save-on-typing replaced
  with an explicit **Save** button. Added **Groq**.
- **De-hardcoded the India bias.** Phone country code comes from the device
  locale (full ISO calling-code table) and falls back to national format when
  the region is unknown — no more forced `+91`. Address detection uses structural
  signals (postal-code shapes, international street/unit words, comma segments)
  instead of a list of Indian cities/states. AI few-shot examples diversified
  (India + US + Europe).
- **Contact detail screen redesigned.** Working back button after save (was a
  dead end); gradient scrim over the card photo (or a clean avatar header when
  there's none); single tappable **CONTACT INFO** card (phone → dialer, email →
  mail, website/LinkedIn → browser, address → maps); Call/Text/Email/Add quick
  actions filtered to what's available; consistent dot-grid background.
- **Add-note popup no longer janky.** Extracted `_TextInputSheet` so only a tiny
  subtree depends on the keyboard inset (the heavy detail screen behind the modal
  no longer rebuilds per frame); focus deferred ~260 ms so the sheet slide and
  keyboard don't animate over each other; controllers disposed.
- Stats screen shows **real** data — per-day scan counts for the last 7 days and
  an actual consecutive-day streak (was hardcoded bars + "0 DAYS 🔥").
- Image preprocessing skips perspective correction and the 60-angle deskew search
  when the ML Kit document scanner already rectified the image (~1 s faster,
  no re-distortion).
- Contact list: staggered entrance animation only for the first screenful (no
  replay-jank on scroll).
- `RemindersScreen` uses the injected `AppDatabase` instead of opening a second
  connection.
- Review "Save" button: one-shot slide-up instead of a scale pulse.
- Removed the non-functional "Theme: System" settings tile (no dark mode).
- `image_picker` / `image_cropper` pinned (`^1.2.1` / `^12.2.1`, were `any`).

### 🧪 Tests

- Replaced the stale Flutter counter `widget_test.dart` with a real boot test.
- Added: `local_parser_region_test.dart`, `duplicate_detector_test.dart`,
  `rbac_auth_test.dart`, `marketing_sync_test.dart`.
- 8 → 49 tests, all green.

### 🗄️ Schema migrations

| Version | Change |
|---|---|
| **v5** | Rebuild `contact_fts` as a real FTS5 table + fix sync triggers |
| **v6** | `contacts.notes` |
| **v7** | `contacts.marketingContactId` + `marketing_sync_queue` table |
| **v8** | `contacts.exhibitionId`, `contacts.exhibitionName` |

### 📦 Dependencies

- Added: `flutter_timezone`.

### 📱 Platform config

- Android: `POST_NOTIFICATIONS` permission; `ScheduledNotificationReceiver` +
  `ScheduledNotificationBootReceiver`; `proguard-rules.pro`; debug-only
  `usesCleartextTraffic` (for a local dev Marketing API).
- iOS: `UNUserNotificationCenter` delegate in `AppDelegate`;
  `NSAllowsLocalNetworking` (localhost/LAN dev only).
