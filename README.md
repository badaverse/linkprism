# ProfilePrism

A macOS menu bar app + Chrome extension that automatically routes URLs to the right Chrome profile based on domain rules.

> Example: `notion.so` → Work profile, `github.com` → Personal profile

## How It Works

```
Link clicked
    ↓
ProfilePrism (default browser) or Chrome extension receives URL
    ↓
Match against domain/regex rules
    ↓
Open in the matched Chrome profile (or show profile picker)
```

### Components

| Component | Role |
|-----------|------|
| **ProfilePrism.app** | macOS menu bar app. Intercepts http/https URLs and routes them to Chrome profiles based on rules |
| **Chrome Extension** | Detects in-browser link clicks and forwards them to the app via `profileprism://` scheme |

## Features

- Domain-based or regex-based routing rules
- Auto-detection of Chrome profiles (reads `Local State`)
- "Ask every time" mode with a profile picker popup
- Menu bar resident (hidden from Dock)
- Add / edit / delete / toggle rules

## Installation

### macOS App

```bash
# Open in Xcode
open ProfilePrism/ProfilePrism.xcodeproj

# Or build from command line
xcodebuild -project ProfilePrism/ProfilePrism.xcodeproj -scheme ProfilePrism build
```

After building, run `ProfilePrism.app` and set it as the default browser in **System Settings → Desktop & Dock → Default web browser**.

### Chrome Extension

1. Open `chrome://extensions/` in Chrome
2. Enable **Developer mode**
3. Click **Load unpacked** → select the `ProfilePrismExtension/` folder
4. Enter domains to route in the extension popup

## Project Structure

```
ProfilePrism/
├── ProfilePrism/                  # macOS SwiftUI app
│   ├── App/                        #   Entry point, URL event handling
│   ├── Models/                     #   Rule model, config persistence (JSON)
│   ├── Services/                   #   Chrome profile scanner, URL router
│   └── Views/                      #   Rule list, editor, profile picker UI
├── ProfilePrismExtension/         # Chrome extension (Manifest V3)
│   ├── content.js                  #   Link click detection
│   ├── background.js               #   Forwards to profileprism:// scheme
│   └── popup.html/js               #   Domain management popup
├── design-sources/                 # App icon originals
└── docs/                           # Design documents
```

## Tech Stack

- **macOS App**: Swift, SwiftUI, AppKit
- **Chrome Extension**: JavaScript (Manifest V3), Chrome Storage API
- **Build**: Xcode
- **Config**: `~/Library/Application Support/ProfilePrism/rules.json`

## License

MIT
