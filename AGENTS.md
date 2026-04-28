# Repository Instructions

## Project

WhereBixi is an iOS SwiftUI app for quickly finding nearby BIXI bikes or open docks without using a map-first interface.

## Important docs

- `docs/ARCHITECTURE.md` describes the intended architecture and must distinguish what is implemented from what is planned.
- `docs/BIXI_API.md` is the source of truth for BIXI GBFS API details, feed URLs, refresh timing, and field semantics.

## Working guidelines

- Keep changes minimal and focused.
- After making Swift/iOS code changes, verify the app still builds with `xcodebuild` when practical.
- Update `docs/ARCHITECTURE.md` after meaningful architecture or feature changes, clearly marking implemented vs planned behavior.
- Check `docs/BIXI_API.md` before adding or changing BIXI API assumptions; update it if those assumptions change.
- Do not commit local Xcode/macOS state such as `xcuserdata/`, `*.xcuserstate`, or `.DS_Store`.
