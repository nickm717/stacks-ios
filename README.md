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

## Linting and formatting

- `./Scripts/lint.sh` — SwiftLint (`brew install swiftlint`) plus a swift-format check, no files modified.
- `./Scripts/format.sh` — applies swift-format in place. `swift format` ships with the Swift 6 toolchain in Xcode 16+.
