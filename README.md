# IP Tables Updater Plugin
The IPTUpdaterPlugin is a Magisk module that automatically adds iptables entries based on the proxy configured in the Wi-Fi network settings. These entries are necessary for successfully intercepting traffic in Flutter applications, as Flutter does not use the Wi-Fi proxy configuration.

This plugin runs every 10 seconds and monitors changes in Wi-Fi settings. When there are changes in the proxy settings, it adds or removes iptables entries accordingly.

Tested on physical device Samsung S24 Ultra with Android 14.

# How to
1) Root your Android device using using Magisk.
2) Complete any pending updates for Magisk, and make sure you have the latest Magisk version.
3) Install your custom CA certificate under user certificate store (you can use Cert-Fixer to place them into system storage)
4) Download IPTUpdaterPlugin.zip and install Plugin module in Magisk.
5) Reboot.
The plugin will monitor Wi-Fi configuration changes and alter ip tables.

# How to check script running
Use the adb shell command to navigate to the /data/local/tmp/ipt_updater.log file. This file contains information about the plugin status. Try updating the proxy and observe any changes. You can also run the command **iptables -L -t nat** to retrieve all entries and ensure that the iptables configuration is current.

# Description
Due to the fact that for an unknown reason, the ProxyDroid app does not effectively modify the iptables, resulting in the inability to intercept Flutter traffic on Android 14.
Manually changing the data in iptables is not convenient, especially considering the frequent need for proxy changing.
This script provides an easy and seamless way to switch to another network and immediately apply the required proxy without the need for additional actions.
Even if ProxyDroid is working well, this plugin is focused on greater automation. It removes the need for any additional steps to start intercepting the traffic of Flutter applications.

# Attention
This script is provided "as is" without warranties of any kind. By using this script, you acknowledge that you do so at your own risk.
