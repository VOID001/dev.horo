obj-m += hello-kernel.o

KERN_DIR = /lib/modules/$(shell uname -r)/build

all:
	make -C $(KERN_DIR) M=$(PWD) modules
	#make -C /lib/modules/$(shell uname -r)/build M=$(PWD) modules

install:
	make -C $(KERN_DIR) M=$(PWD) modules
	- sudo rmmod hello-kernel
	- sudo insmod hello-kernel.ko

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
