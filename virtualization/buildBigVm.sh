#!/bin/bash
#  echo "Issuing a command to ask for your password"
#  sudo apt-get
if [ $# -ne 2 ]; then
  echo "Usage, $0 from to"
  exit 1
fi
if [ $2 -ge $1 ]; then
virsh -c qemu:///system list --all
x=$1
while [ $x -le $2 ]
do
#  echo "Cleaning up yaboulna$x"
#virsh destroy yaboulna$x
#  virsh undefine yaboulna$x
#  rm -rf /home/yaboulna/yaboulna$x.vm*
  mv /home/yaboulna/yaboulna$x* /home/yaboulna/old/
  echo "Creating vm yaboulna$x "
  mkdir /home/yaboulna/yaboulna$x.vm
  echo UWPa55w0rt | sudo -S vmbuilder kvm ubuntu \
	-t /home/yaboulna/tmp \
	--mirror=http://mirror.cs.uwaterloo.ca/ubuntu \
	--suite=precise \
	--flavour=server \
	--arch=amd64 \
	-o -v \
	--cpus=50 \
	--mem=204800 \
        --libvirt=qemu:///system \
	--ip=192.168.122.$x \
	--hostname=yaboulna$x \
        --gw=192.168.122.1 \
	--dns=192.168.122.1 \
	 --part=vmBig.partition \
	 --user=younos \
	--pass=aboulna \
	--name='Younos Aboulnaga'\
         --addpkg=acpid \
	--addpkg=openssh-server \
	--addpkg=vim \
	--addpkg=nfs-common \
	--firstboot=/home/yaboulna/nfs/vmshared/Code/thesis/virtualization/vm1stboot.sh \
	--timezone='Canada/Eastern' \
        --dest=/home/yaboulna/yaboulna$x.vm > /home/yaboulna/yaboulna$x.out 2> /home/yaboulna/yaboulna$x.err 
#	--bridge=br0 \
#  echo "Done creating yaboulna$x"
#&  virsh start yaboulna$x
#  --user=yaboulna \
#        --name='Younos Aboulnaga'\
#         --pass=anboulna \
  cat ./buildVms.sh >> /home/yaboulna/yaboulna$x.out
  virsh dumpxml yaboulna$x > /home/yaboulna/yaboulna$x.xml
  x=`expr $x + 1`
done
#tail -f 10 yaboulna`expr $x - 1`.err
else
  echo "From muse bt smaller than to ip octet"
fi
