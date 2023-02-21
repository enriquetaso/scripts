#!/bin/bash -x

basic_setup () {
    echo 'Enable Ceph V2 Clone API'
    # use v2 clone api
    sudo ceph osd set-require-min-compat-client mimic
    # Create trash purge schedule add --pool volume 1M now 
    # Create encrypted type
    # openstack volume type create --encryption-provider nova.volume.encryptors.luks.LuksEncryptor --encryption-cipher aes-xts-plain64 --encryption-key-size 256 --encryption-control-location front-end luks
    # cinder type-key luks set volume_backend_name=ceph
}

create_clones (){
   for ((i = 0 ; i < $2 ; i++)); do
         echo $i
         name="volume-$i"
         vol_id=$(cinder create 1 --name $name --source-volid $1 --poll | grep " id " | awk '{print $4}' ) 
         sleep 2
   done
   return vol_id
}

remove_all_volumes_UUID_order(){
    list_vols=$(cinder list | grep available | awk '{print $2}' ) 
    for i in $list_vols; do
          echo $i
          cinder delete $i
          sleep 5
    done
}

delete_volumes_one_line(){
    list_vols=$( cinder list | grep available | awk '{print $2}' | tr '\n' '  ' ) 
    cinder delete $list_vols
}
basic_testcase1(){
    # 1. Create volume A
    # 2. Create snapshot B on volume A
    # 3. Create volume C cloning from snapshot B
    # 4. Delete snapshot B
    # 5. Delete volume A 
    # Check the rbd trash purge ls --pool volumes
    
    volA_id=$(cinder create 1 --name volume-A | grep -owP 'id.*\|\s\K.*[^\|]+' ) 
    echo "First volume created $volA_id"
    snap_id=$(cinder snapshot-create volume-A --name snap-from-volume-A | grep -owP 'id.*\|\s\K.*[^\|]+' )
    echo "First snap created $snap_id"
    sleep 10
    volB_id=$(cinder create 1 --name volume-B --snapshot-id $snap_id | grep -owP 'id.*\|\s\K.*[^\|]+' ) 
    echo "Second volume created $volB_id"
    cinder snapshot-delete $snap_id
    sleep 10
    cinder list
    cinder delete $volA_id
    sleep 10
    cinder list
    echo "The volume $volA_id should be display in the trash: "
    sudo rbd trash list --pool volumes 
    cinder delete $volB_id
    sleep 10
    sudo rbd trash list --pool volumes 
    sudo rbd trash purge --pool volumes 
}

basic_testcase1
