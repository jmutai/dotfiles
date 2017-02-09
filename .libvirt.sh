#!/bin/bash
# Script to manage vm nodes - Including cluster management

main () {
    case "$1" in
       "start") start;;
       "reboot") reboot;;
       "shutdown") shutdown;;
       "poweroff") poweroff;;
       "destroy") destroy;;
       *) 
           usage
           exit 2
           ;;
   esac
}

usage () {
    echo ""
    echo "USAGE: ${0##*/} <command>"
    echo "Commands:"
    echo -e "\tstart\t\tstart the QEMU/KVM nodes"
    echo -e "\treboot\t\treboot the QEMU/KVM nodes"
    echo -e "\tshutdown\tshutdown the QEMU/KVM nodes"
    echo -e "\tpoweroff\tpoweroff the QEMU/KVM nodes"
    echo -e "\tdestroy\t\tdestroy the QEMU/KVM nodes"
}


start () {
    echo ""
    echo -en "Enter nodes: "
    read nodes
    for node in ${nodes[@]}; do
        sudo virsh start $node
    done
}

reboot () {
    echo ""
    echo -en "Enter nodes: "
    read nodes
    for node in ${nodes[@]}; do
        sudo virsh reboot $node
    done
}

shutdown () {
    echo ""
    echo -en "Enter nodes: "
    read nodes
    for node in ${nodes[@]}; do
        sudo virsh shutdown $node
    done
}

poweroff () {
    echo ""
    echo -en "Enter nodes: "
    read nodes
    for node in ${nodes[@]}; do
        sudo virsh destroy $node
    done
}

destroy () {
    echo ""
    echo -en "Enter nodes: "
    for node in ${nodes[@]}; do
        sudo virsh destroy $node
    done
    for node in ${nodes[@]}; do
        sudo virsh undefine $node
    done
    sudo virsh pool-refresh default
    for node in ${nodes[@]}; do
        sudo virsh vol-delete --pool default $node.qcow2
    done
}

main $@
