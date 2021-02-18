# Install from network via PXE boot

Details regarding preseeding: https://help.ubuntu.com/lts/installation-guide/amd64/apbs04.html and https://help.ubuntu.com/lts/installation-guide/example-preseed.txt

## nfs

    Enable NFS 3 (not 4) on QNAP
    mkdir /Public/isos # on qnap
    Mount iso image
    cp to /Public/isos
    mount on linux system
    chmod -R ug+rwX,o+rX,o-w /Public/isos/myiso

## unnattended configuration

Run

    docker compose up

in order to provide the unattended seed (I'm running it on 192.168.178.38)

## Either boot via PXE.

Get additional files not provided in this repo.

    cd pxeboot
    sudo mkdir /tmp/loop
    mkdir -p iso/linuxmint-20-xfce-64bit.iso
    sudo mount -o loop /mnt/nas/home/isos/linuxmint-20-xfce-64bit.iso /tmp/loop
    sudo cp -r /tmp/loop/. iso/linuxmint-20-xfce-64bit.iso/
    mkdir /tmp/out
    dpkg -x iso/linuxmint-20-xfce-64bit.iso/pool/main/g/grub2-signed/grub-efi-amd64-signed_1.142+2.04-1ubuntu26_amd64.deb /tmp/out/
    sudo cp /tmp/out/usr/lib/grub/x86_64-efi-signed/grubnetx64.efi.signed grubx64.efi

## Or use USB stick

For UEFI via USB: Hit `e` on the grub menu entry. Add ip=dhcp before `--` and append
`automatic-ubiquity url=http://192.168.178.38:8080/preseed/linuxmint-unattended.seed`
 after the `--`.

Or create a custom USB drive manually.

1. Format the USB drive. For that issue `sudo fdisk /dev/sdb`, hit `o` to create a new empty DOS partition table. Hit `n` and just accept primary and the defaults. Save with `w`. To format run `sudo mkfs.vfat /dev/sdb1`.
2. Copy iso contents to USB drive. For that mount ubuntu iso file (tested with Ubuntu 20.04) and copy everything to usb. `sudo cp -a /tmp/iso-mnt/. /tmp/usb-mnt/`. Ignore errors regarding links.
3. Modify `boot/grub/grub.cfg` as desired. See [the example from this repo](usb/grub.cfg).
4. After booting and choosing `Unattended install...` remove the USB after the initrd has been loaded (which should only take a couple of seconds).

## Finish installation

Change the default LUKS password from `insecure` to something more secure.

    sudo cryptsetup luksChangeKey /dev/sda3

Consider extending root volume.

    sudo lvextend -l +100%FREE /dev/workstation/root
    sudo resize2fs -p /dev/workstation/root

## Virtualbox setup

Assuming host is running the PXE server.

Configure network to be in Bridged mode
Hit F12 on boot or configure Network boot to be the first option (System->Motherboard)
