#!/usr/bin/env bash

# Bash script to manage networking using nmcli
# Install network manager and enable it to run on boot
# By NerdJK23
# web: www.computingforgeeks.com
# email: kiplangatmtai@gmail.com, josepy@computingforgeeks.com

set -euo pipefail

# Function to connect to Wifi AP
wifi_connect () {
  echo -e " \e[01;31m[!]\e[00m Checking available wifi AP:"
  echo ""
  nmcli device wifi rescan
  sleep 10
  dev_list=`nmcli dev wifi list`
  echo "$dev_list"
  echo ""
  read -p "Enter <SSID|BSSID> name: " wifi_name
  unset wifi_password
  prompt="Enter  AP Password: "

  while IFS= read -p "$prompt" -r -s -n 1 char
do
    if [[ $char == $'\0' ]];     then
        break
    fi
    if [[ $char == $'\177' ]];  then
        prompt=$'\b \b'
        wifi_password="${wifi_password%?}"
    else
        prompt='*'
        wifi_password+="$char"
    fi
done
  echo ""
  echo "Connecting to wifi....."
  echo ""
  echo "$wifi_name"
  #nmcli device wifi connect \$wifi_name\ password $wifi_password
  nmcli dev wifi connect "$wifi_name" password $wifi_password
  echo ""
  if [[ "$?" -eq "0" ]]; then
    echo -e "Connection was successful\n"
    echo ""
    echo "Active Wifi connections are :"
    echo ""
    con_status=$(nmcli con show --active | grep 802-11 | awk  '{ print $1,$2,$3 }')
    echo "$con_status"
    echo ""
    read -p "Test internet Connection(N/Y): " internet_check
    case $internet_check in
      Y|y )
      echo ""
      ping -c3 8.8.8.8
      echo ""
        ;;
      N|n )
      echo ""
      echo "Okay!.."
          ;;
    esac
  else
    echo ""
    echo "Too bad!, connection failed."
    exit 1
  fi
  }

# Function to delete old Wifi connections
delete_old_wifi () {
read -p "Are you sure you want to delete old Wifi connections(Y/N): " selection
if [[ $selection == "Y" || $selection == "y" ]]; then
  echo ""
  echo "Deleting connections..."
  echo""
  for  UUID in `nmcli con sho | grep 802-11 |grep -o\
 "[0-9a-f]\{8\}-[0-9a-f]\{4\}-[0-9a-f]\{4\}-[0-9a-f]\{4\}-[0-9a-f]\{12\}"`;
 do
    nmcli con del $UUID
  done
elif [[ $selection == "N" || $selection == "n" ]]; then
  echo ""
  echo "Okay!."
else
  echo ""
  echo "Wrong selection"
  exit 1
fi
  }


create_con (){
    echo ""
    echo -e " Your current connections are: \n"
    nmcli con show
    echo ""
    echo -e " This will create new connection....."
    echo -en " Enter interface type: " 
    read con_type
    echo -en " Enter connection name: " 
    read con_name
    echo -en " Enter interface name: "
    read int_name
    echo -en " Enter ipv4: " 
    read ip_v4
    echo -en " Enter gw v4: " 
    read gw_v4
    echo -e " Adding connections ...... \n"
    nmcli con add type "$con_type" ifname "$int_name" con-name "$con_name" autoconnect yes  ip4 "$ip_v4"  gw4 "$gw_v4" 
    echo ""
    if [[ $? -eq "0" ]]; then
	echo "***** Network connection added successfully ***** "
	echo ""
    else
	echo -e " Failed to create connection!! \n"
	exit 1
    fi
}

mod_con () {
    echo ""
    echo " This will help you modify existing connection..."
    echo ""
    echo -en " Enter interface name/UUID to modify: " 
    read int_name
    echo ""
    echo " Select from below: "
    echo -en "
    \033[1;36m
     1: change ID name
     2: Change interface name
     3: Change connection name

     4: Change ipv4 address
     5: Change DNS address
     6: Change ipv4 gateway address

     7: Add additional ipv4 
     8: Add additional gw4 
     9: Add additional dns 
     \033[m
    "
    echo ""
    echo -en " Enter Your selection: "
    read selection
}


# Main
clear
echo ""
echo -e "Press : \n"
echo -e " 
\033[31m

****** CHECK     ********

1: Check all connections 
2: Check Atcive Connections

*******  WI-FI   ********

3: Connect to Wifi AP 
4: Delete old wifi connections 

******* Ethernet *******

5: Create new connection 
6: Modify existing connection 
\033[m
"
read -p "Enter your selection: " selection
case $selection in
  4 )
  echo ""
  delete_old_wifi
    ;;
  3 )
  echo ""
  wifi_connect
    ;;

  1 )
  echo ""
  nmcli con show 
    ;;
  2 )
  echo ""
  nmcli con show --active
    ;;
  5 )
  echo ""
  create_con
    ;;
  6 )
  echo ""
  mod_con
    ;;
esac
exit 0
