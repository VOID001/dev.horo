package main

import (
	"flag"
	"fmt"
	"io/ioutil"
	"os"
	"syscall"
	"unsafe"
)

func init() {
	flag.Parse()
}

func main() {
	arg := flag.Args()
	file, err := os.OpenFile("/tmp/horo.log", os.O_RDWR|os.O_APPEND, 0666)
	if err != nil {
		fmt.Printf("%s", err)
		os.Exit(-1)
	}
	defer file.Close()
	fmt.Fprintf(file, "Operation: %s\n", arg)
	data, err := ioutil.ReadFile("/tmp/horo.log")
	if err != nil {
		fmt.Printf("%s", err)
		os.Exit(-1)
	}
	dev, err := os.Open("/dev/horo")
	if err != nil {
		fmt.Printf("%s", err)
		os.Exit(-1)
	}
	syscall.Syscall(syscall.SYS_IOCTL, dev.Fd(), 0, uintptr(unsafe.Pointer(&data[0])))
	return
}
