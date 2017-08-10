#!/bin/bash
# This shell script will create amount of linux login accounts for you.
# 1. check the "account_add.txt" file exist? you must create that file manually.
#    one account name one line in the "account_add.txt" file.
# 2. use openssl to create users password.
# 3. User must change his password in his first login.
# 4. more options check the following url:
export PATH=/bin:/sbin:/usr/bin:/usr/sbin

# 0. userinput
usergroup="docker"             # if your account need secondary group, add here. zhanghf add docker group
pwmech="openssl"               # "openssl" or "account" is needed.
homeperm="no"                  # if "yes" then I will modify home dir permission to 711

# 1. check the accountadd.txt file
action="${1}"                  # "create" is useradd and "delete" is userdel.
if [ ! -f account_add.txt ]; then
	echo "There is no account_add.txt file, stop here."
        exit 1
fi

[ "${usergroup}" != "" ] && groupadd -r ${usergroup}
rm -f outputpw.txt
usernames=$(cat account_add.txt)

for username in ${usernames}
do
    case ${action} in
        "create")
            [ "${usergroup}" != "" ] && usegrp=" -G ${usergroup} " || usegrp=""
            useradd ${usegrp} ${username}               # 新增账号
            [ "${pwmech}" == "openssl" ] && usepw=$(openssl rand -base64 6) || usepw=${username}
            echo ${usepw} | passwd --stdin ${username}  # 建立密码
            chage -d 0 ${username}                      # 强制登录修改密码
            [ "${homeperm}" == "yes" ] && chmod 711 /home/${username}
	    echo "username=${username}, password=${usepw}" >> outputpw.txt
            ;;
        "delete")
            echo "deleting ${username}"
            userdel -r ${username}
            ;;
        *)
            echo "Usage: $0 [create|delete]"
            ;;
    esac
done
