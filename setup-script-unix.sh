#!/bin/bash

# Disk expand/mapping
echo 'Expanding disk...'
lvextend -l +100%FREE -r /dev/mapper/ubuntu--vg-ubuntu--lv
echo 'Expansion done'

# Disable service interactive restart
echo 'Disabling interactive restart for apt... '
echo "\$nrconf{restart} = 'a'" >> /etc/needrestart/needrestart.conf
echo 'Disabled interactive restart'

# Get updates
echo 'Getting latest update...'
apt-get update
echo 'Updates done'

# Installing NFS server
echo 'Installing NFS server...'
apt-get install -y nfs-kernel-server
echo 'Install done'

# Make Directory
echo 'Making directory...'
mkdir -p /var/nfsshare/
echo 'Made directory'

# Change ownership
echo 'Changing ownership of directory...'
chown nobody:nogroup /var/nfsshare
echo 'Ownership changed'

# Export to NFS
echo 'Exporting directory to NFS...'
echo "/var/nfsshare *(rw,all_squash,sync,no_subtree_check)" | tee -a /etc/exports
echo 'Exporting done'

# Start NFS server
echo 'Starting NFS server...'
systemctl start nfs-server
echo 'NFS server started'

# Install pip
echo 'Installing pip. This might take a while...'
apt install -y python3-pip
echo 'Done installing pip...'

# Install python module 
echo 'Installing purge module as user...'
sudo -u $1 pip install --no-input --user ciscodnacbackupctl
echo 'Purge module installed'

# Add to PATH
echo 'Adding purge module to PATH via append...'
echo 'export PATH="/home/'$1'/.local/bin:$PATH"' >> /home/$1/.bashrc
echo 'Done adding to PATH'

#ciscodnacbackupctl config --hostname $2 --username $3 --password $4
# Can't reload shell profile in NON-interactive script, pass to reboot. 

# Create service script
echo 'Creating init-purge script for service...'
cat >/usr/bin/init-purge.sh <<EOF1
#!/bin/bash
# Run DNA Center/Catalyst Center backup purge on startup  

PATH=$PATH:/home/$1/.local/bin/ciscobackupctl:/home/$1/.local/bin/
export PATH

ciscodnacbackupctl config --hostname $2 --username $3 --password $4

ciscodnacbackupctl daemon start --keep 4

ciscodnacbackupctl schedule_purge -i daily

exit 0

EOF1
# Make it an executable
echo 'Making init-purge an executable...'
chmod +x /usr/bin/init-purge.sh
echo 'Done'
# Create backup-purge service
echo 'Creating backup-purge service...'
cat >/etc/systemd/system/backup-purge.service <<EOF2
[Unit]
description=Backup purge service

[Service]
User=$1
ExecStart=/usr/bin/init-purge.sh

[Install]
WantedBy=multi-user.target
EOF2
echo 'Backup-purge service made'

# Enable service persist on reboot
echo 'Enable new service persist on reboot'
systemctl enable backup-purge.service

echo "All application have been installed and setup is complete, rebooting!!!!!"
sleep 6

reboot now
exit 0
