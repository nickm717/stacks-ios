# CLAUDE.md — Operating Rules for stacks-ios

This file is the entry point for any AI agent working in **this repo** (Claude Code, Cowork, or otherwise). Read it first.

*Stacks turns private bookshelves into a shared neighborhood library. This repo is the iOS app's code — nothing else.*

---

## Where this repo sits

`stacks-ios` holds **app code only**. It never holds specs, PRDs, decisions, or design rationale — those live in [`nickm717/stacks-context`](https://github.com/nickm717/stacks-context) and are read-only reference from here. Work state (status, assignment, task history) lives in Notion, not in this repo and not in GitHub Issues.

| System | Owns | Never holds |
|---|---|---|
| **`stacks-context`** (git) | Specs, PRDs, decisions, design rationale | Kanban state, task assignment |
| **Notion** ("Stacks" workspace → **Work Items** database) | Work state, assignment, working prompts, per-task history | Spec content — ever |
| **`stacks-ios`** (this repo) | App code | Specs, work state |
| **Figma** | Design files, frames, components | Written rationale |

If you catch yourself about to paste spec content into this repo or into a Notion card body, stop — it belongs in `stacks-context`.

---

## Before starting any task

1. **Check Notion first.** The Work Items database is the source of truth for what's in flight. A card is only safe to start when Status = **Ready for Worker**, which means: a spec exists in `stacks-context` and `Linked doc` points at it, the Working Prompt section is filled in, and acceptance criteria are checkable. If a card is thinner than that, ask before proceeding rather than inventing scope.
2. **Read the linked spec in `stacks-context`.** Follow the card's `Linked doc`. At minimum, skim `decisions/decision-log.md` and (for anything user-facing) `design/design-decision-log.md` — between them they hold reasoning the specs themselves omit.
3. **Never contradict an Accepted decision silently.** If new work seems to conflict with one, surface it explicitly and say which decision it touches.

## While working

- **Platform: native Swift / SwiftUI.** Accepted 2026-08-21 in `stacks-context/decisions/decision-log.md` ("Platform and stack"), superseding an earlier React Native + Expo plan. Full detail in `stacks-context/engineering/platform-and-stack.md`.
- **Backend: Supabase** — Postgres, Auth (Sign in with Apple), Storage, Realtime. Row-level security is the sharing mechanism; visibility rules belong in RLS policies, not app-side filtering.
- **Data model, scanning approach, copy-state machine, etc.** — read the relevant file under `stacks-context/engineering/` or `stacks-context/circulation/` before implementing; don't re-derive these from scratch.
- **User-facing strings** must follow `stacks-context/design/voice-and-tone.md`.

## After finishing

1. Commit to git — that's the real change history for the code itself.
2. Move the Notion card to **Review** and append what happened to its **Worker Log** (append-only; what was done, what surprised you, what got deferred).
3. If something learned deserves to persist beyond this one task, it belongs in `stacks-context`'s `decisions/decision-log.md` or `design/design-decision-log.md` — not in the Notion card body, which is disposable and task-scoped.

## Reading `stacks-context`

This session can read `stacks-context` directly (public repo, read-only). If a future session doesn't have it attached yet, clone it:

```
GIT_LFS_SKIP_SMUDGE=1 git clone --depth 1 https://github.com/nickm717/stacks-context
```

Start with `stacks-context/CLAUDE.md` (its own operating rules), then `decisions/decision-log.md` for the fastest way to get current.

## Notion

The "Stacks" workspace's **Work Items** database tracks every card (`STK-<n>`). Full conventions — status definitions, the handoff sequence, view purposes — are on the **How This Works** page in that workspace, linked from the database.
