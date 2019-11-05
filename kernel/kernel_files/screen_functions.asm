; Screen functions -----------------------------------------------------------------------------------------------------      
; Set cursor - Takes in the row(DH) and column(DL)
; Updates the cursor position on page 0
tomos_set_cursor:                     
        pusha                                   ; Save registers
        mov bh, 0                               ; Page zero
        mov ah, 02h                             ; BIOS set cursor function
        int 10h                                 ; Set
        popa                                    ; Restore regsiters
        ret                                     ; Return
        jmp tomos_kernel_panic
;-----------------------------------------------------------------------------------------------------------------------
; Get cursor - Returns row(DH) and column(DL)
; All other registers preserved
tomos_get_cursor:
        pusha                                   ; Save registers
        mov ah, 03h                             ; Get cursor position function
        int 10h
        mov [tmp_row], dh                       ; Save row to variable
        mov [tmp_column], dl                    ; Save column to variable
        popa                                    ; Restore all registers
        mov dh, [tmp_row]                       ; Set the DH back to the row
        mov dl, [tmp_column]                    ; Set the DL back to the column
        ret                                     ; Return
        jmp tomos_kernel_panic
        tmp_row db 0                            ; Variable for holding the cursor row while registers are popped
        tmp_column db 0                         ; Variable for holding the cursor column while registers are popped
;-----------------------------------------------------------------------------------------------------------------------
; Displays a 20x5 red error box in the middle of the screen
; Takes string in SI of max length 16 characters (WARINING:will overwrite any text underneath it)
; Pad string with spaces to center it
; Colour in BL (example - RED = mov bl, 01000000b)
tomos_error_middle:
        pusha                                   ; Save registers
        call tomos_get_cursor                   ; Get cursor position
        mov [prev_row], dh                      ; Save cursor position before registers are editted
        mov [prev_column], dl
        call tomos_string_length                ; Get the length of the error string
        cmp al, 16                              ; Check if the string is over 16 characters
        jle .length_ok_error_middle             ; If less than 16 characters, then continue
        mov si, too_long                        ; Else, replace string with blank line
.length_ok_error_middle:
        mov bl, 01000000b                       ; Red background colour
        mov dl, 30                              ; Cursor to starting position
        mov dh, 10
.loop_error_middle:
        call tomos_set_cursor                   
        mov ah, 09h                             ; Print character function
        mov al, ' '                             ; Space (has a no foreground colour)
        mov cx, 20                              ; Width of error box is 20 columns
        mov bh, 0                               ; Page zero
        int 10h                                 ; Print a red line
        call tomos_get_cursor                   ; Get cursor position
        inc dh                                  ; Increment the row
        cmp dh, 15                              ; Check if the row is at the end point
        jne .loop_error_middle                  ; If not, repeat
.write_message_error_middle:                    ; Red box has now been drawn - write error message on middle line
        mov dh, 12                              ; Middle row
        add dl, 2                               ; Box width = 20 | String length = 16 (20-16)/2=2
        call tomos_set_cursor                   ; Set cursor
        call tomos_print_string                 ; Write the string
.finish_error_middle:
        popa                                    ; Restore registers from before the function
        mov dh, [prev_row]                      ; Set the cursor back to where it was at the start
        mov dl, [prev_column]
        call tomos_set_cursor
        ret                                     ; Return
        jmp tomos_kernel_panic
        too_long dw '               '
        prev_row db 0
        prev_column db 0
;-------------------------------------------------------------------------------------------------------------------
; Draw block - Draws a block on the screen of specified size and colour
; dl - Starting column | dh - starting row
; si - width           | di - ending row
; bl - colour(high 4 bits)
tomos_draw_block:
        pusha                                   ; Save registers
.loop_draw_block:
        call tomos_set_cursor                   ; Set cursor to starting position
        mov ah, 09h                             ; Write 1 line
        mov bh, 0
        mov cx, si                              ; Length comes in in SI - move to CX
        mov al, ' '                             ; Blank space
        int 10h
        inc dh                                  ; Increment the row
        mov ax, 0                               ; DI is a 16bit register so has to be compared with another 16bit register
        mov al, dh                              ; We have to move dh into al, then compare the AX with the SI
        cmp ax, di                              ; This checks if we have done the last line
        jne .loop_draw_block                    ; If not, repeat
.done_draw_block:                               ; If yes, pop registers and return
        popa                                    ; Restore registers
        ret                                     ; Return
        jmp tomos_kernel_panic
;-------------------------------------------------------------------------------------------------------------------    
tomos_newline:
        pusha
        mov ah, 0Eh
        mov al, 13
        int 10h
        mov al, 10
        int 10h 
        popa
        ret 
        jmp tomos_kernel_panic
;-------------------------------------------------------------------------------------------------------------------
tomos_clear_screen:
        pusha
        call tomos_get_cursor
        push dx
        mov dh, 0
        mov dl, 0
        call tomos_set_cursor
        mov ah, 08h
        mov bh, 0
        int 10h
        mov bh, ah
        pop dx
        call tomos_set_cursor
        mov ah, 06h
        mov al, 0

        mov cx, 0
        mov dl, 79
        mov dh, 24
        int 10h
        popa
        ret
        jmp tomos_kernel_panic
tomos_clear_screen_color:
        pusha
        mov dh, 0
        mov dl, 0
        call tomos_set_cursor

        
        mov ah, 06h
        mov al, 0
        mov cx, 0
        mov dl, 79
        mov dh, 24
        int 10h

        popa
        ret
        jmp tomos_kernel_panic
tomos_get_color:
        pusha
        call tomos_get_cursor
        push dx
        mov dh, 0
        mov dl, 0
        call tomos_set_cursor
        mov ah, 08h
        mov bh, 0
        int 10h
        mov bh, ah
        pop dx
        call tomos_set_cursor
        mov [.tmp_color], ah
        popa
        mov ah, [.tmp_color]
        ret
        jmp tomos_kernel_panic
.tmp_color db 0
jmp tomos_kernel_panic                         ; Should the kernel reach this line, the flow of the OS is wrong and therefore must reboot
        