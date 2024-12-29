configure:
	sudo sed -i '1s/^/#/' /etc/apt/sources.list
	echo "deb https://http.kali.org/kali kali-rolling main non-free contrib" | sudo tee -a /etc/apt/sources.list
	sudp apt-get update
	sudo apt-get install aptitude -y
	sudo aptitude update
	sudo aptitude safe-upgrade -y
