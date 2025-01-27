#!/system/bin/sh
# Magisk Service Script

while true; do
    sh /data/adb/modules/ipt_updater_script_runner/script.sh
    sleep 10
done
