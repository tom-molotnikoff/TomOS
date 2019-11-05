; Keyboard functions ------------------------------------------------------------------------------------------------
; Wait for key - Scan code out ah, ASCII out al
; Waits for a keypress
tomos_wait_for_key:
    mov ah, 00h                                 ; BIOS func for wait for keypress
    int 16h                                     ; Keyboard services interrupt
    ret                                         ; Return
;--------------------------------------------------------------------------------------------------------------------
; Check for key - Scan code out ah, ASCII out al
; Checks if a key has been pressed, useful if you don't need to wait for input
tomos_check_for_key:
    mov ah, 01h                                 ; BIOS func for check keyboard buffer
    int 16h                                     ; Keyboard services interrupt
    jz .finish_check_for_key                    ; If no key in buffer, finish
    mov ah, 00h                                 ; Else, get key out of buffer
    int 16h                                     ; Keyboard services interrupt
.finish_check_for_key:
    ret                                         ; Return
;--------------------------------------------------------------------------------------------------------------------
; Empty Keyboard buffer
; Cycles through the keyboard buffer until empty
tomos_empty_key_buffer:
    pusha
    .loop_key_buffer:
    mov ah, 01h
    int 16h
    jz .finish_key_buffer
    mov ah, 00h
    int 16h
    jmp short .loop_key_buffer
.finish_key_buffer:
    popa 
    ret
jmp tomos_kernel_panic                         ; Should the kernel reach this line, the flow of the OS is wrong and therefore must reboot