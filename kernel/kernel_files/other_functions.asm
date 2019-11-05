; Other functions -----------------------------------------------------------------------------------------------------
; Waits for a small amount of time - Only really used in the start up screen
tomos_short_preset_wait:
        pusha                                   ; Save registers
        mov ah, 86h                             ; BIOS wait function
        mov cx, 1                               ; Time to wait
        int 15h                                 ; Begin delay
        popa                                    ; Restore registers
        ret                                     ; Return
        jmp tomos_kernel_panic
;-------------------------------------------------------------------------------------------------------------------
; Waits for any amount of time - IN CX(high),DX(low) amount of time to wait in microseconds
tomos_wait:
        pusha                                   ; Save registers
        mov ah, 86h                             ; BIOS wait function
        int 15h                                 ; Begin delay
        popa                                    ; Restore registers
        ret                                     ; Return
        jmp tomos_kernel_panic
;-------------------------------------------------------------------------------------------------------------------
; Clears the 4 data registers
tomos_clear_registers:
        mov ax, 0                               ; Clear AX
        mov bx, ax                              ; Clear BX
        mov cx, ax                              ; Clear CX
        mov dx, ax                              ; Clear DX
        ret                                     ; Return
        jmp tomos_kernel_panic
;-------------------------------------------------------------------------------------------------------------------
; Reboots the system
; CX = 0 for software reboot, = 1 for hardware reboot
tomos_reboot:
        pusha
        mov bh, 0xF0
        call tomos_clear_screen_color
        mov dh, 12
        mov dl, 32
        call tomos_set_cursor
        mov bl, 10000000b
        mov si, reboot_string
        call tomos_print_string_with_delay
        mov cx, 25
        call tomos_wait
        mov si, cover_message
        mov dh, 12
        mov dl, 32
        call tomos_set_cursor
        call tomos_print_string_with_delay
        popa

        cmp cx, 1
        je .hardware_reboot
.software_reboot:
        call tomos_clear_registers
        jmp tomos_main
.hardware_reboot:
        mov ax, 0
        mov bx, ax
        mov cx, ax
        mov dx, ax
        mov ds, ax
        mov es, ax
        mov fs, ax
        mov gs, ax
        mov ss, ax
        mov si, ax
        mov di, ax
        mov bp, ax
        mov sp, ax
        int 19h
        jmp tomos_kernel_panic
        reboot_string db "REBOOTING SYSTEM",0
        cover_message db "                ",0
;-------------------------------------------------------------------------------------------------------------------
tomos_kernel_panic:
        mov ah, 00h
        mov al, 03h
        int 10h
        mov bl, 01000000b
        mov dh, 0
        mov dl, 0
        call tomos_set_cursor
        mov si, 80
        mov di, 25
        call tomos_draw_block
        mov dh, 0
        mov dl, dh
        call tomos_set_cursor
        mov si, error_kernel_panic
        call tomos_print_string
        mov cx, 100
        call tomos_wait
        mov ax, 0
        mov bx, 0
        mov cx, 0
        mov dx, 0
        mov ds, ax
        mov es, ax
        mov fs, ax
        mov gs, ax
        mov ss, ax
        mov si, ax
        mov di, ax
        mov bp, ax
        mov sp, ax
        int 19h
        error_kernel_panic dw "FATAL OS ERROR - REBOOT", 0
        
jmp tomos_kernel_panic                         ; Should the kernel reach this line, the flow of the OS is wrong and therefore must reboot