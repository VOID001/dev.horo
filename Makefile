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
	install -Dm755 $(HOROPROXY) $(DESTDIR)/usr/bin
	install -Dm644 $(MODULE_NAME) $(DESTDIR)/lib/modules/$(shell uname -r)/
ifndef PKGBUILD
	- rmmod $(MODULE_NAME)
	- insmod $(MODULE_NAME)
endif

uninstall:
	- rmmod $(MODULE_NAME)
	- rm /usr/bin/horoproxy
	- rm $(DESTDIR)/lib/modules/$(shell uname -r)/$(MODULE_NAME)

clean:
	make -C $(KERN_DIR) M=$(shell pwd) clean
	rm $(HOROPROXY)

test:
	echo "Running echo test >>"
	echo "feed" >> /dev/horo
	echo "Running cat test\n"
	cat /dev/horo


