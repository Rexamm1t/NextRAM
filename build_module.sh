#!/system/bin/sh
set -e
cd "$(dirname "$0")"
make clean
make -j$(nproc)
if [ ! -f libnextram-zramlib.so ] || [ ! -f nextram-zram-ctl ] || [ ! -f tools/nextramaicf ]; then
    echo "Ошибка сборки!"
    exit 1
fi
mkdir -p bin/lib
mv libnextram-zramlib.so bin/lib/
mv nextram-zram-ctl bin/
mv tools/nextramaicf bin/
rm -rf tools
if [ ! -f module.prop ]; then
    echo "module.prop не найден!"
    exit 1
fi
MOD_ID=$(grep '^modname=' module.prop | cut -d= -f2 | tr -d ' ')
MOD_VER=$(grep '^version=' module.prop | cut -d= -f2 | tr -d ' ')
if [ -z "$MOD_ID" ] || [ -z "$MOD_VER" ]; then
    echo "Не удалось получить id или version из module.prop"
    exit 1
fi
ARCHIVE_NAME="NextRAM-${MOD_ID}-v${MOD_VER}.zip"
TEMP_DIR="NextRAM-temp"
mkdir -p "$TEMP_DIR"
tar cf - --exclude="$TEMP_DIR" . | (cd "$TEMP_DIR" && tar xf -)
rm -rf "$TEMP_DIR/src" \
       "$TEMP_DIR/source" \
       "$TEMP_DIR/tools" \
       "$TEMP_DIR/Makefile" \
       "$TEMP_DIR/build_module.sh" \
       "$TEMP_DIR/NextRAM-temp" \
       "$TEMP_DIR"/*.o \
       "$TEMP_DIR"/*.so \
       "$TEMP_DIR"/nextram-zram-ctl \
       "$TEMP_DIR"/nextramaicf \
       "$TEMP_DIR"/*.zip 2>/dev/null || true
cd "$TEMP_DIR"
zip -r -0 "../$ARCHIVE_NAME" .
cd ..
rm -rf "$TEMP_DIR"
make clean
echo "Готово: $ARCHIVE_NAME"
