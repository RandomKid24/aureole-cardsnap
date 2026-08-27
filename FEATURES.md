# CardSnap Features and File Locations

This document maps the application features to their corresponding source code locations.

## 1. Core Scanning & OCR
- **Image Preprocessing:** `lib/features/scan/image_processor.dart` (Grayscale, thresholding, deskewing).
- **OCR Service:** `lib/features/scan/ocr_service.dart` (ML Kit integration, block sorting).
- **Camera Interface:** `lib/features/scan/camera_screen.dart` (Document scanner integration, front/back toggle).

## 2. Parsing Engine
- **Local Rules Parser:** `lib/features/parse/local_parser.dart` (Regex, positional heuristics, keyword mapping).
- **AI Parser:** `lib/features/parse/ai_parser.dart` (OpenAI-compatible and Gemini APIs; text and vision).
- **Confidence Logic:** `lib/features/parse/confidence_engine.dart` (Determines when to trigger AI).
- **Correction Learning:** `lib/features/parse/corrections_store.dart` records every review edit; `lib/features/parse/parse_pipeline.dart` replays the most common past correction for name/company/designation on future scans.

## 3. Contact Management
- **Contact List:** `lib/features/contacts/list_screen.dart` (Search, filter, slide-to-delete, multi-select).
- **Contact Details:** `lib/features/contacts/detail_screen.dart` (Action buttons, notes timeline, save to phone).
- **Review & Edit:** `lib/features/review/review_screen.dart` (Confidence indicators, duplicate detection, field editing).

## 4. Free Features (Offline)
- **Follow-up Reminders:** set per contact in `lib/features/contacts/detail_screen.dart` (date/time + note), listed in `lib/features/reminders/reminders_screen.dart`, scheduled as a local notification via `lib/core/notifications/notification_service.dart`.
- **CSV Export:** `lib/features/contacts/list_screen.dart` (Using `csv` package).
- **Duplicate Detection:** `lib/features/review/review_screen.dart` (Normalization and comparison logic).
- **Stats & Insights:** `lib/features/stats/stats_screen.dart` (Scans over time, network summary).
- **Save to Phone:** `lib/features/contacts/detail_screen.dart` (Using `flutter_contacts`).

## 5. System & Infrastructure
- **Database (Drift):** `lib/core/database/database.dart` and `lib/core/database/contacts_dao.dart`.
- **Secure Storage:** `lib/core/secure_storage/key_storage.dart` (API key management).
- **Theme & Brand:** `lib/shared/theme/app_theme.dart` and `lib/shared/widgets/dot_grid_painter.dart`.
- **Routing:** `lib/app.dart` (Using `go_router` with Bottom Navigation).
