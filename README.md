# Wellnest

An all-in-one workspace for healthcare professionals in the UAE: licence renewal, continuing medical education, peer-reviewed publications and clinical news — in a single, secure app.

This repository contains a high-fidelity Flutter prototype focused on visual identity, motion and interaction quality. All data is local sample content; no backend services are required.

## Identity

**Emerald Matrix** — a deep emerald HUD world with ivory typography and gold-leaf detail.

- **Emerald** shell: hexagonal matrix grid, scanlines, glyph rain and lit corner brackets.
- **Ivory** paper surfaces for reading: certificates, featured papers and the article reader.
- **Gold flakes** tumble through the splash screen and return as accents, seals and celebrations across the app.
- **Mark**: a single continuous line drawing a "W" inside a hexagonal nest, crowned by one gold flake (`assets/brand/logo.svg`).
- **Type**: Sora (display), Inter (interface), JetBrains Mono (data), Newsreader (reading). All fonts are bundled for offline use.

## Experience

| Area | Highlights |
| --- | --- |
| Splash | Seamless hand-off from the native launch screen, light pulse along the mark, gold flake burst and shower, grid power-up, typed tagline |
| Onboarding | Three illustrated pages built in code with parallax and a morphing indicator |
| Sign-in | Encrypted credential panel and a biometric scan with haptic feedback |
| Home | Licence countdown ring with live ECG trace, animated stats, quick actions, learning carousel, live news ticker, notifications |
| Licence | Holographic licence card — drag to tilt, tap to flip to a verification QR — plus requirements and history |
| Renewal | Four-step flow with live compliance scan, document upload and hold-to-pay, ending in a gold seal celebration |
| CME | Search and filters, generative course covers, card-to-page expansion, module progress and stamped certificates |
| Library | Publications, news and saved items with an ivory article reader, animated figures and citations |
| Profile | Credentials, preferences (including an app-wide reduce-motion switch) and sign-out |

Actions carry through the whole app: renewing updates the licence card, timeline and dashboard; claiming a certificate adds credits everywhere they appear.

## Demo path

1. Launch and let the splash play, then swipe through onboarding.
2. Sign in with **Biometric sign-in**.
3. On Home, tap **Renew now** and complete the four steps — hold the gold button to pay.
4. Open **View digital licence**; drag the card to tilt it and tap to flip it.
5. In **CME**, open *Heat-Related Illness*, complete its three modules and claim the certificate.
6. In **Library**, open the featured paper to read it in the ivory reader.

## Architecture

- **Flutter 3.44 / Dart 3.12**
- **State**: Riverpod 3 notifiers over local sample data
- **Navigation**: go_router 18 with a stateful shell for tabs and custom page routes (scan reveal, card expand, fade)
- **Motion**: hand-built with core Flutter APIs — shared motion tokens, staggered entrances, springs, custom painters and a particle system — all respecting reduced-motion settings

```
lib/
  core/        theme, router, effects, shared widgets, utilities
  features/    splash, onboarding, auth, shell, home, licence, cme, library, profile
assets/
  brand/       logo
  fonts/       bundled typefaces
  launcher/    app icon and launch screen sources
```

## Running

```bash
flutter pub get
flutter run
```

Runs on iOS 15+ and Android phones in portrait. App icons and launch screens are generated from `assets/launcher` with:

```bash
dart run flutter_launcher_icons
dart run flutter_native_splash:create
```

## Quality

```bash
flutter analyze
flutter test
```
