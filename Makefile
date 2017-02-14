obj-m += horok.o

KERN_DIR = /lib/modules/$(shell uname -r)/build

MODULE_NAME = horok.ko

HOROPROXY = horoproxy/horoproxy

.PHONY: all install clean test

all: 
	cd horoproxy; go build
	make -C $(KERN_DIR) M=$(PWD) modules

install:
	make -C $(KERN_DIR) M=$(PWD) modules
	sudo cp $(HOROPROXY) /usr/local/bin
	- sudo rmmod $(MODULE_NAME)
	- sudo insmod $(MODULE_NAME)

uninstall:
	- sudo rmmod $(MODULE_NAME)
	- sudo rm /usr/local/bin/horoproxy

clean:
	make -C $(KERN_DIR) M=$(PWD) clean
	rm $(HOROPROXY)

test:
	echo "Running echo test >>"
	echo "feed" >> /dev/horo
	echo "Running cat test\n"
	cat /dev/horo


