# iOS Release Runbook

This is the current release path for the iOS-first build.

## Current Verified State

- Bundle id: `com.aicoach.aiCoach`
- Display name: `AI Coach`
- iOS minimum deployment target: `15.0`
- iOS Firebase config must exist locally at
  `ios/Runner/GoogleService-Info.plist`; the real file is ignored by git.
  Use `ios/Runner/GoogleService-Info.plist.example` as the committed template.
- Google Sign-In URL scheme is present in `ios/Runner/Info.plist`.
- Apple Sign-In entitlement is present at `ios/Runner/Runner.entitlements`.
- Custom AppIcon set is present in
  `ios/Runner/Assets.xcassets/AppIcon.appiconset`.
- Local checks have passed:

```sh
flutter analyze
flutter test
npm --prefix functions run build
flutter build ios --release --no-codesign
```

## Blockers Before TestFlight

1. Apple signing is not available locally yet.

Current local check:

```sh
security find-identity -v -p codesigning
```

Last known result was `0 valid identities found`. Add the Apple Developer
account in Xcode and let Xcode create/download signing certificates and
provisioning profiles.

2. Firebase Functions secrets require Blaze.

`dear-diary-483614` must be upgraded to the Blaze plan before Secret Manager can be
enabled. The Firebase console upgrade URL is:

```text
https://console.firebase.google.com/project/dear-diary-483614/usage/details
```

## Firebase Functions Deploy

After the project is on Blaze:

```sh
firebase functions:secrets:set ANTHROPIC_API_KEY --project dear-diary-483614
npm --prefix functions run build
firebase deploy --only functions --project dear-diary-483614
```

Do not commit Anthropic keys. Keep local emulator values in
`functions/.secret.local`, which is ignored by git.

Do not commit real Firebase client config files either. Keep
`ios/Runner/GoogleService-Info.plist` local and rotate/restrict exposed Google
API keys in Google Cloud Console if a config file was ever pushed.

## Apple Signing Setup

1. Open Xcode.
2. Go to Xcode Settings > Accounts and add the Apple Developer account.
3. Open `ios/Runner.xcworkspace`.
4. Select the `Runner` target.
5. In Signing & Capabilities:
   - Enable automatic signing.
   - Select the Apple Developer Team.
   - Confirm bundle id is `com.aicoach.aiCoach`.
   - Confirm Sign in with Apple remains enabled.
6. Re-run:

```sh
security find-identity -v -p codesigning
```

At least one valid Apple Development or Apple Distribution identity should be
listed before signed builds are expected to work.

## TestFlight Build

After signing is configured:

```sh
flutter clean
flutter pub get
cd ios
pod install --repo-update
cd ..
flutter build ipa --release --build-name 1.0.0 --build-number 1
```

The generated IPA should appear under:

```text
build/ios/ipa/
```

Upload it with Xcode Organizer, Transporter, or `xcrun altool`/App Store
Connect tooling depending on the local Apple setup.

## Device Smoke Test

Before submitting to TestFlight testers:

1. Install a signed build on a real iPhone.
2. Verify Google Sign-In.
3. Verify Apple Sign-In.
4. Run the app with real Firebase backend enabled:

```sh
flutter run --release --dart-define=AI_COACH_USE_FUNCTIONS=true
```

5. Submit one short IELTS essay.
6. Confirm:
   - callable function succeeds
   - Firestore creates `essays/{essayId}`
   - Firestore creates `essay_analyses/{essayId}`
   - user credit is decremented
   - the app shows the Claude analysis result
