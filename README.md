# User Management Script

This script simplifies adding users and granting them administrative privileges on various Linux distributions (CentOS, Ubuntu, Rocky, Debian, AlmaLinux). It reads usernames and passwords from an external users.txt file, making it easy to add or update users without modifying the script.

## How to Use

1.Clone the repository

```bash
git clone https://github.com/TaKiKaToJi/ShellScripts-adduser-UNIX.git
cd ShellScripts-adduser-UNIX
```
2.Create or modify the users.txt file:
```bash
username:password
nueng:compcenter
nat:compcenter
wathit:compcenter
```

3.Give execution permission and run the script:
```bash
chmod +x AutoAdduser.sh
sudo ./AutoAdduser.sh
```
4.The script will create the users and display them from /etc/passwd.

