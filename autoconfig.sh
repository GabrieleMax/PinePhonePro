#!/bin/bash
## Last update 26/12/2024 ##                                   
## Before to start the script connect the device by usb to the laptop

FIRSTUSER=$(grep "1000" /etc/passwd | awk -F ':' '{print $1}')                                                                
# Url of the website with image links
url="https://images.mobian-project.org/pinephonepro/installer/weekly/"

# Show the initial message
echo "Connect the device"

# Save the initial output of lsblk, excluding partitions
initial_devices=$(lsblk -dn -o NAME | sort)

# Continuously monitor for a new device
while true; do
    # Save the current output of lsblk, excluding partitions
    current_devices=$(lsblk -dn -o NAME | sort)

    # Compare the current output with the initial one
    new_device=$(comm -13 <(echo "$initial_devices") <(echo "$current_devices"))

    # If a new device is found, perform the desired action
    if [ -n "$new_device" ]; then
        echo "New device connected: $new_device"
        device_name="$new_device"  # Assign the device name to a variable
        break  # Exit the loop
    fi

    # Pause to avoid consuming too much CPU
    sleep 1
done

# Now you can use the $device_name variable
echo "The connected device is: $device_name"

# Recover the list of files from the website
deb_testing_posh=$(wget -q -O - "$url" | grep -oP 'mobian-installer-rockchip-phosh-\d{8}.img.xz' | sort -r | head -n 1)
deb_testing_plasma=$(wget -q -O - "$url" | grep -oP 'mobian-installer-rockchip-plasma-mobile-\d{8}.img.xz' | sort -r | head -n 1)

# Function to download the Mobian image with Phosh
deb_img_testing_posh() {
    if [ -n "$deb_testing_posh" ]; then
        echo "File found: $deb_testing_posh"
        wget --progress=dot "$url$deb_testing_posh" -O "/tmp/image.xz"
        echo "Download finished: $deb_testing_posh"
    else
        echo "File not found."
    fi
}

# Function to download the Mobian image with Plasma
deb_img_testing_plasma() {
    if [ -n "$deb_testing_plasma" ]; then
        echo "Most recent file found: $deb_testing_plasma"
        wget --progress=dot "$url$deb_testing_plasma" -O "/tmp/image.xz"
        echo "Download finished: $deb_testing_plasma"
    else
        echo "File not found."
    fi
}

# Function for the image burn process
img_burn() {
    bash -c '\
    echo "The disk that will be erased is /dev/$new_device"; \
    pv "/tmp/image.xz" | unxz -c > /tmp/image.img
    sudo dd if=/tmp/image.img of=/dev/$new_device bs=4M status=progress conv=noerror,sync
    '
}

# Menu with correct options
PS3="Choose an option (1-4): "
select menu in "Download and install Debian testing with Plasma mobile" \
               "Download and install Debian testing with Phosh mobile" \
               "Image burn" \
               "Exit"; do
    case $menu in
        "Download and install Debian testing with Plasma mobile")
            deb_img_testing_plasma
            ;;
        "Download and install Debian testing with Phosh mobile")
            deb_img_testing_posh
            ;;
        "Image burn")
            img_burn
            ;;
        "Exit")
            echo "Exiting the script."
            break
            ;;
        *)
            echo "Invalid choice. Please try again."
            ;;
    esac
done

