#!/bin/bash

# url of thwe website with image links
url="https://images.mobian-project.org/pinephonepro/installer/weekly/"

# Recover the list of files from the website
# wget -q is quiet option, -O output file but - means the output file content is tranfered to the pipe |
# grep -o will print just the searche pattern -P is pearl regex and \d{8} means eight numbers
# sort -r the first line will be the latest
# head -n 1 shows just the first line
latest_file=$(wget -q -O - "$url" | grep -oP 'mobian-installer-rockchip-phosh-\d{8}.img.xz' | sort -r | head -n 1)

# Verifica se è stato trovato un file
if [ -n "$latest_file" ]; then
    echo "File più recente trovato: $latest_file"
    
    # Scarica il file
    wget --progress=dot "$url$latest_file" -O "/tmp/$latest_file"
    echo "Download completato: $latest_file"
else
    echo "Nessun file trovato."
fi
