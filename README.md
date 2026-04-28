# Velo Radar

[![CI](https://github.com/coffee-cup/velo-radar/actions/workflows/ci.yml/badge.svg)](https://github.com/coffee-cup/velo-radar/actions/workflows/ci.yml)

Velo Radar is an iOS SwiftUI app for quickly finding nearby BIXI bikes or open docks without starting from a map.

## Development

Open `wherebixi-ios/wherebixi.xcodeproj` in Xcode.

Run tests from the command line:

```sh
xcodebuild test \
  -project wherebixi-ios/wherebixi.xcodeproj \
  -scheme wherebixi \
  -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.4.1' \
  CODE_SIGNING_ALLOWED=NO
```
