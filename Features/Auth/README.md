# Features/Auth

Landed with **STK-4** (Supabase auth in app).

- `SignInView.swift` — the O2 sign-in surface: Sign in with Apple as the
  system-styled primary action (Apple HIG requires the system button style;
  see `stacks-context/design/design-decision-log.md`), with email magic link
  as a secondary path. Session state and both sign-in methods are owned by
  `Services/AuthService.swift`.

Out of scope here: the rest of the onboarding journey (welcome, profile
setup, first scan — STK-32) and a `profiles` table / user data model
(STK-5's real-data-models job). This card only gets the Supabase Auth
session itself working end to end, including persistence across restart.
