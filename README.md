# backupserversetup
## Easy setup script for Ubuntu server to act as NFS server for DNA/Catalyst Center Assurance backups including automatic backup purging. 

Tested on Ubuntu 22.04.4 LTS
# Install
1. Setup your Ubuntu machine as usual.
2. execute the bash script including args.

   $1 = Ubuntu user
      (Python module will be installed under /home/user/.local/bin)
   
   $2 = DNA/Catalyst Center Enterprise address/VIP
   
   $3 = DNA/Catalyst Center admin account
   
   $4 = DNA/Catalyst Center admin password

example: sudo wget -O - http://raw.githubusercontent.com/Michaelkarper/backupserversetup/main/setup-script-unix.sh | sudo bash -s nonrootuser 10.1.0.10 admin 'examplep@$$!'

4. Wait for reboot and verify daemon is running. <ciscodnacbackupctl daemon status>

5. Verify backup-purge service is running. <sudo systemctl status backup-purge.service> 

6. Proceed with configuring your Assurance backup in DNA/Catalyst Center.
