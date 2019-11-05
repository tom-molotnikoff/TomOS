; Start screen -----------------------------------------------------------------------------------------------------      
; Draws the TOM_OS at the start and houses the "<press__enter>" flashing function
tomos_draw_welcome:
        
        pusha
        mov dh, 9
        call tomos_set_cursor
        mov si, line_1_first
        call tomos_print_string
                call tomos_short_preset_wait
        add dh, 1
        call tomos_set_cursor
        mov si, line_2_first
        call tomos_print_string
                call tomos_short_preset_wait
        add dh, 1
        call tomos_set_cursor
        mov si, line_3_first
        call tomos_print_string
                call tomos_short_preset_wait
        add dh, 1
        call tomos_set_cursor
        mov si, line_4_first
        call tomos_print_string    
        call tomos_short_preset_wait
        add dh, 1
        call tomos_set_cursor

        mov si, line_5_first
        call tomos_print_string    
        call tomos_short_preset_wait
        add dh, 1
        call tomos_set_cursor

        mov si, line_6_first
        call tomos_print_string    
        call tomos_short_preset_wait
        add dh, 1
        call tomos_set_cursor

        mov si, line_7_first
        call tomos_print_string    
        call tomos_short_preset_wait
        add dh, 1
        call tomos_set_cursor

        mov dl, 33
        add dh, 3
        call tomos_set_cursor
        mov si, message
        call tomos_print_string
        
.wait_for_enter:        
        mov ah, 01h
        int 16h
        jnz .key_in_buffer
        call blink
        jmp .wait_for_enter
.key_in_buffer:
        mov ah, 00h
        int 16h
        cmp al, 13
        jz .enter_key
        jmp .wait_for_enter
.enter_key:
        popa
        ret  
blink:
        mov dl, 33
        mov dh, 19
        call tomos_set_cursor
        mov si, blank_message
        call tomos_print_string
        mov cx, 10                              ; Time to wait
        call tomos_wait
        mov si, message
        call tomos_set_cursor
        call tomos_print_string
        mov cx, 10                              ; Time to wait
        call tomos_wait
        ret
jmp tomos_kernel_panic                         ; Should the kernel reach this line, the flow of the OS is wrong and therefore must reboot

line_1_first dd "           00000000    0000    000  000              0000     00000             ", 0
line_2_first dd "              00      0    0   000  000             0    0   00    0            ", 0
line_3_first dd "              00     0      0  0 0000 0            0      0   00                ", 0
line_4_first dd "              00     0      0  0  00  0            0      0     0               ", 0
line_5_first dd "              00     0      0  0      0            0      0      00             ", 0
line_6_first dd "              00      0    0   0      0             0    0   0    00            ", 0
line_7_first dd "              00       0000    0      0  000000000   0000     00000             ", 0

message dw "<press  enter>", 0
blank_message dw "              ", 0