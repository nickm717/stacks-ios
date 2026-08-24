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

## Auth setup (one-time, dashboard side)

Email magic link (`Features/Auth`, `Services/AuthService.swift`) — currently the only sign-in method — needs one piece of configuration outside this repo:

- **Supabase dashboard → Authentication → URL Configuration:** add `com.nickm717.stacks://auth-callback` to the redirect URL allow list, so tapping a magic link can reopen the app.

Without it, the in-app UI still renders but the sign-in link won't complete.

Sign in with Apple is deferred until there's an Apple Developer Program account — see STK-34 in Notion. The removed implementation (system button, ID-token nonce flow, entitlement) is preserved in `stacks-ios` git history on branch `claude/stk-4-2cyfyl`.

## Linting and formatting

- `./Scripts/lint.sh` — SwiftLint (`brew install swiftlint`) plus a swift-format check, no files modified.
- `./Scripts/format.sh` — applies swift-format in place. `swift format` ships with the Swift 6 toolchain in Xcode 16+.
