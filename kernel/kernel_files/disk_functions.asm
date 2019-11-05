;Takes IN filename in SI, Location to load to in CX
tomos_load_file:
        ; Read all the root directory into the buffer
        ; There are 224 root entries
        ; Each is 32 bytes long
        ; 224 * 32 = 7168 bytes total
        ; Each sector is 512 bytes large
        ; 7168/512 = 14 sectors
        ; So i have to read 14 sectors starting at ??
        ; 1 sector is reserved for the bootloader
        ; There are 2 FATs
        ; Each is 9 sectors
        ; 9*2+1 = 19
        ; Starting at sector 19 i have to read 14 sectors into the disk buffer
        ; I need to calculate the other parameters of the disk
        ; Sectors per side = 1440
        ; Sectors per track = 18
        ; We have to add 1 to the starting sector because there is no sector 0
        ; Given a sector number -> divide by 18 to get the track
        ; Ignore the remainder
        ; Given a sector number -> divide by 2 to get the head
        ; To get sector number from 19 -> divide by 18 and add one
        ; Before we do anything, we must separate the filename and extension
        mov [filename_location], si
        mov [load_location], cx
        mov di, extension
        mov ah, "."
        call tomos_separate_string
        ; Now i have 2 strings, 1 with the filename (less than or equal to 8 characters long)
        ; Another containing 3 letter extension
        ; The next job is to pad the filename out to be 8 characters

        mov ax, [filename_location]
        add ax, 9
        mov si, ax
        mov byte [si], 0
        mov ax, extension
        add ax, 4
        mov si, ax
        mov byte [si], 0
        mov ax, [filename_location]
        mov si, ax
        mov di, extension
        
        
        call tomos_string_length
        mov ah, 0
        add si, ax
        cmp al, 8
        je .got_two_strings
        mov ah, 8
        sub ah, al

        mov al, " "
.loop_append_to_string:
        call tomos_append_to_string
        sub ah, 1
        cmp ah, 0
        je .got_two_strings
        jmp short .loop_append_to_string

        ; At this point, there is a string called extension, which contains a 3 letter extension
        ; And a string called filename_location, which contains the location of the 8 letter long filename
        ; I want to have a single string that contains the 8byte filename and the 3byte extension

.got_two_strings:
        mov si, [filename_location]
        mov di, extension
        call tomos_add_strings
        ; Now i have 1 filename and extension that is 11 bytes long
    
.read_root_dir:
        pusha
        
        mov ax, 19
        call tomos_floppy_interrupt
        
        mov ah, 02h
        mov al, 14
        mov si, disk_buffer
        mov bx, si
        int 13h
        
        popa
        mov di, disk_buffer
        mov si, [filename_location]
        mov cx, 11
        mov ax, 0 ; Offset
        mov dl, 224
.search_buffer:
        ; Now the root sectors are in the disk buffer in RAM
        ; Each entry is 32 bytes long
        ; The first 11 bytes is the filename and extension
        ; The total length of root is 7168 bytes
        ; We also have the filename in the SI and the length in the CX
        rep cmpsb
        jnc .found_file
        sub dl, 1
        add ax, 32
        mov di, disk_buffer
        add di, ax
        cmp dl, 0
        je .file_not_found
        jmp .search_buffer
        ; We want to loop this, 224 times  
.file_not_found:
        popa
        mov cx, 1
        ret
                 
.found_file:
        ; Now i have to root entry for the file i am trying to load
        ; I can find the first logical sector of the file in the 26th byte of the root entry, we are currently pointing at 11th byte
        ; I need to get 2 bytes starting at the 26th
        mov ax, word [di + 0fh]
        mov word [sector], ax
        
        ; I am loading this to the [load_location]
        ; But first i need an FAT loop to load all the sectors at once
        ; I have all the info i need from the root directory
        ; Now i can read the FAT from the disk.
.load_FAT:
        pusha
        mov ax, 1
        call tomos_floppy_interrupt
        mov ah, 2 
        mov cl, 9
        mov si, disk_buffer
        mov bx, si
        int 13h
        popa
        ; The FAT is now loaded into the buffer
        ; I can now begin searching through for the FAT entries
.load_sector:
        mov ax, word [sector]
        add ax, 31
        call tomos_floppy_interrupt
        mov si, [load_location]
        mov ah, 02
        mov al, 01
        int 13h
        ; The first sector is now loaded into the load location, now we have to find the FAT entry for that sector
        
.next_sector:
        mov ax, [sector]
        mov bx, 3
	mul bx
	mov bx, 2
	div bx				; DX = [CLUSTER] mod 2
	mov si, disk_buffer		; AX = word in FAT for the 12 bits
	add si, ax
	mov ax, word [si]

	or dx, dx			; If DX = 0 [CLUSTER] = even, if DX = 1 then odd

	jz .even			        ; If [CLUSTER] = even, drop last 4 bits of word
					; with next cluster; if odd, drop first 4 bits

.odd:
	shr ax, 4			; Shift out first 4 bits (belong to another entry)
	jmp .calculate_cluster_cont	; Onto next sector!

.even:
	and ax, 0FFFh			; Mask out top (last) 4 bits

.calculate_cluster_cont:
	mov word [sector], ax		; Store cluster

	cmp ax, 0FF8h
	jae .end

	add word [load_location], 512
	jmp .next_sector


.end:
	ret

        
        load_location db 0 
        
; Takes logical sector in AL
; Returns all necessary registers for int 13h            
tomos_floppy_interrupt:
        
        push ax
        
        
        push ax
        mov dx, 0
        div word [SectorsPerTrack]
        add dl, 01h
        mov cl, dl
        mov dx, 0
        
        pop ax
        push ax
        div word [SectorsPerTrack]
        mov ch, dl
        mov dx, 0
        
        pop ax
        div word [Sides]
        mov dh, al
        
        pop ax
        
        mov dl, [boot_device]
        
        ret

        
OEMLabel    		db "TOM___OS"	; Disk label
BytesPerSector		dw 512		; Bytes per sector
SectorsPerCluster	db 1		; Sectors per cluster
ReservedForBoot		dw 1		; Reserved sectors for boot record
NumberOfFats		db 2		; Number of copies of the FAT
RootDirEntries		dw 224		; Number of entries in root dir
					; (224 * 32 = 7168 = 14 sectors to read)
LogicalSectors		dw 2880		; Number of logical sectors
MediumByte		db 0F0h		; Medium descriptor byte
SectorsPerFat		dw 9		; Sectors per FAT
SectorsPerTrack		dw 18		; Sectors per track (36/cylinder)
Sides			dw 2		; Number of sides/heads
HiddenSectors		dd 0		; Number of hidden sectors
LargeSectors		dd 0		; Number of LBA sectors
DriveNo			dw 0		; Drive No: 0
Signature		db 41		; Drive signature: 41 for floppy
VolumeID		        dd 00000000h	; Volume ID: any number
VolumeLabel		db "TOMOS      "; Volume Label: any 11 chars
FileSystem		db "FAT12   "	; File system type: don't change!

filename_location dw 0
extension dw 0
sector db 0
        
        
        