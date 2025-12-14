#!/bin/bash

# Lista svih VM-ova
VMS=("manage.test.lab" "host1.test.lab" "host2.test.lab")

usage() {
    echo "Usage: $0 {start|stop|reset|status} [vm_name|all]"
    exit 1
}

# Provjera argumenata
if [ $# -lt 1 ]; then
    usage
fi

ACTION=$1
TARGET=$2

# Funkcija za pokretanje VM
start_vm() {
    virsh start "$1"
}

# Funkcija za zaustavljanje VM
stop_vm() {
    virsh shutdown "$1"
}

# Funkcija za reset VM
reset_vm() {
    virsh reset "$1"
}

# Funkcija za status VM
status_vm() {
    virsh dominfo "$1"
}

# Ako je target "all", radi na svim VM-ovima
if [ "$TARGET" == "all" ] || [ -z "$TARGET" ]; then
    TARGETS=("${VMS[@]}")
else
    TARGETS=("$TARGET")
fi

for vm in "${TARGETS[@]}"; do
    case $ACTION in
        start)
            echo "Starting $vm..."
            start_vm "$vm"
            ;;
        stop)
            echo "Stopping $vm..."
            stop_vm "$vm"
            ;;
        reset)
            echo "Resetting $vm..."
            reset_vm "$vm"
            ;;
        status)
            echo "Status of $vm:"
            status_vm "$vm"
            ;;
        *)
            usage
            ;;
    esac
done
