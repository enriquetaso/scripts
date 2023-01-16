#!/bin/bash -x

# echo "asdf" > passphrase
# MYSECRET=`printf %s $(cat passphrase) | base64`
 
BASE_IMG=/home/enriquetaso/test-qemu-img-snapshot/volume-7488dfde-b639-44d4-8df0-34da6f616b2d
SNAPSHOT_IMG=/home/enriquetaso/test-qemu-img-snapshot/volume-7488dfde-b639-44d4-8df0-34da6f616b2d.7a30bc08-09c0-482e-bf40-286cbcddd121
PASSPHRASE=/home/enriquetaso/test-qemu-img-snapshot/passphrase
SIZE=1073741824
VM_NAME=instance-0000009b
RAW_IMG=/home/enriquetaso/test-qemu-img-snapshot/volume-from-second-qcow2-vol.raw

MYSECRET=`printf %s "123456" | base64`

qemu-img create --object secret,id=sec0,data=123456 \
 -f qcow2 \
 -o encrypt.format=luks,encrypt.key-secret=sec0 \
 $BASE_IMG 1G


qemu-img create -f qcow2 \
    -o encrypt.format=luks,encrypt.key-secret=s1 \
    -o encrypt.format=luks,encrypt.key-secret=s0 \
    -b 'json:{"encrypt.key-secret": "s0", "backing.encrypt.key-secret": "s0", "backing.file.filename": "'"$BASE_IMG"'", "file.filename": "'"$BASE_IMG"'"}' \
    -F qcow2 \
    --object secret,id=s0,data=123456  \
    --object secret,id=s1,data=123456 \
    $SNAPSHOT_IMG 



virsh secret-define sec1.xml
virsh secret-define sec2.xml
# virsh secret-dumpxml f981dd17-143f-45bc-88e6-111111111111

virsh secret-set-value f981dd17-143f-45bc-88e6-111111111111 $MYSECRET
virsh secret-set-value f981dd17-143f-45bc-88e6-222222222222 $MYSECRET


virsh list
virsh domblklist instance-0000009b

virsh attach-device $VM_NAME disk-attach-snap.xml

virsh domblklist instance-0000009b
virsh domblkinfo instance-0000009b vdb


sleep 5 && virsh detach-device instance-0000009b disk-attach-snap.xml





# rm -f $BASE_IMG
# rm -f $SNAPSHOT_IMG
# rm -f $RAW_IMG


# qemu-img create -f qcow2 \
#     -o encrypt.format=luks,encrypt.key-secret=s0,encrypt.cipher-alg=aes-256,encrypt.cipher-mode=xts,encrypt.ivgen-alg=plain64 \
#     --object secret,id=s0,format=raw,file=passphrase \
#     $BASE_IMG \
#     $SIZE

# qemu-img create -f qcow2 \
#     -o encrypt.format=luks,encrypt.key-secret=s1,encrypt.cipher-alg=aes-256,encrypt.cipher-mode=xts,encrypt.ivgen-alg=plain64 \
#     -o encrypt.format=luks,encrypt.key-secret=s0,encrypt.cipher-alg=aes-256,encrypt.cipher-mode=xts,encrypt.ivgen-alg=plain64 \
#     -b 'json:{"encrypt.key-secret": "s0", "backing.encrypt.key-secret": "s0", "backing.file.filename": "'"$BASE_IMG"'", "file.filename": "'"$BASE_IMG"'"}' \
#     -F qcow2 \
#     --object secret,id=s0,format=raw,file=$PASSPHRASE \
#     --object secret,id=s1,format=raw,file=$PASSPHRASE \
#     $SNAPSHOT_IMG 


# qemu-img info --output=json --force-share $SNAPSHOT_IMG

# qemu-img rebase \
#     --object secret,id=s0,file=passphrase \
#     --image-opts encrypt.key-secret=s0,file.filename=$SNAPSHOT_IMG \
#     -u \
#     -b $BASE_IMG \
#     -F qcow2


# qemu-img info --output=json --force-share $BASE_IMG && sleep 3

# qemu-img check --image-opts encrypt.format=luks,encrypt.key-secret=s0,file.filename=$BASE_IMG \
#     --object secret,id=s0,file=passphrase

# qemu-img check --image-opts encrypt.format=luks,encrypt.key-secret=s1,file.filename=$SNAPSHOT_IMG,backing.encrypt.key-secret=s0 \
#    --object secret,id=s1,file=passphrase \
#    --object secret,id=s0,file=passphrase 

# qemu-img convert -n -p \
#     --object secret,id=s0,file=passphrase \
#     --image-opts encrypt.format=luks,encrypt.key-secret=s0,file.filename=$BASE_IMG \
#     --target-image-opts "driver=raw,file.filename=$RAW_IMG"


# qemu-img convert -n -p \
#     --object secret,id=s0,file=passphrase \
#     --object secret,id=s1,file=passphrase \
#     --image-opts encrypt.format=luks,encrypt.key-secret=s1,file.filename=$SNAPSHOT_IMG,backing.encrypt.key-secret=s0,backing.file.filename=$BASE_IMG \
#     --target-image-opts "driver=raw,file.filename=$RAW_IMG"
