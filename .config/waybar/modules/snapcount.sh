#!/bin/bash
snapcount=$(zfs list -t snapshot | grep $(date +%Y-%m-%d) | wc -l)
echo "{\"text\":\"${snapcount}\"}"
