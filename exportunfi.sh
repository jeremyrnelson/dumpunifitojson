#!/bin/bash

OUTPUTDIR=~/unifi
mkdir -p "$OUTPUTDIR"

which mongoexport || echo "Need to run as root: apt install mongo-tools"
which jq || echo "Need to run as root: apt install jq"

#excluded rogue and event - too huge and unnecessary - stat_archive will be handled below
for table in account admin alarm broadcastgroup dashboard device dhcpoption dpiapp dpigroup dynamicdns firewallgroup firewallrule guest heatmap heatmappoint hotspot2conf hotspotop hotspotpackage map mediafile networkconf payment portalfile portconf portforward privilege radiusprofile rogueknown routing scheduletask setting site stat system.indexes tag task user usergroup verification virtualdevice voucher wall wlanconf wlangroup; do echo "Exporting $table"; ( mongoexport --quiet --port 27117 -d ace -c $table --jsonArray |jq '' > "$OUTPUTDIR/$table" ); done

#exporting just the last 48 hours of stat_archive
for table in stat_archive; do echo "Exporting $table"; ( mongoexport --quiet  --query "{datetime: { \$gte: { \"\$date\": \"$(date -u --date="NOW - 48 hours" "+%Y-%m-%dT%H:%M:%SZ")\" } }}" --port 27117 -d ace_stat -c stat_archive --jsonArray |jq '' > "$OUTPUTDIR/$table" ); done
