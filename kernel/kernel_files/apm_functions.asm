;-------------------------------------------------------------------------------------------------------------------
; APM installation check
tomos_APM_check:
        pusha
        mov ax, 53h                              ; APM function
        mov al, 00h                              ; Check installation function
        mov bx, 0000h                            ; Device no.
        int 15h
        popa
        ret                                      ; Return
        jmp tomos_kernel_panic
;-------------------------------------------------------------------------------------------------------------------
tomos_APM_connect:
        pusha                                    ; Save registers
        mov ah, 53h                              ; APM function
        mov al, 01h                              ; Real mode interface
        mov bx, 0000h                            ; Device no.
        int 15h
        popa                                     ; APM running on real mode driver
        ret                                      ; Restore registers and return
        jmp tomos_kernel_panic
;-------------------------------------------------------------------------------------------------------------------
tomos_APM_enable:
        pusha                                    ; Save registers
        mov ah, 53h                              ; APM function
        mov al, 08h                              ; Enable/Disable power management function
        mov bx, 0001h                            ; ALL devices
        mov cx, 0001h                            ; Turn on power management
        int 15h
        popa                                     ; Power states for all devices can now be changed
        ret                                      ; Restore registers and return
        jmp tomos_kernel_panic
;-------------------------------------------------------------------------------------------------------------------
tomos_shutdown:
        
        ;call tomos_APM_check
        ;jc .no_apm_return
        call tomos_APM_connect
        call tomos_APM_enable
        pusha
        mov bh, 0xF0
        call tomos_clear_screen_color
        mov dh, 12
        mov dl, 33
        call tomos_set_cursor
        mov bl, 10000000b
        mov si, shutdown_string
        call tomos_print_string_with_delay
        mov cx, 25
        call tomos_wait
        mov si, shutdown_cover
        mov dh, 12
        mov dl, 33
        call tomos_set_cursor
        call tomos_print_string_with_delay
        popa
        mov ah, 53h
        mov al, 07h
        mov bx, 0001h
        mov cx, 03h
        int 15h
        jmp tomos_kernel_panic
.no_apm_return:
        pusha
        mov si, no_apm_msg
        call tomos_newline
        call tomos_print_string
        popa
        ret
        jmp tomos_kernel_panic
        no_apm_msg dw "APM not supported! Unable to shutdown", 0
        shutdown_string dw "CLOSING SYSTEM", 0
        shutdown_cover dw "              ", 0
