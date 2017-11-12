#!/usr/bin/expect
#set timeout 1

spawn scp root@10.184.61.92:/root/prj/vbs_ramdisk /tmp/zff
expect {
	"yes/no" {send "yes\r"}
	"assword" {send "Huawei123\r"}
}
interact

spawn scp /tmp/zff/vbs_ramdisk root@192.168.2.22:/home/ep_ramdisk
expect {
	"yes/no" {send "yes\r"}
	"assword" {send "EulerLinux\r"}
}
interact
