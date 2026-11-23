# CardSnap

**Scan. Save. Connect.** — Aureole's business-card scanner for the Android phones of the people who work exhibitions and roadshows.

Point the camera at a card, CardSnap reads it, and the contact lands in the Marketing system tagged with the exhibition it was collected at.

## Download

Get the latest APK from **[Releases](https://github.com/RandomKid24/aureole-cardsnap/releases/latest)** → `cardsnap.apk`.

1. Open the link on your phone and download `cardsnap.apk`.
2. Open it. If Android asks, allow installs from this source.
3. Sign in with your HRMS login.
4. **Settings** → paste your **Groq API key** → **Save**.

### Updates

You never need to download again. When a new version is published, CardSnap shows **Update available** on launch — tap **Update now**, it downloads and opens the installer.

## What it does

- **Scan** a card with the camera (auto-crop); text is read on the phone with Google ML Kit.
- **Parse** name, company, designation, phones, emails, website and address. When on-device parsing is unsure, the **Groq** model gives a second pass using the card image.
- **Pick the exhibition** you are at once; every new scan is tagged with it.
- **Sync** each card to the Marketing system (`/api/visiting-card-contacts`) using your HRMS login. Cards are queued and retried when offline.
- **Contact list** with the scanned card photo on every row (tap a contact, then the photo, to view it full-screen and zoom), favourites, and follow-up reminders shown under the name.
- **Export / import** everything as vCard or CSV.

## Settings

Only one setting needs your attention: the **Groq API key**. Leave it empty and CardSnap still works with on-device parsing only.

## Build it yourself

Requires Flutter 3.38 and JDK 17.

```bash
flutter pub get
flutter build apk --release
```

Backend addresses default to production and can be overridden:

```bash
flutter build apk --release \
  --dart-define=HRMS_BASE_URL=https://hrms.example.com \
  --dart-define=MARKETING_API_BASE=https://marketing.example.com
```

## Releases and auto-update (how it works)

Every push to `main` runs [`.github/workflows/build.yml`](.github/workflows/build.yml):

1. Builds a signed release APK. The GitHub run number is the app's build number.
2. Publishes it as release `v1.0.<run number>` with the file named `cardsnap.apk`.

On launch the app asks GitHub for the latest release. If its number is higher than the installed build number, the update prompt appears.

### One-time repository setup

Add these under **Settings → Secrets and variables → Actions**. They hold the signing key — every release must be signed with the same key, or Android refuses to install it as an update.

| Secret | Value |
|---|---|
| `KEYSTORE_BASE64` | the keystore file, base64-encoded (`base64 -i release.keystore`) |
| `KEYSTORE_PASSWORD` | keystore password |
| `KEY_ALIAS` | key alias (`cardsnap`) |
| `KEY_PASSWORD` | key password |

**Keep a backup of the keystore.** If it is lost, phones with the app installed must uninstall and reinstall once to get future versions.

## Project layout

```
lib/
  core/      auth (HRMS), marketing sync, database (Drift/SQLite), update check
  features/  scan, review, contacts, settings, reminders, stats
  shared/    BeForth theme and widgets
```

Built by [BeForth](https://www.beforth.in) for Aureole.
