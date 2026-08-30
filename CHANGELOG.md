# Changelog

All notable changes to CardSnap. Dates are `YYYY-MM-DD`.

---

## [Unreleased] — 2026-08-30

A large stabilisation + integration pass. Test suite grew from 8 → 56 tests;
`flutter analyze` clean throughout. Schema migrated v4 → v8. App renamed
**bizman → CardSnap**; launcher icon added.

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

#### Marketing API integration (Aureole "S&M Hub")
- Saved contacts are pushed to `POST {MARKETING_API_BASE}/api/visiting-card-contacts`
  as "Visiting Card Contacts" using the HRMS token as `Authorization: Bearer`.
- **Durable outbox** (`marketing_sync_queue` table, migration **v7**): `enqueue()`
  never blocks the capture flow; a background `flush()` does the POSTs. A
  Marketing outage leaves rows `pending` for retry (on save / login / app start;
  5-attempt cap). A single flush mutex prevents concurrent double-submit.
- Payload: `name`, `company_name`, `designation`, `phone_numbers[]`, `emails[]`,
  `website`, `social_media[]`, `address` (one line), `notes`,
  `source: "card-scanner"`, and `exhibition_id` (omitted when none).
- 401 → `revalidate()` then retry once; dead session → login, row survives.
- 403 (missing `marketing.create_visiting_card_contact`) → all pending rows
  marked `failed` with the "ask an admin" message.
- 400 / 422 (validation — incl. stale/out-of-domain `exhibition_id`) → row
  `failed`; a 400 about the exhibition also **clears the session exhibition** so
  the user re-picks.
- **Post-send timeout** → `MarketingUncertain`: the card may or may not have been
  created (no server dedup), so it's parked for a **manual** retry, not
  auto-retried. Connection-refused / DNS / 5xx (server didn't get it) still
  auto-retry.
- On 201 the returned `id` is stored on the contact (`marketingContactId`);
  already-synced contacts aren't re-enqueued.
- Failures surface in Settings → **MARKETING SYNC** (message + "Retry failed" +
  per-item discard).
- Config: `--dart-define=MARKETING_API_BASE=…`
  (default `https://api-marketing.encryptedbar.com`).

#### Session exhibition
- `GET /api/exhibitions/active` (needs `marketing.view_events`, cached ~10 min) —
  the server already scopes it to the caller's domain, so no client-side filter.
- **"Set current exhibition"** banner on the main contacts screen — a prominent
  card showing name · location · dates; pick once, persisted across restarts;
  every scan that session defaults to it.
- Per-card override on the review/save screen, pre-selected to the session
  exhibition, plus a Domain/Region/role chip row from `GET /api/auth/scope`.
- Picked exhibition stored on the contact (`exhibitionId` / `exhibitionName`,
  migration **v8**), shown as "Captured at" on the detail screen, and sent as
  `exhibition_id` in the push.
- Load failures show the error + the resolved API URL for diagnosis. Accepts a
  bare array or a `data`/`results`/`exhibitions`/`items` wrapper.

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
- Launcher icon via `flutter_launcher_icons` (source in `assets/icon/`);
  Android adaptive-icon background `#0D1117`.
- Review screen surfaces **why AI was skipped** (bad key, unknown model, rate
  limit, network, unparseable response) instead of silently showing "Local".
- `AppDatabase.forTesting()` constructor; `SessionStore` abstraction for
  testable auth.

### ♻️ Changed

- **AI now always runs when it's enabled.** Previously a confidence gate could
  suppress it — so a confidently-wrong on-device parse (bad company, half an
  address) never reached the model. Now: AI on → AI runs on every scan with
  enough OCR text.
- **AI settings, drastically simplified + restyled.** For OpenAI / Gemini / xAI /
  Groq the screen is a provider dropdown + one API key field + Save/Test. Removed
  the separate text/vision model fields, "Supports Vision" toggle, API-format
  dropdown, and base-URL field (Custom only). One multimodal model per provider,
  shown pre-filled and editable (defaults: `gpt-5-mini`, `gemini-2.5-flash`,
  `grok-4`, `qwen/qwen3.6-27b`). Auto-save-on-typing replaced with an explicit
  **Save** button. Added **Groq**. The card was re-laid-out with labelled filled
  fields, a full-width provider dropdown, mono font for keys/URLs, and
  `BeforthButton` styling.
- **Parser: company / phone / PIN confusion fixed.**
  - Digit-heavy blocks (a bare PIN, a phone) are excluded from company
    candidates entirely.
  - The phone detector ignores digit runs under 7 digits — a 6-digit PIN
    (`411001`, `311 300`, `311-300`) is no longer eaten as a phone.
  - Multi-line addresses are captured **whole** (street line + city/PIN line
    joined), with adjacent digit/comma lines pulled in as continuations.
  - New postal shape for spaced Indian PINs; `"Dr"` removed from street words
    (was matching "Dr. Priya Sharma" as an address).
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
- **Scan flow:** removed the "SCAN CARD" placeholder screen — tapping Scan now
  opens the document scanner straight away (brief spinner only). Cancelling the
  scanner returns to the contact list instead of a dead-end.
- **Fixed: cancelling the document scanner opened the system camera.** The ML Kit
  scanner throws on cancel; that was being caught as "scanner failed" and falling
  back to the plain camera. Cancel is now recognised and just returns.

### 🔤 Naming / branding

- App display name **bizman → CardSnap** (`android:label`, iOS
  `CFBundleDisplayName` / `CFBundleName`). Package id unchanged
  (`com.cardsnap.bizman`).
- Launcher icon generated from `assets/icon/icon.png`.

### 🧪 Tests

- Replaced the stale Flutter counter `widget_test.dart` with a real boot test.
- Added: `local_parser_region_test.dart`, `duplicate_detector_test.dart`,
  `rbac_auth_test.dart`, `marketing_sync_test.dart` (incl. `exhibition_id`
  payload, no-trailing-slash endpoint, timeout→uncertain, 400 handling,
  active-exhibition persistence, multi-line address, PIN-not-company).
- 8 → 56 tests, all green.

### 🗄️ Schema migrations

| Version | Change |
|---|---|
| **v5** | Rebuild `contact_fts` as a real FTS5 table + fix sync triggers |
| **v6** | `contacts.notes` |
| **v7** | `contacts.marketingContactId` + `marketing_sync_queue` table |
| **v8** | `contacts.exhibitionId`, `contacts.exhibitionName` |

### 📦 Dependencies

- Added: `flutter_timezone`, `flutter_launcher_icons` (dev).

### 📱 Platform config

- Android: `POST_NOTIFICATIONS` permission; `ScheduledNotificationReceiver` +
  `ScheduledNotificationBootReceiver`; `proguard-rules.pro`; debug-only
  `usesCleartextTraffic` (for a local dev Marketing API).
- iOS: `UNUserNotificationCenter` delegate in `AppDelegate`;
  `NSAllowsLocalNetworking` (localhost/LAN dev only).
