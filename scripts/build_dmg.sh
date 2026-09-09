#!/usr/bin/env bash
# ==============================================================================
# scripts/build_dmg.sh
# SalaryTicker（时薪）macOS DMG 自动化构建打包脚本
# ==============================================================================

set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DIST_DIR="${PROJECT_DIR}/dist"
BUILD_DIR="${PROJECT_DIR}/build"
STAGING_DIR="${DIST_DIR}/staging"
DMG_NAME="SalaryTicker.dmg"
DMG_PATH="${DIST_DIR}/${DMG_NAME}"
VOL_NAME="SalaryTicker"

echo "=========================================="
echo "🚀 开始构建并打包 SalaryTicker DMG..."
echo "=========================================="

export DEVELOPER_DIR="${DEVELOPER_DIR:-/Applications/Xcode.app/Contents/Developer}"

if [ ! -d "${DEVELOPER_DIR}" ]; then
    echo "❌ 错误: 未在 ${DEVELOPER_DIR} 找到 Xcode。请确保已安装 Xcode。"
    exit 1
fi

# 1. 清理并准备目录
rm -rf "${STAGING_DIR}" "${BUILD_DIR}"
mkdir -p "${DIST_DIR}" "${STAGING_DIR}"

# 2. 重新生成 Xcode 工程以确保最新
if command -v xcodegen >/dev/null 2>&1; then
    echo "⚙️ 正在通过 xcodegen 更新 Xcode 工程..."
    xcodegen generate
fi

# 3. 执行 Release 归档/编译
echo "🔨 正在使用 Xcodebuild 编译 Release 构件..."
xcodebuild -project "${PROJECT_DIR}/SalaryTicker.xcodeproj" \
    -scheme SalaryTicker \
    -configuration Release \
    -destination 'platform=macOS' \
    -derivedDataPath "${BUILD_DIR}/DerivedData" \
    build

APP_PATH="${BUILD_DIR}/DerivedData/Build/Products/Release/SalaryTicker.app"

if [ ! -d "${APP_PATH}" ]; then
    echo "⚠️ 未在默认 derivedDataPath 找到，尝试常规路径查找..."
    APP_PATH="$(find "${BUILD_DIR}" -name "SalaryTicker.app" -type d | head -n 1)"
fi

if [ ! -d "${APP_PATH}" ]; then
    echo "❌ 错误: 未能生成 SalaryTicker.app，请检查编译日志！"
    exit 1
fi

echo "✅ App 编译成功: ${APP_PATH}"

# 4. 组装 DMG 挂载卷内容
echo "📦 组装 DMG 挂载卷内容..."
cp -R "${APP_PATH}" "${STAGING_DIR}/SalaryTicker.app"

# 确保清除隔离属性与刷新时间戳，保证 Finder 识别图标
xattr -cr "${STAGING_DIR}/SalaryTicker.app" 2>/dev/null || true
touch "${STAGING_DIR}/SalaryTicker.app"

# 为 DMG 挂载卷配置自定义图标
if [ -f "${PROJECT_DIR}/Resources/AppIcon.icns" ]; then
    cp "${PROJECT_DIR}/Resources/AppIcon.icns" "${STAGING_DIR}/.VolumeIcon.icns"
    if command -v SetFile >/dev/null 2>&1; then
        SetFile -c icnC "${STAGING_DIR}/.VolumeIcon.icns" 2>/dev/null || true
        SetFile -a C "${STAGING_DIR}" 2>/dev/null || true
    fi
fi

# 创建指向 /Applications 的快捷方式，方便用户拖拽安装
ln -s /Applications "${STAGING_DIR}/Applications"

# 5. 生成 UDZO 压缩 DMG
echo "💿 正在打包生成 DMG 磁盘映像..."
rm -f "${DMG_PATH}"

hdiutil create \
    -volname "${VOL_NAME}" \
    -srcfolder "${STAGING_DIR}" \
    -ov \
    -format UDZO \
    "${DMG_PATH}"

# 6. 清理临时暂存目录
rm -rf "${STAGING_DIR}"

# 7. 计算校验和与体积
DMG_SIZE="$(du -sh "${DMG_PATH}" | cut -f1)"
DMG_SHA256="$(shasum -a 256 "${DMG_PATH}" | awk '{print $1}')"

echo "=========================================="
echo "🎉 打包完成！"
echo "产物路径: ${DMG_PATH}"
echo "文件大小: ${DMG_SIZE}"
echo "SHA256:  ${DMG_SHA256}"
echo "=========================================="
