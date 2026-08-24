# stacks-ios
Stacks iOS app (native Swift/SwiftUI). Specs and decisions live in nickm717/stacks-context.

## Setup

1. Install Xcode 26+ and [XcodeGen](https://github.com/yonaskolb/XcodeGen): `brew install xcodegen`
2. Generate the Xcode project (not checked in — regenerate from `project.yml` after every pull that touches it):
   ```
   xcodegen generate
   ```
3. Open `Stacks.xcodeproj`, let Xcode resolve the Supabase Swift package, select a simulator, and Run (⌘R).
4. Once it resolves packages for the first time, commit the generated `Package.resolved` if it isn't already tracked.

The root view is a placeholder that renders the configured Supabase project host, confirming the scaffold and `Config/Supabase.xcconfig` wiring both work.

## Auth setup (one-time, dashboard/portal side)

Sign in with Apple and email magic link (`Features/Auth`, `Services/AuthService.swift`) need configuration outside this repo before either works end to end:

- **Apple Developer portal:** enable the "Sign in with Apple" capability on the `com.nickm717.stacks` App ID. (`App/Stacks.entitlements` already declares it app-side; running on a real device/App Store build needs the portal side too. The simulator generally works without it.)
- **Supabase dashboard → Authentication → Sign In / Providers → Apple:** enable the provider and supply the Services ID, Team ID, Key ID, and private key for Sign in with Apple.
- **Supabase dashboard → Authentication → URL Configuration:** add `com.nickm717.stacks://auth-callback` to the redirect URL allow list, so tapping a magic link can reopen the app.

Without these, the in-app UI still renders but the corresponding sign-in method will fail at the network call.

## Linting and formatting

- `./Scripts/lint.sh` — SwiftLint (`brew install swiftlint`) plus a swift-format check, no files modified.
- `./Scripts/format.sh` — applies swift-format in place. `swift format` ships with the Swift 6 toolchain in Xcode 16+.
