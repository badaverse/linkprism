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

## Releasing

앱에 내장된 자동 업데이트 기능은 GitHub Releases API (`badaverse/profileprism`)를 확인합니다.

### 릴리즈 순서

1. **버전 올리기** — Xcode에서 `MARKETING_VERSION` 변경 (예: `1.0` → `1.1`)
2. **빌드** — `Product → Archive → Distribute App → Copy App`
3. **Ad-hoc 서명** (Developer ID가 없는 경우)
   ```bash
   codesign --force --deep --sign - ProfilePrism.app
   ```
4. **DMG 만들기**
   ```bash
   hdiutil create -volname ProfilePrism -srcfolder ProfilePrism.app -ov -format UDZO ProfilePrism-1.1.dmg
   ```
5. **GitHub Release 생성**
   ```bash
   gh release create v1.1 ProfilePrism-1.1.dmg --title "v1.1" --notes "변경 사항 작성"
   ```

### 규칙

| 항목 | 형식 | 예시 |
|------|------|------|
| Tag | `v{MAJOR}.{MINOR}` 또는 `v{MAJOR}.{MINOR}.{PATCH}` | `v1.1`, `v1.2.3` |
| DMG 파일명 | `ProfilePrism-{version}.dmg` | `ProfilePrism-1.1.dmg` |
| Xcode 버전 | `MARKETING_VERSION`과 tag 숫자 일치 | Xcode `1.1` = tag `v1.1` |

> 앱의 "업데이트 확인" 메뉴에서 tag의 `v` prefix를 제거 후 `CFBundleShortVersionString`과 비교합니다. DMG 에셋이 있으면 직접 다운로드, 없으면 릴리즈 페이지로 이동합니다.

## Tech Stack

- **macOS App**: Swift, SwiftUI, AppKit
- **Chrome Extension**: JavaScript (Manifest V3), Chrome Storage API
- **Build**: Xcode
- **Config**: `~/Library/Application Support/ProfilePrism/rules.json`

## License

MIT
