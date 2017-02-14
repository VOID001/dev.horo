#include <linux/module.h>
#include <linux/kernel.h>
#include <linux/file.h>
#include <linux/string.h>
#include <linux/miscdevice.h>
#include <linux/uaccess.h>
#include <linux/netpoll.h>

#define M_MISC_MAJOR 0

static struct miscdevice misc;

char kbuf[PAGE_SIZE];

// horo_read displays info to user stored by horo_ioctl
static ssize_t horo_read(struct file *filp, char __user *buf,
		size_t count, loff_t *offp)
{
	return simple_read_from_buffer(buf, count, offp, kbuf, strlen(kbuf) + 1);
}

// call_horoproxy calls usermode helper: horoproxy to do real tasks
static int call_horoproxy(char *cmd) {
	struct subprocess_info *sub_info;
	char *argv[] = {"/usr/local/bin/horoproxy", cmd, NULL};
	static char *envp[] = {
		"HOME=/",
		"TERM=linux",
		NULL
	};

	schedule();
	sub_info = call_usermodehelper_setup(argv[0], argv, envp, GFP_ATOMIC, NULL, NULL, NULL);
	if (sub_info == NULL) return -ENOMEM;
	return call_usermodehelper_exec(sub_info, UMH_WAIT_PROC);
}

// horo_write gets the command from user, and send it to horoproxy
static ssize_t horo_write(struct file *filp, const char __user *buf,
		size_t count, loff_t *offp)
{
	char *cmdbuf;
	int ret;

	cmdbuf = (char *)kmalloc(PAGE_SIZE, GFP_KERNEL);
	memset(kbuf, 0, sizeof(kbuf));
	ret = simple_write_to_buffer(kbuf, sizeof(kbuf), offp, buf, count);
	if (ret < 0)
		return ret;
	pr_debug("Kbuf: %s", kbuf);
	ret = call_horoproxy(kbuf);
	kfree(cmdbuf);
	if(ret == 0)
		return count;
	return ret;
}

// horo_ioctl is for store the result to buffer
// later will show the result when userspace call horo_read
static long horo_ioctl(struct file *filp, unsigned int op, 
		unsigned long paramp) 
{

	char __user *userdat = (char *)paramp;
	int ret;

	memset(kbuf, 0, sizeof(kbuf));
	ret = copy_from_user(kbuf, userdat, PAGE_SIZE);
	pr_debug("IOCTL Recv Message: %s\n", kbuf);
	return ret;
}

const struct file_operations misc_fops = {
	.read = horo_read,
	.owner = THIS_MODULE,
	.write = horo_write,
	.unlocked_ioctl = horo_ioctl,
};

int horo_init(void)
{
	int ret;

	pr_debug("Start init misc device horo\n");
	misc.minor = MISC_DYNAMIC_MINOR;
	misc.mode = 0666;
	misc.name = "horo";
	misc.fops = &misc_fops;
	ret = misc_register(&misc);
	if (ret < 0) {
		pr_err("Cannot register misc horo\n");
		return ret;
	}
	return 0;
}

void horo_exit(void)
{
	pr_debug("Start de-init misc device horo\n");
	misc_deregister(&misc);
}


module_init(horo_init);
module_exit(horo_exit)

MODULE_LICENSE("GPL v3");
MODULE_AUTHOR("VOID001<telegram @VOID001>");
