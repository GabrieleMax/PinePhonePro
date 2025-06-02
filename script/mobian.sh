#! /bin/bash

mob_keyring="https://salsa.debian.org/Mobian-team/mobian-keyring/-/raw/509d5fae1ac9bb1aa8e9d9bd446dbac3f9588c49/mobian-archive-keyring.gpg"                                                  
mob_testing_img_url="https://images.mobian.org/pinephonepro/weekly/"
mob_testing_install_url="https://images.mobian.org/pinephonepro/installer/weekly/"

# Retrieve the list of downloadable files from the websites, sort them, and take the latest one
mob_testing_img_phosh=$(curl -s "$mob_testing_img_url" | grep -oP '(?<=href=")mobian-rockchip-phosh-\d{8}.img.xz' | sort -r | head -n 1)
mob_testing_install_phosh=$(curl -s "$mob_testing_install_url" | grep -oP '(?<=href=")mobian-installer-rockchip-phosh-\d{8}.img.xz' | sort -r | head -n 1)
mob_testing_img_plasma=$(curl -s "$mob_testing_img_url" | grep -oP '(?<=href=")mobian-rockchip-plasma-mobile-\d{8}\.img\.xz' | sort -r | head -n 1)
mob_testing_install_plasma=$(curl -s "$mob_testing_install_url" | grep -oP '(?<=href=")mobian-installer-rockchip-plasma-mobile-\d{8}\.img\.xz' | sort -r | head -n 1)

# Function to download Mobian testing image with Phosh without installer for PinePhone Pro                                                                                                                     
mob_img_testing_img_phosh() {
    if [ -z "$mob_testing_img_phosh" ]; then
        echo "The variable mob_testing_img_posh is empty."
        return 1  # Termina solo la funzione, lo script continua
    fi  

    if [ -f "/$DOWNLOAD_DIR/$mob_testing_img_phosh" ]; then
        echo "File already exists in /$DOWNLOAD_DIR/. Skipping download."
    else
        echo "Latest file found: $mob_testing_img_phosh"
        wget --progress=dot -c -d --timeout=60 --tries=3 -O "/$DOWNLOAD_DIR/$mob_testing_img_phosh" "$mob_testing_img_url$mob_testing_img_phosh"

        if [ $? -eq 0 ]; then
            echo "Download complete: $mob_testing_phosh"
        else
            echo "Download failed."
            return 1
        fi
    fi
}

# Function to download Mobian testing image with Phosh with installer for PinePhone Pro                                                                                                                     
mob_img_testing_img_phosh() {
    if [ -z "$mob_testing_phosh" ]; then
        echo "The variable mob_testing_posh is empty."
        return 1  # Termina solo la funzione, lo script continua
    fi  

    if [ -f "/$DOWNLOAD_DIR/$mob_testing_phosh" ]; then
        echo "File already exists in /$DOWNLOAD_DIR/. Skipping download."
    else
        echo "Latest file found: $mob_testing_phosh"
        wget --progress=dot -c -d --timeout=60 --tries=3 -O "/$DOWNLOAD_DIR/$mob_testing_phosh" "$mob_testing_img_url$mob_testing_phosh"

        if [ $? -eq 0 ]; then
            echo "Download complete: $mob_testing_phosh"
        else
            echo "Download failed."
            return 1
        fi
    fi
}



# Function to check Mobian testing image with phosh with installer for PinePhone Pro signature
mob_img_testing_phosh_sig() {
    mob_testing_phosh_shasums=$(curl -s "$mob_testing_img_url" | grep -oP 'mobian-rockchip-phosh-\d{8}.sha256sums' | sort -r | head -n 1)
    mob_testing_phosh_shasig=$(curl -s "$mob_testing_img_url" | grep -oP 'mobian-rockchip-phosh-\d{8}.sha256sums.sig' | sort -r | head -n 1)
    mob_testing_phosh_imgbmap=$(curl -s "$mob_testing_img_url" | grep -oP 'mobian-rockchip-phosh-\d{8}.img.bmap' | sort -r | head -n 1)

    if [ -f /$DOWNLOAD_DIR/$mob_testing_phosh_shasums ] && [ -f /$DOWNLOAD_DIR/$mob_testing_phosh_shasig ] && [ -f /$DOWNLOAD_DIR/$mob_testing_phosh_imgbmap ]; then
      echo "Signature files already available and I don't download them."
    else
      echo "I'm going to download signature files."
    wget -q -P /$DOWNLOAD_DIR "$mob_testing_img_url$mob_testing_phosh_shasums"
    wget -q -P /$DOWNLOAD_DIR "$mob_testing_img_url$mob_testing_phosh_shasig"
    wget -q -P /$DOWNLOAD_DIR "$mob_testing_img_url$mob_testing_phosh_imgbmap"
    fi

# GPG download and import key
if [ -z "$mob_keyring" ]; then
    echo "Debian keyring variable URL not available"
    exit 1
  else
    if [ ! -f "/$DOWNLOAD_DIR/mobian-archive-keyring.gpg" ]; then
      echo "I'm going to download Debian keyring"
      wget -q -P /$DOWNLOAD_DIR "$mob_keyring"
    #gpg --import mobian-archive-keyring.gpg
    #gpg --list-keys --with-colons | grep "$(gpg --with-colons --import-options show-only --import mobian-archive-keyring.gpg | grep '^fpr' | cut -d: -f10)"
      else
        echo "Debian keyring already present"
    fi
    # GPG check key
    if gpg --verify "/$DOWNLOAD_DIR/$mob_testing_phosh_shasig" >/dev/null 2>&1; then
        echo "Valid GPG signature"
    else
        echo "GPG signature not valid"
        exit 1
    fi
fi

# SHA256SUM check
#( cd /$DOWNLOAD_DIR && sha256sum -c "$mob_testing_plasma_shasums" )
if [ ! -f "/$DOWNLOAD_DIR/$mob_testing_phosh" ]; then
  echo "Image not avalaible"
  exit 1
else
    if ( cd /$DOWNLOAD_DIR && sha256sum -c "$mob_testing_phosh_shasums" ) |  grep -q "OK$"; then
        echo "SHA256SUM verification passed. Renaming file..."

        # Verifica se il file esiste prima di spostarlo
        if [ -f "/$DOWNLOAD_DIR/$mob_testing_phosh" ]; then
            mv "/$DOWNLOAD_DIR/$mob_testing_phosh" "/$DOWNLOAD_DIR/image.xz"

            # Controlla se mv ha avuto successo
            if [ $? -eq 0 ]; then
                echo "File renamed to image.xz"
            else
                echo "Error: Failed to rename the file."
                exit 1
            fi
        else
            echo "File to rename not found in /$DOWNLOAD_DIR."
            exit 1
        fi
    else
        echo "Signature failed: SHA256SUM verification did not pass."
        exit 1
    fi
fi
}





# Function to check Mobian testing image with phosh without installer for PinePhone Pro signature
mob_img_testing_img_phosh_sig() {
    mob_testing_img_phosh_shasums=$(curl -s "$mob_testing_img_url" | grep -oP 'mobian-rockchip-phosh-\d{8}.sha256sums' | sort -r | head -n 1)
    mob_testing_img_phosh_shasig=$(curl -s "$mob_testing_img_url" | grep -oP 'mobian-rockchip-phosh-\d{8}.sha256sums.sig' | sort -r | head -n 1)
    mob_testing_img_phosh_imgbmap=$(curl -s "$mob_testing_img_url" | grep -oP 'mobian-rockchip-phosh-\d{8}.img.bmap' | sort -r | head -n 1)

    if [ -f /$DOWNLOAD_DIR/$mob_testing_phosh_shasums ] && [ -f /$DOWNLOAD_DIR/$mob_testing_phosh_shasig ] && [ -f /$DOWNLOAD_DIR/$mob_testing_phosh_imgbmap ]; then
      echo "Signature files already available and I don't download them."
    else
      echo "I'm going to download signature files."
    wget -q -P /$DOWNLOAD_DIR "$mob_testing_img_url$mob_testing_phosh_shasums"
    wget -q -P /$DOWNLOAD_DIR "$mob_testing_img_url$mob_testing_phosh_shasig"
    wget -q -P /$DOWNLOAD_DIR "$mob_testing_img_url$mob_testing_phosh_imgbmap"
    fi

# GPG download and import key
if [ -z "$mob_keyring" ]; then
    echo "Debian keyring variable URL not available"
    exit 1
  else
    if [ ! -f "/$DOWNLOAD_DIR/mobian-archive-keyring.gpg" ]; then
      echo "I'm going to download Debian keyring"
      wget -q -P /$DOWNLOAD_DIR "$mob_keyring"
    #gpg --import mobian-archive-keyring.gpg
    #gpg --list-keys --with-colons | grep "$(gpg --with-colons --import-options show-only --import mobian-archive-keyring.gpg | grep '^fpr' | cut -d: -f10)"
      else
        echo "Debian keyring already present"
    fi
    # GPG check key
    if gpg --verify "/$DOWNLOAD_DIR/$mob_testing_phosh_shasig" >/dev/null 2>&1; then
        echo "Valid GPG signature"
    else
        echo "GPG signature not valid"
        exit 1
    fi
fi

# SHA256SUM check
#( cd /$DOWNLOAD_DIR && sha256sum -c "$mob_testing_plasma_shasums" )
if [ ! -f "/$DOWNLOAD_DIR/$mob_testing_phosh" ]; then
  echo "Image not avalaible"
  exit 1
else
    if ( cd /$DOWNLOAD_DIR && sha256sum -c "$mob_testing_phosh_shasums" ) |  grep -q "OK$"; then
        echo "SHA256SUM verification passed. Renaming file..."

        # Verifica se il file esiste prima di spostarlo
        if [ -f "/$DOWNLOAD_DIR/$mob_testing_phosh" ]; then
            mv "/$DOWNLOAD_DIR/$mob_testing_phosh" "/$DOWNLOAD_DIR/image.xz"

            # Controlla se mv ha avuto successo
            if [ $? -eq 0 ]; then
                echo "File renamed to image.xz"
            else
                echo "Error: Failed to rename the file."
                exit 1
            fi
        else
            echo "File to rename not found in /$DOWNLOAD_DIR."
            exit 1
        fi
    else
        echo "Signature failed: SHA256SUM verification did not pass."
        exit 1
    fi
fi
}

# Function to download Mobian testing image with Plasma for PinePhone Pro
mob_img_testing_plasma() {
    if [ -z "$mob_testing_plasma" ]; then
        echo "File not found."
        return 1  # Termina solo la funzione, lo script continua
    fi

    if [ -f "/$DOWNLOAD_DIR/$mob_testing_plasma" ]; then
        echo "File already exists in /$DOWNLOAD_DIR/. Skipping download."
    else
        echo "Latest file found: $mob_testing_plasma"
        wget --progress=dot -c -d --timeout=60 --tries=3 -O "/$DOWNLOAD_DIR/$mob_testing_plasma" "$mob_testing_img_url$mob_testing_plasma"

        if [ $? -eq 0 ]; then
            echo "Download complete: $mob_testing_plasma"
        else
            echo "Download failed."
            return 1
        fi
    fi
}


# Function to check Mobian testing image with Plasma for PinePhone Pro signature
mob_img_testing_plasma_sig() {
    mob_testing_plasma_shasums=$(curl -s "$mob_testing_img_url" | grep -oP 'mobian-rockchip-plasma-mobile-\d{8}.sha256sums' | sort -r | head -n 1)
    mob_testing_plasma_shasig=$(curl -s "$mob_testing_img_url" | grep -oP 'mobian-rockchip-plasma-mobile-\d{8}.sha256sums.sig' | sort -r | head -n 1)
    mob_testing_plasma_imgbmap=$(curl -s "$mob_testing_img_url" | grep -oP 'mobian-rockchip-plasma-mobile-\d{8}.img.bmap' | sort -r | head -n 1)

    if [ -f /$DOWNLOAD_DIR/$mob_testing_plasma_shasums ] && [ -f /$DOWNLOAD_DIR/$mob_testing_plasma_shasig ] && [ -f /$DOWNLOAD_DIR/$mob_testing_plasma_imgbmap ]; then
      echo "Signature files already available and I don't download them."
    else
      echo "I'm going to download signature files."
    wget -q -P /$DOWNLOAD_DIR "$mob_testing_img_url$mob_testing_plasma_shasums"
    wget -q -P /$DOWNLOAD_DIR "$mob_testing_img_url$mob_testing_plasma_shasig"
    wget -q -P /$DOWNLOAD_DIR "$mob_testing_img_url$mob_testing_plasma_imgbmap"
    fi

# GPG download and import key
if [ -z "$mob_keyring" ]; then
    echo "Debian keyring variable URL not available"
    exit 1
  else
    if [ ! -f "/$DOWNLOAD_DIR/mobian-archive-keyring.gpg" ]; then
      echo "I'm going to download Debian keyring"
      wget -q -P /$DOWNLOAD_DIR "$mob_keyring"
    #gpg --import mobian-archive-keyring.gpg
    #gpg --list-keys --with-colons | grep "$(gpg --with-colons --import-options show-only --import mobian-archive-keyring.gpg | grep '^fpr' | cut -d: -f10)"
      else
        echo "Debian keyring already present"
    fi
    # GPG check key
    if gpg --verify "/$DOWNLOAD_DIR/$mob_testing_plasma_shasig" >/dev/null 2>&1; then
        echo "Valid GPG signature"
    else
        echo "GPG signature not valid"
        exit 1
    fi
fi

# SHA256SUM check
#( cd /$DOWNLOAD_DIR && sha256sum -c "$mob_testing_plasma_shasums" )
if [ ! -f "/$DOWNLOAD_DIR/$mob_testing_plasma" ]; then
  echo "Image not avalaible"
  exit 1
else
  if ( cd /$DOWNLOAD_DIR && sha256sum -c "$mob_testing_plasma_shasums" 2>/dev/null ) |  grep -q "OK$"; then
        echo "SHA256SUM verification passed. Renaming file..."

        # Check if the file exist before to rename it
        if [ -f "/$DOWNLOAD_DIR/$mob_testing_plasma" ]; then
            mv "/$DOWNLOAD_DIR/$mob_testing_plasma" "/$DOWNLOAD_DIR/image.xz"
            
            # Check if the mv command status
            if [ $? -eq 0 ]; then
                echo "File renamed to image.xz"
            else
                echo "Error: Failed to rename the file."
                exit 1
            fi
        else
            echo "File to rename not found in /$DOWNLOAD_DIR."
            exit 1
        fi
    else
        echo "Signature failed: SHA256SUM verification did not pass."
        exit 1
    fi
fi
}                     


