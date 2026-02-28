# Releasing LinkPrism

## Prerequisites

```bash
brew install create-dmg
```

## 1. Update Version

In **Xcode** → project target → General → **Version** (MARKETING_VERSION):

```
0.1.0 → 0.2.0
```

Both Debug and Release configurations should match.

## 2. Build the App

1. Open `LinkPrism/LinkPrism.xcodeproj` in Xcode
2. Select **Product → Archive**
3. In the Organizer, click **Distribute App → Copy App**
4. Save `LinkPrism.app` to a staging folder (e.g. `.releases/`)

## 3. Create DMG

```bash
cd .releases

create-dmg \
  --volname "LinkPrism" \
  --background ../assets/dmg-background.png \
  --window-pos 200 120 \
  --window-size 660 400 \
  --icon-size 100 \
  --icon "LinkPrism.app" 170 200 \
  --app-drop-link 490 200 \
  --no-internet-enable \
  LinkPrism.dmg \
  LinkPrism.app
```

Open the DMG to verify the layout (app icon + arrow + Applications folder).

## 4. Package Chrome Extension

```bash
cd LinkPrismExtension
zip -r ../.releases/LinkPrismExtension.zip . -x '*.DS_Store'
```

## 5. Create GitHub Release

```bash
gh release create v<VERSION> \
  .releases/LinkPrism.dmg \
  .releases/LinkPrismExtension.zip \
  --title "LinkPrism v<VERSION>" \
  --notes "$(cat <<'EOF'
## LinkPrism v<VERSION>

### Highlights
- ...

---

<details>
<summary>한국어</summary>

### 주요 변경사항
- ...
</details>
EOF
)"
```

## 6. Verify

- [ ] Download DMG from release page and install
- [ ] App launches and shows onboarding (clean install) or menu bar icon
- [ ] Auto-update checker finds the new release
- [ ] Chrome extension loads from zip
