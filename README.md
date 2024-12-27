I wrote a Makefile and some scripts to download and burn Pine Phone Pro images, here below the list:
- Mobian Trixie with Posh;
- Mobian Trixie with Plasma Mobile;
- Arch;
- Kali NetHunter.

### FIRST STEP ###
You can start to run "make img" and the image will be downloaded and copied to the Pine Phone Pro.

### SECOND STEP ###
Turn off the Pine Phone Pro, remove if inserted the microSD, power on the Pine Phone Pro and start to install the o.s.

### THIRD STEP ###
Install ssh if it is non avalaible on the Pine Phone Pro.

### FOURTH STEP ####
Run from the pc\laptop "make deploy", it will copy the files to the Pine Phone Pro.

### FIVETH STEP ####
From the Pine Phone Pro (you can connect also to its by ssh from your pc/laptop) run "make update" and after it "make install".
