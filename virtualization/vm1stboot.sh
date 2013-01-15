#!/bin/bash

#nfs mount
mkdir -p /nfs/vmshared
chown younos:younos /nfs/vmshared

echo "192.168.122.1:/vmshared				/nfs/vmshared	nfs4	_netdev,bootwait,auto	0	0" >> /etc/fstab

mount /nfs/vmshared

# passwordless sudoer
echo "younos ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# apt repos
echo "deb http://cran.rstudio.com/bin/linux/ubuntu/ precise/" >> /etc/apt/sources.list
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E084DAB9

# echo "deb http://archive.canonical.com/ precise partner" >> /etc/apt/sources.list

apt-get update

# apt-get upgrade

# Java from Sun
# apt-get install -qqy --force-yes debconf-utils
# export DEBIAN_FRONTEND=noninteractive


#R, RHadoop and its dependencies
apt-get install -qqy --force-yes r-base screen
echo 'options(repos=structure(c(CRAN="http://cran.rstudio.com/")))' >> /usr/lib/R/library/base/R/Rprofile 
# Rscript --vanilla --default-packages=utils -e 'res <- try(install.packages("RJSONIO"))' -e 'cat(res)'

#Public key
mkdir /home/younos/.ssh
chown younos:younos /home/younos/.ssh
chmod 700 /home/younos/.ssh
# echo "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAvVicKiuaZmO5K8+mWsHk5QtPOgsFzyZcKH1TGuZvtf65aQuoIKZMqJ5jXqwXMA3L9GvCybiws5BUmELoqJJeYaF6JvJPIqw6rCQMH4AjhjJxjJt5ZgvjUOEOZjFqMwccfSAi5NRCaLVufSsKN6Fv5z04ayeymg/VKVHkixqrbslDB/2X+ecVEmQmvcxfleAqwz0w/y3OViD94R1lTVBWr+xDfkrKrWCriGy+MbLMYmaPSsRspaZ1uxe7gcjLOkwLuFl/zDktk8ly9pToidR9cMuHDy4bf/Uy3Wpc28iOQ77na0Hzitpx9+MvV9q54idAD0EAui2v1aNl0NIRJLNagw== yaboulna@plg2" > /home/younos/.ssh/authorized_keys

echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCiYs/M7TRMCsK7g6eY47vi47VeYBIuHm9orOFLoWtlog6QxCtvQPqRgRaLmob2Z/40rLMsW/WUoE2xBJtHPrwDQUL8g0+25KKbmEQwZCXRcpO6bnKPiTcfHp6+mrwpgSJnsDZI3pTSYC4c2fJ7/FvfSuaHrMO+3UqsVb6/xwrlRfw3eKfYDUdsEJ3YBrZAOa74ov9WfZxs/qaLrIDXHfT3CH14EtZWWpK/ofo8Bfugvb/r7AALXfhRB9t3XFO94VWsbPNKCpKh+DlCoTyZ+NEFBed8JnopCgv594KSPR/8xzN0nFnmchBcqUMr2EJWTXkO5Ewg3hd1P2b0eSC7uH+D yaboulna@hops" > /home/younos/.ssh/authorized_keys

echo "127.0.0.1 localhost

# The following lines are desirable for IPv6 capable hosts
::1 ip6-localhost ip6-loopback
fe00::0 ip6-localnet
ff00::0 ip6-mcastprefix
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters
ff02::3 ip6-allhosts" > /etc/hosts

for h in {11..250}
do
	echo "192.168.122.$h yaboulna$h" >> /etc/hosts
done
