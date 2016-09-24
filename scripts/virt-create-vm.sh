#!/bin/bash -
clear
echo -e "
\033[31m################################################################\033[m
\033[1;36m
#          FILE: virt-create-vm.sh
#
#         USAGE: ./virt-create-vm.sh
#
#   DESCRIPTION: Bash script to make vm creation with virt-install interactive
#
#  REQUIREMENTS: Bash shell
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: NerdJK23 (Nd), geekstuff15@gmail.com,
#  ORGANIZATION: Computingforgeeks
#       CREATED: 08/09/2016 12:29
#      REVISION: version 1.0
\033[m

\033[31m################################################################\033[m"

#----------------------------------------------------------#
#                   Check if the user is root              #
#----------------------------------------------------------#

check_root () {
  if [[ "$EUID" -ne '0' ]]; then
    echo ""
    echo -e " This script should be run as root user!"
    exit 1
  fi
}


set -o nounset

install_script(){
  # Check if script is installed
  if [[ ! -e "/usr/bin/virt-create-vm" ]]; then
    echo "Script is not installed, do you want to install it (Y/N)"
    read install
    if [[ $install == "Y" || $install == "y" ]]; then
      sudo cp -v $0 /usr/bin/virt-create-vm
      sudo chmod +x /usr/bin/virt-create-vm
      echo "Script should be installed now. Launching it!"
      sleep 2
      sudo virt-create-vm
      exit 1
    else
      echo -e "\e[32m[-] It's Ok,maybe later !\e[0m"
    fi
  else
    echo ""
    echo -e "Script is already installed, good!\n"
    echo -e "\e[1;31m-  Now reinstalling... \e[00m"
    echo ""
    sudo cp -v $0 /usr/bin/virt-create-vm
    sleep 1
  fi
}


#----------------------------------------------------------#
#                   Default values                      #
#----------------------------------------------------------#
# grep MemTotal /proc/meminfo | cut -d: -f2 | tr -d " " | tr -d "kB"
# red='\e[1;31m'
ram_size=""
cpu_cores=""
cpu_count=`grep -c ^processor /proc/cpuinfo`
total_cpu="$cpu_count cores"
mem_bytes=$(awk '{ print $2 }' /proc/meminfo |head -n1)
mem_gb="$(($mem_bytes/1024/1024)) GB"
total_ram="$mem_gb"
#media_selection=""

#----------------------------------------------------------#
#  Function to prompt user for answers                     #
#----------------------------------------------------------#

function answers {
  echo ""
  # enter vm name name
  echo -e "\e[1;31m- Enter the name:  \e[00m \n"
  read -p "vm name:    " selection

# Check if vm entered already exist for default vm
virsh list --all | grep $selection > /dev/null 2>&1
if [[ $? -eq '0' ]]; then
  echo ""
  echo " vm name already exist:"
  exit 1
else
vm_name=$selection
fi

echo ""
read -p "Enter VM description: e.g  My RHEL 7 : " vm_description
echo ""

# Enter ram information
while [[ ! $ram_size =~ ^[0-9]+$ ]]; do
  echo ""
  echo -e "You have total ram of: \e[1;31m $total_ram \e[00m \n"
  echo -e "Please enter Ram value in integer format, e.g \e[1;31m 1024 for 1GB ram:\e[00m \n"
  read -p "Ram size: " ram_size
done

echo ""
echo -e "Yout total number of cpu cores is : \e[1;31m $total_cpu \e[00m \n"
read -p "Enter the number of cpu cores guest will use: " cpu_cores

# Cpu must be an integer value
while [[ ! $cpu_cores =~ ^[0-9]+$ ]]; do
  echo ""
  echo -e "Please enter number of vcpus (numeric): "
  read -p "Virtual cpu cores: " cpu_cores
done

cpu_value=$(($cpu_cores))
while [[ "$cpu_cores" -gt "$cpu_count" ]]; do
  echo ""
  echo -e "You specified number higher than total number of cores \n"
  echo -e "Enter value less than \e[1;31m $cpu_count \e[00m \n"
  read -p "Number of vcpus: " cpu_cores
done

echo ""
read -p "Do you want to specify bridge name to use? (Y/N): " selection
case $selection in
  Y|y)
  echo ""
  echo -e "Enter bridge name (e.g: \e[1;31m br0 \e[00m \n"
  read -p "Brige name: " bridge_name

while [[ ! `brctl show | grep ^$bridge_name`  ]]; do
  echo ""
  echo -e " Bridge name you specified doesn'e exist!."
  echo ""
  echo -e "Use\e[1;31m  brctl show \e[00m to list configured bridges \n"
  read -p "Enter valid bridge interface: " bridge_name
done

  echo ""
  bridge_interface="bridge=$bridge_name"
      ;;
  N|n )
      echo ""
      bridge_interface="network=default"
                ;;
esac

# Disk path to use
echo -e "Virtual disk will be created in \e[1;31m /var/lib/libvirt/images \e[00m \n "
read -p "Enter disk name to create: " disk_name
echo ""
read -p "Enter disk size to create, it's in GB by default( e.g 10 for 10GB ) : " disk_size
echo ""
read -p "Enter image format to use (img/qcow2): " image_format
echo ""

# VNC selection
echo -e "\e[1;31m Select whether to use vnc or not \e[00m \n"
read -p "Do you want to use graphical installation?, if yes, you should have vnc installed. (Y/N): " selection
if [[ $selection == "Y" || $selection == "y" ]]; then
  set_graphics="vnc"
elif [[ $selection == "N" || $selection == "n" ]]; then
  set_graphics="none"
else
  echo "Wrong selection!"
  exit 1
fi

# Specify installation media
echo ""
echo -e " Specify medium from which installation is to be done: \n"
echo -e "\e[1;31m Enter installation url e.g ftp://192.168.122.1/rhel7:  \e[00m \n"
read  -p " Enter your selection: " media_selection

# Select OS variant
echo ""
echo -e "\e[1;31m Select OS Type, Press 1 for Linux, 2 for Windows, 3 for Unix :\e[00m \n "
read -p " Enter selection: " selection
case $selection in
  1)
  os_type="linux"
    ;;
  2)
  os_type="windows"
    ;;
  3)
  os_type="unix"
    ;;
  *)
  os_type="generic"
    ;;
esac


# Select OS variant
echo ""
echo -e " Enter OS variant to use: e.g \e[1;31m rhel7\e[00m \n"
echo -e " Run \e[1;31m virt-install --os-variant list\e[00m  to see full list:  \n"
read -p " Enter OS variant name: " os_variant

# Kickstart
echo ""
read -p " Do you have Kickstart file to use? (Y/N): " selection
if [[ $selection == Y || $selection == y ]]; then
  echo ""
  echo -e -n  "Enter Kickstart location: e.g \e[1;31m http://192.168.122.1/ks.cfg \e[00m : "
  read kickstart
  kickstart_file="ks=$kickstart"
  echo "$kickstart_file"
elif [[ $selection == N || $selection == n ]]; then
  echo ""
  kickstart_file=""
else
  echo ""
  echo "Invalid selection: "
  exit 1
fi
}

function installation {
  echo -e "**** Beginning installation ***\n"
  echo ""
    virt-install  --connect=qemu:///system \
    --name $vm_name \
    --description \$vm_description\ \
    --accelerate \
    --graphics $set_graphics \
    --location $media_selection \
    --network bridge:virbr0 \
    --network $bridge_interface \
    --ram $ram_size \
    --disk path=/var/lib/libvirt/images/$disk_name.$image_format,format=$image_format,size=$disk_size \
    --vcpus $cpu_cores \
    --os-type $os_type \
    --os-variant $os_variant \
    --extra-args 'console=tty0 console=ttyS0,115200 "$kickstart_file"'
}

echo ""
read -p " Do you want to start installation (y/n): " selection
case $selection in
  Y|y)
  check_root
  install_script
  answers
  installation
    ;;
  N|n)
  echo ""
  echo " Ok. Maybe next time!"
  exit 1
  ;;
  *)
  echo "Invalid selection!!.."
  exit 1
  ;;
esac
