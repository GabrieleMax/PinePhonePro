#! /bin/bash

# Fix repository's issue
sudo sed -i '1s/^/#/' /etc/apt/sources.list
echo "deb https://http.kali.org/kali kali-rolling main non-free contrib" | sudo tee -a /etc/apt/sources.list                       
sudo apt-get update
sudo apt-get install aptitude -y
sudo aptitude update
sudo aptitude safe-upgrade -y

# Install make
sudo apt-get install make -y
sudo reboot
