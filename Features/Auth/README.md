# Features/Auth

Landed with **STK-4** (Supabase auth in app).

- `SignInView.swift` — the O2 sign-in surface: email magic link, currently
  the only sign-in method. Session state and the sign-in flow are owned by
  `Services/AuthService.swift`.

Sign in with Apple was implemented and then pulled back out of STK-4's
scope — no Apple Developer Program account yet. It's tracked separately as
**STK-34**; the removed implementation (system button, ID-token nonce flow,
entitlement) is preserved in git history on branch `claude/stk-4-2cyfyl`.

Out of scope here: the rest of the onboarding journey (welcome, profile
setup, first scan — STK-32) and a `profiles` table / user data model
(STK-5's real-data-models job). This card only gets the Supabase Auth
session itself working end to end, including persistence across restart.
