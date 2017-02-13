obj-m += horok.o

KERN_DIR = /lib/modules/$(shell uname -r)/build

MODULE_NAME = horok.ko

all:
	make -C $(KERN_DIR) M=$(PWD) modules
	cd horoproxy; go get; go build
	#make -C /lib/modules/$(shell uname -r)/build M=$(PWD) modules

install:
	make -C $(KERN_DIR) M=$(PWD) modules
	sudo cp horoproxy/horoproxy /usr/local/bin
	touch "/tmp/horo.log"
	- sudo rmmod $(MODULE_NAME)
	- sudo insmod $(MODULE_NAME)

clean:
	make -C $(KERN_DIR) M=$(PWD) clean

test:
	echo "Running cat test\n"
	cat /dev/horo
	echo "Running echo test >>"
	- echo "feed" >> /dev/horo
	- echo "wash" > /dev/horo
	echo "Running cat test\n"
	cat /dev/horo
