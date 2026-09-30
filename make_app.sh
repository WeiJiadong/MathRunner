#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")"

APP_NAME="MathRunner"
BUILD_DIR=".build/release"
APP="build/${APP_NAME}.app"
DMG="build/${APP_NAME}.dmg"

echo ">> 构建 release"
swift build -c release

echo ">> 组装 ${APP}"
rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS"
mkdir -p "$APP/Contents/Resources"
cp "$BUILD_DIR/$APP_NAME" "$APP/Contents/MacOS/$APP_NAME"

# App 图标（可选，缺省跳过）
if [ -f "Assets/AppIcon.icns" ]; then
    echo ">> 拷贝图标"
    cp "Assets/AppIcon.icns" "$APP/Contents/Resources/AppIcon.icns"
fi

cat > "$APP/Contents/Info.plist" <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleName</key>            <string>MathRunner</string>
    <key>CFBundleDisplayName</key>     <string>数学小勇士</string>
    <key>CFBundleIdentifier</key>      <string>local.mathrunner.MathRunner</string>
    <key>CFBundleVersion</key>         <string>1.0</string>
    <key>CFBundleShortVersionString</key> <string>1.0</string>
    <key>CFBundleExecutable</key>      <string>MathRunner</string>
    <key>CFBundleIconFile</key>        <string>AppIcon</string>
    <key>CFBundlePackageType</key>     <string>APPL</string>
    <key>CFBundleInfoDictionaryVersion</key> <string>6.0</string>
    <key>LSMinimumSystemVersion</key>  <string>15.0</string>
    <key>NSPrincipalClass</key>        <string>NSApplication</string>
    <key>NSHighResolutionCapable</key> <true/>
    <key>LSUIElement</key>             <false/>
</dict>
</plist>
PLIST

echo ">> ad-hoc 签名"
codesign --force --sign - "$APP"

echo ">> 打 DMG：$DMG"
rm -f "$DMG"
STAGE="build/dmg-stage"
rm -rf "$STAGE"
mkdir -p "$STAGE/.background"
cp -R "$APP" "$STAGE/"
ln -s /Applications "$STAGE/Applications"
hdiutil create -volname "$APP_NAME" -srcfolder "$STAGE" -ov -fs HFS+ -format UDZO "$DMG"
rm -rf "$STAGE"

echo ">> 完成"
echo "  App: $APP"
echo "  DMG: $DMG"
echo "  启动（本地）: open $APP"
echo "  分享：把 $DMG 发给对方，双击挂载后拖入 Applications，首次右键打开。"
