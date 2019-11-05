BITS 16                                         ; Tells NASM that this is only using 16bit x86

        %DEFINE TOMOS_VER '1.0'                 ; OS version
        disk_buffer equ 24576                   ; Disk buffer location to read into and write from
        
tomos_kernel_int_vectors:

        jmp tomos_main                          ; 0000h - Called from bootloader to jump to kernel start
        jmp tomos_print_string_with_delay       ; 0003h - Prints string with small delay after each character, string in SI register ending in 0
        jmp tomos_print_string                  ; 0006h - Prints string in SI register - String must end with 0          
        jmp tomos_print_char_inc_cursor         ; 0009h - Prints character in AL register CX-times, updates cursor
        jmp tomos_shutdown                      ; 000Ch - Sets the power state to off for all devices
        jmp tomos_set_cursor                    ; 000Fh - Sets the cursor, takes in the row(DH) and column(DL)
        jmp tomos_wait_for_key                  ; 0012h - Waits for a keypress, returns ASCII and scan code in AX
        jmp tomos_check_for_key                 ; 0015h - Checks for a key in buffer, if present, returns ASCII and scan code in AX
        jmp tomos_short_preset_wait             ; 0018h - Waits for a short amount of time, used mostly by start screen
        jmp tomos_draw_block                    ; 001Bh - Draws a block(BL=colour (highnibble=background lownibble = foreground)|dh/dl starting cursor|SI=width|DI=ending row)
        jmp tomos_error_middle                  ; 001Eh - Message in SI, draws error box in middle and types text (Text should be 16 characters long)
        jmp tomos_string_length                 ; 0021h - String in SI, returns the length in CL
        jmp tomos_read_char                     ; 0024h - Reads the character at the cursor location, returns ASCII in AL
        jmp tomos_wait                          ; 0027h - Time in CX, halts the computer for that time
        jmp tomos_newline                       ; 002Ah - Moves the cursor down 1 row
        jmp tomos_clear_screen                  ; 002Dh - Resets the screen mode to clear the screen
        jmp tomos_clear_registers               ; 0030h - Places 0 into all the data registers
        jmp tomos_reboot                        ; 0033h - Reboot the system,CX=1 causes hardware reboot. CX=0 causes software reboot
        jmp tomos_empty_key_buffer              ; 0036h - Emptys the keybuffer - useful prior to taking input
        jmp tomos_separate_string               ; 0039h - Splits a string in half at the first separator byte. Separator byte in AH, String to split in SI, Empty string in DI
        jmp tomos_input_string                  ; 003Ch - Takes a line of input ended by the Enter Key & stores in string - String location in AX
        jmp tomos_clear_screen_color            ; 003Fh - Clears the screen - Takes in background and foreground in BH to set color
        jmp tomos_get_color                     ; 0042h - Retrieves the attributes of the top left space on the screen
        jmp tomos_add_strings                   ; 0045h - Takes in string1 in si, string 2 in di. Appends string2 onto string1
        jmp tomos_APM_check                     ; 0048h - Checks the installation of APM, 1 returned in CX if installed, 0 if not
        jmp tomos_APM_enable                    ; 004Bh - Enables power management on all devices
        jmp tomos_APM_connect                   ; 004Eh - Connects to the APM realmode interface
; ---------------------------------------------------------------------------------------------------------------
; Start of kernel
tomos_main:
        mov ebp, esp                            ; for correct debugging
        mov bp, sp                              ; Stack base and stack pointer have to be set to the same
        cli                                     ; Clear interrupts
        mov ax, 0                               ; Set the stack
        mov ss, ax
        mov sp, 0FFFFh
        sti                                     ; Restore interrupts
        
        mov ax, 2000h                           ; Set segment registers to where we are loaded in RAM
        mov ds, ax                              
        mov es, ax                              ; All registers are set to the same so that offsets can be used
        mov fs, ax
        mov gs, ax                              ; This allows 64kb of RAM
        
        mov byte [boot_device], dl
        ;mov bh, 0x87
        mov bh, 0xF0
        call tomos_clear_screen_color           ; Clear the screen from any text in the bootloader            
        call tomos_draw_welcome                 ; Draw the TOM_OS and "<press__enter>"
        mov bh, 0xF0
        call tomos_clear_screen_color
        
        
        
        
        mov dh, 0                               ; Set cursor back to top left corner
        mov dl, 0
        call tomos_set_cursor
        
        call tomos_clear_screen                 ; Clear the screen and data registers
        call tomos_clear_registers              
        
        jmp tomos_command_line                  ; Jump to start of commandline.asm
; Variables ------------------------------------------------------------------
        boot_device db 0
        program_location dw 32768
        testtest db "test.asm", 0
jmp tomos_kernel_panic
        %INCLUDE "kernel/kernel_files/keyboard_functions.asm"
        %INCLUDE "kernel/kernel_files/string_functions.asm"
        %INCLUDE "kernel/kernel_files/commandline.asm"
        %INCLUDE "kernel/kernel_files/screen_functions.asm"
        %INCLUDE "kernel/kernel_files/other_functions.asm"
        %INCLUDE "kernel/kernel_files/start_screen.asm"
        %INCLUDE "kernel/kernel_files/commandline_functions.asm"
        %INCLUDE "kernel/kernel_files/disk_functions.asm"
        %INCLUDE "kernel/kernel_files/apm_functions.asm"
        