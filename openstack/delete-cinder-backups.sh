cinder backup-remove | (cinder backup-list | awk '{print $2}' | sed -n '2!p')
