#!/bin/bash

# Definiamo il dispositivo della partizione cifrata
DEVICE="/dev/mapper/calamares_crypt"

# Otteniamo la dimensione totale della partizione
total_size=$(sudo blockdev --getsize64 /dev/mmcblk2p2)

# Otteniamo la dimensione utilizzata del file system
used_size=$(df --output=used "$DEVICE" | tail -n 1)

# Otteniamo la dimensione totale del file system
total_fs_size=$(df --output=size "$DEVICE" | tail -n 1)

# Confrontiamo se la dimensione utilizzata è uguale alla dimensione totale
if [[ $used_size -eq $total_fs_size ]]; then
    echo "Il file system sta utilizzando tutto lo spazio disponibile: $total_fs_size bytes"
else
    echo "Il file system NON sta utilizzando tutto lo spazio disponibile."
    echo "Spazio totale della partizione: $total_size bytes"
    echo "Spazio utilizzato dal file system: $used_size bytes"
    echo "Spazio disponibile nel file system: $((total_fs_size - used_size)) bytes"
fi

