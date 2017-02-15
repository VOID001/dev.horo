obj-m += horok.o

KERN_DIR = /lib/modules/$(shell uname -r)/build
MODULE_NAME = horok.ko
HOROPROXY = horoproxy/horoproxy

.PHONY: all install clean test

all: 
	cd horoproxy; go build
	make -C $(KERN_DIR) M=$(shell pwd) modules

install:
	make -C $(KERN_DIR) M=$(shell pwd) modules
	install -Dm755 $(HOROPROXY) $(DESTDIR)/usr/local/bin
ifndef PKGBUILD
	- rmmod $(MODULE_NAME)
	- insmod $(MODULE_NAME)
endif

uninstall:
	- rmmod $(MODULE_NAME)
	- rm /usr/local/bin/horoproxy

clean:
	make -C $(KERN_DIR) M=$(shell pwd) clean
	rm $(HOROPROXY)

test:
	echo "Running echo test >>"
	echo "feed" >> /dev/horo
	echo "Running cat test\n"
	cat /dev/horo


