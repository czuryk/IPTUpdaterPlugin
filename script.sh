#!/system/bin/sh

# Path to the WifiConfigStore.xml file
WIFI_CONFIG_FILE="/data/misc/apexdata/com.android.wifi/WifiConfigStore.xml"

config_file="/data/local/tmp/ipt_config.sh"

LOG_FILE="/data/local/tmp/ipt_updater.log"

log_message() {
    local LOG_TYPE=$1
    local MESSAGE=$2
    local TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")
    echo "$TIMESTAMP [$LOG_TYPE] $MESSAGE" >> "$LOG_FILE"
    echo "$TIMESTAMP [$LOG_TYPE] $MESSAGE"
}

write_config() {
    local SSID=$1
    local PROXY_HOST=$2
    local PROXY_PORT=$3
    echo "CFG_SSID='"$SSID"'" > "$config_file"
    echo "CFG_PROXY_HOST="$PROXY_HOST"" >> "$config_file"
    echo "CFG_PROXY_PORT="$PROXY_PORT"" >> "$config_file"
}

write_iptables() {
    local SSID=$1
    local PROXY_HOST=$2
    local PROXY_PORT=$3

    # Flush records
    iptables -F -t nat

    # Add new records if it not empty
    if [ "$PROXY_HOST" != "" ] && [ "$PROXY_PORT" != "" ]; then
       iptables -t nat -A OUTPUT -p tcp --dport 80 -j DNAT --to-destination $PROXY_HOST:$PROXY_PORT
       iptables -t nat -A OUTPUT -p tcp --dport 443 -j DNAT --to-destination $PROXY_HOST:$PROXY_PORT
       log_message "INFO" "iptables entries added."
    else
       log_message "INFO" "No proxy. iptables entries removed."
    fi
}

# Run the dumpsys command and filter the output
SSID_LINE=$(dumpsys wifi | grep -E 'iface=wlan0,ssid=')

# Extract the SSID using shell parameter expansion
SSID=$(echo "$SSID_LINE" | sed -n 's/.*ssid="\([^"]*\)".*/\1/p')

# Escape special characters in SSID for regex compatibility
ESCAPED_SSID=$(echo "$SSID" | sed 's/[][(){}.^$*+?|\\]/\\&/g')

# No SSID found. Wi-Fi is not connected or configuration problem?
if [ "$SSID" == "" ]; then
  log_message "ERROR" "No Wifi connected or config problem."
  exit 1
fi

if [ -f "$WIFI_CONFIG_FILE" ]; then
   # Extract the <Network> block containing the target SSID
   NETWORK_BLOCK=$(awk -v RS="</Network>" "/<string name=\"SSID\">&quot;$ESCAPED_SSID&quot;<\/string>/" "$WIFI_CONFIG_FILE")

   # Extract ProxyHost and ProxyPort values from the Network block
   PROXY_HOST=$(echo "$NETWORK_BLOCK" | sed -n 's/.*<string name="ProxyHost">\([^<]*\)<\/string>.*/\1/p')
   PROXY_PORT=$(echo "$NETWORK_BLOCK" | sed -n 's/.*<int name="ProxyPort" value="\([^"]*\)" \/>.*/\1/p')
else
   log_message "ERROR" "Wifi config file $WIFI_CONFIG_FILE not found."
  exit 1
fi

# Output the results
### log_message "INFO" "SSID: $SSID, Proxy: $PROXY_HOST:$PROXY_PORT."

if [ -f "$config_file" ]; then
  source "$config_file"
  
  #### log_message "INFO" "Config: CFG_SSID = $CFG_SSID, CFG_PROXY_HOST = $CFG_PROXY_HOST, CFG_PROXY_PORT = $CFG_PROXY_PORT"
 
  if [ "$SSID" = "$CFG_SSID" ] && [ "$PROXY_HOST" = "$CFG_PROXY_HOST" ] && [ "$PROXY_PORT" = "$CFG_PROXY_PORT" ]; then
    #### log_message "INFO" "Proxy data has not changed. Exit script."
    exit 0    
  else
    log_message "INFO" "Proxy data has changed. Saving new state and update iptables."
    write_config "$SSID" "$PROXY_HOST" "$PROXY_PORT"
    write_iptables "$SSID" "$PROXY_HOST" "$PROXY_PORT"
    exit 0
  fi

else
    log_message "INFO" "No config. Force crate config and update iptables."
    write_config "$SSID" "$PROXY_HOST" "$PROXY_PORT"
    write_iptables "$SSID" "$PROXY_HOST" "$PROXY_PORT"
    exit 0
fi
