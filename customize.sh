#!/system/bin/sh
ui_print "- Blue Whale 6.0.6"
set_perm $MODPATH/system/bin/BlueWhale 0 0 0755
set_perm $MODPATH/service.sh 0 0 0755
set_perm $MODPATH/action.sh 0 0 0755
ui_print "- Done"
