BLUE='\033[1;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
DEFAULT='\033[0m'
GREEN='\033[0;32m'
UNDERLINE=$(tput smul)
INPUT=
rm -f disk_images/tomos.flp
mkdosfs -C disk_images/tomos.flp 1440 || exit
clear
cd bootloader
nasm -O0 -w+orphan-labels -f bin -o bootloader.bin bootloader.asm || exit
echo -e "--${YELLOW}bootloader->assembled${DEFAULT}--"
cd ..
nasm -O0 -w+orphan-labels -f bin -o kernel/kernel.bin kernel/kernel.asm || exit
echo -e "----${YELLOW}kernel->assembled${DEFAULT}----"


cd programs

for i in *.asm
do
	nasm -O0 -w+orphan-labels -f bin $i -o `basename $i .asm`.bin || exit
done

cd ..
echo -e "---${YELLOW}programs->assembled${DEFAULT}---"


dd status=noxfer conv=notrunc if=bootloader/bootloader.bin of=disk_images/tomos.flp &> /dev/null|| exit 
rm -rf tmp-loop
echo -e "-----${YELLOW}bootloader->MBR${DEFAULT}-----"


mkdir tmp-loop && mount -o loop -t vfat disk_images/tomos.flp tmp-loop && cp kernel/kernel.bin tmp-loop/ &> /dev/null
cp programs/*.bin tmp-loop
sleep 0.2

umount tmp-loop || exit

echo -e "------${YELLOW}files->floppy${DEFAULT}------"
rm -rf tmp-loop
rm -f disk_images/tomos.iso
mkisofs -quiet -V 'TOMOS' -input-charset iso8859-1 -o disk_images/tomos.iso -b tomos.flp disk_images/ || exit


echo -e "-------${YELLOW}ISO created${DEFAULT}-------"
echo -e "---${YELLOW}${UNDERLINE}TomOS ready to boot${DEFAULT}---"
echo -e "${BLUE}Continue and start VM?${GREEN}y/n"
read -n 1 INPUT
echo -e "\n${DEFAULT}"
if [ "$INPUT" = "y" ]; then 
VBoxManage controlvm "TomOS" poweroff &> /dev/null
sleep 0.5
VBoxManage startvm "TomOS" &> /dev/null
else
if [ "$INPUT" = "y" ]; then
VBoxManage controlvm "TomOS" poweroff &> /dev/null
sleep 0.5
VBoxManage startvm "TomOS" &> /dev/null
fi
fi

