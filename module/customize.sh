#!/system/bin/sh
MODDIR=${0%/*}

ui_print ""
ui_print "🐋 Blue Whale v2.0"
ui_print "===================="
ui_print ""

# Copy binary to system
if [ -f "$MODDIR/bin/bluewhale_d" ]; then
    cp -f "$MODDIR/bin/bluewhale_d" /system/bin/bluewhale_d
    chmod 755 /system/bin/bluewhale_d
    ui_print "✓ Binary installed"
else
    ui_print "⚠ Binary not found (will add later)"
fi

# Set webroot permissions
chmod -R 755 "$MODDIR/webroot"
ui_print "✓ WebUI ready"

# Create working directories
mkdir -p /data/local/tmp/bluewhale
chmod 755 /data/local/tmp/bluewhale

ui_print ""
ui_print "✓ Installation complete"
ui_print "  Reboot to activate"
ui_print "  WebUI: http://127.0.0.1:8080"
ui_print ""