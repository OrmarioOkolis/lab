#!/bin/bash

# Lista svih VM-ova
VMS=("manage.test.lab" "host1.test.lab" "host2.test.lab")

usage() {
    echo "Usage: $0 {start|stop|reset|status} [vm_name|all]"
    exit 1
}

if [ $# -lt 1 ]; then
    usage
fi

ACTION=$1
TARGET=$2

# Odredi ciljne VM-ove
if [ "$TARGET" == "all" ] || [ -z "$TARGET" ]; then
    TARGETS=("${VMS[@]}")
else
    TARGETS=("$TARGET")
fi

# Funkcije
start_vm() {
    echo "Starting $1..."
    virsh start "$1"
}

stop_vm() {
    echo "Stopping $1..."
    virsh shutdown "$1"
}

status_vm() {
    echo "Status of $1:"
    virsh dominfo "$1"
}

reset_vm() {
    local vm=$1
    # Provjeri postoji li snapshot 'clean'
    if virsh snapshot-list "$vm" | grep -q "^clean"; then
        echo "Resetting $vm to snapshot 'clean'..."
        virsh shutdown "$vm"
        # Sačekaj dok se VM ne ugasi
        while [ "$(virsh domstate "$vm")" != "shut off" ]; do
            sleep 1
        done
        virsh revert "$vm" clean
        virsh start "$vm"
    else
        echo "Error: Snapshot 'clean' does not exist for $vm!"
    fi
}

# Glavna logika
for vm in "${TARGETS[@]}"; do
    case $ACTION in
        start)
            start_vm "$vm"
            ;;
        stop)
            stop_vm "$vm"
            ;;
        reset)
            reset_vm "$vm"
            ;;
        status)
            status_vm "$vm"
            ;;
        *)
            usage
            ;;
    esac
done
