vboxmanage modifyvm win7 --memory 2048
vboxmanage modifyvm win7 --cpus 2
vboxmanage modifyvm win7 --ioapic on
vboxmanage modifyvm win7 --hwvirtex on
vboxmanage modifyvm win7 --nestedpaging on
vboxmanage modifyvm win7 --rtcuseutc on



vboxmanage modifyvm win7 --nic1 nat
vboxmanage modifyvm win7 --nictype1 virtio
vboxmanage modifyvm win7 --natpf1

#
!abort
在本地图形化界面创建好后，在COPY到服务器上面去
