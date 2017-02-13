package main

import (
	"flag"
	"fmt"
	"io/ioutil"
	"net/http"
	"os"
	"strings"
	"syscall"
	"unsafe"
)

var Endpoint = ""

const (
	HoroServerAPI = "http://voidisprogramer.com:9999/api"
	APIVer        = "v0"
)

var cmdMap = map[string]string{
	"feed":  "POST /horo/feed",
	"stats": "GET /individual/stats",
}

func init() {
	flag.Parse()
}

func command() (cmd string, args []string, err error) {
	arg := flag.Args()

	for i := 0; i < len(arg); i++ {
		arg[i] = strings.Replace(arg[i], "\n", "", -1)
	}

	if len(arg) <= 0 {
		err = fmt.Errorf("no command provided")
		return
	}
	cmd = arg[0]
	if len(arg) >= 2 {
		args = arg[1:]
	}
	return
}

func request(command string, args []string) (data []byte, err error) {
	cmd, ok := cmdMap[command]
	if !ok {
		err = fmt.Errorf("unsupported command %s", command)
		return
	}

	lst := strings.Split(cmd, " ")
	method := lst[0]
	api := lst[1]

	machineID, er := ioutil.ReadFile("/etc/machine-id")
	machineID = machineID[0 : len(machineID)-2]
	if er != nil {
		//err = errors.Wrap(er, "get machine_id error")
		err = er
		return
	}

	cli := http.Client{}
	req, er := http.NewRequest(method, Endpoint+api, nil)
	if er != nil {
		//err = errors.Wrap(er, "create request error")
		err = er
		return
	}
	req.Header.Set("X-Lawrence-ID", string(machineID))
	resp, er := cli.Do(req)
	if er != nil {
		//err = errors.Wrap(er, "request error")
		err = er
		return
	}
	defer resp.Body.Close()
	data, err = ioutil.ReadAll(resp.Body)
	if err != nil {
		//err = errors.Wrap(err, "read response error")
		err = er
		return
	}
	return
}

func response(data []byte) (err error) {
	dev, er := os.Open("/dev/horo")
	if er != nil {
		err = er
		return
	}
	syscall.Syscall(syscall.SYS_IOCTL, dev.Fd(), 0, uintptr(unsafe.Pointer(&data[0])))
	return
}

func main() {
	//f, err := os.OpenFile("/tmp/horo.log", os.O_RDWR|os.O_APPEND, 0666)
	//defer f.Close()
	//log.SetOutput(f)
	Endpoint = HoroServerAPI + "/" + APIVer
	cmd, args, err := command()
	if err != nil {
		//log.Errorf("%s", err)
		os.Exit(-1)
	}
	data, err := request(cmd, args)
	if err != nil {
		//log.Errorf("%s", err)
		os.Exit(-2)
	}
	err = response(data)
	if err != nil {
		//log.Errorf("%s", err)
		os.Exit(-3)
	}
}
