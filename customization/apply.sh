#!/bin/bash
# Kullanım: apply.sh <kaynak_kök_dizini>
# Örn: apply.sh /mnt/android/lineage

set -e
SRC="$1"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEVICE_TREE="$SRC/device/samsung/hlte"

echo "==> Özelleştirmeler uygulanıyor: $DEVICE_TREE"

# -------------------------------------------------------------------
# 1) BOOT ANİMASYONU - device tree'nin altına koyup makefile'a ekliyoruz
# -------------------------------------------------------------------
if [ -f "$SCRIPT_DIR/bootanimation.zip" ]; then
  mkdir -p "$DEVICE_TREE/rootdir/system/media"
  cp "$SCRIPT_DIR/bootanimation.zip" "$DEVICE_TREE/rootdir/system/media/bootanimation.zip"

  # device.mk içine ekle (eğer satır yoksa)
  DEVICE_MK="$DEVICE_TREE/device.mk"
  if ! grep -q "bootanimation.zip" "$DEVICE_MK" 2>/dev/null; then
    cat >> "$DEVICE_MK" <<'EOF'

# Custom boot animation
PRODUCT_COPY_FILES += \
    device/samsung/hlte/rootdir/system/media/bootanimation.zip:system/media/bootanimation.zip
EOF
  fi
fi

# -------------------------------------------------------------------
# 2) VARSAYILAN DUVAR KAĞIDI
# -------------------------------------------------------------------
if [ -f "$SCRIPT_DIR/wallpaper.png" ]; then
  WALLPAPER_DIR="$SRC/vendor/lineage/overlay/common/frameworks/base/core/res/res/drawable-nodpi"
  mkdir -p "$WALLPAPER_DIR"
  cp "$SCRIPT_DIR/wallpaper.png" "$WALLPAPER_DIR/default_wallpaper.png"
fi

# -------------------------------------------------------------------
# 3) BUILD.PROP ÖZELLİKLERİ (cihaz adı, DPI vb.)
#    device.mk içinde PRODUCT_PROPERTY_OVERRIDES bölümüne ekleriz
# -------------------------------------------------------------------
DEVICE_MK="$DEVICE_TREE/device.mk"
if ! grep -q "# CUSTOM_PROPS" "$DEVICE_MK" 2>/dev/null; then
  cat >> "$DEVICE_MK" <<'EOF'

# CUSTOM_PROPS
PRODUCT_PROPERTY_OVERRIDES += \
    ro.sf.lcd_density=320 \
    ro.product.model=SM-N9005-Custom \
    persist.sys.disable_rescue=true \
    debug.sf.nobootanimation=0
EOF
fi

# -------------------------------------------------------------------
# 4) ÖN YÜKLÜ UYGULAMALAR - prebuilt-apps/ klasöründeki apk'ları ekle
#    Her apk için basit bir Android.mk üretir, sonra device.mk'a paket adını ekler
# -------------------------------------------------------------------
PREBUILT_DIR="$SCRIPT_DIR/prebuilt-apps"
PACKAGES_MK="$DEVICE_TREE/packages.mk"
touch "$PACKAGES_MK"

if [ -d "$PREBUILT_DIR" ]; then
  for apk in "$PREBUILT_DIR"/*.apk; do
    [ -e "$apk" ] || continue
    name=$(basename "$apk" .apk)
    dest_dir="$SRC/vendor/lineage/prebuilt/common/apps/$name"
    mkdir -p "$dest_dir"
    cp "$apk" "$dest_dir/$name.apk"

    # Bu uygulama için minimal Android.mk
    cat > "$dest_dir/Android.mk" <<EOF
LOCAL_PATH := \$(call my-dir)
include \$(CLEAR_VARS)
LOCAL_MODULE := $name
LOCAL_MODULE_CLASS := APPS
LOCAL_MODULE_TAGS := optional
LOCAL_CERTIFICATE := platform
LOCAL_SRC_FILES := \$(LOCAL_MODULE).apk
LOCAL_MODULE_SUFFIX := \$(COMMON_ANDROID_PACKAGE_SUFFIX)
LOCAL_PRIVILEGED_MODULE := false
include \$(BUILD_PREBUILT)
EOF

    if ! grep -q "PRODUCT_PACKAGES += $name" "$PACKAGES_MK"; then
      echo "PRODUCT_PACKAGES += $name" >> "$PACKAGES_MK"
    fi
  done

  # packages.mk'ı device.mk'tan include et
  if ! grep -q "include .*packages.mk" "$DEVICE_MK" 2>/dev/null; then
    echo "" >> "$DEVICE_MK"
    echo '$(call inherit-product, device/samsung/hlte/packages.mk)' >> "$DEVICE_MK"
  fi
fi

echo "==> Özelleştirmeler tamamlandı."
