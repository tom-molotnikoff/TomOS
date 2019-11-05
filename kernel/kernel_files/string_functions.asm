; String Functions -----------------------------------------------------------------------------------------------------      
; Print string with delay - String in SI register, adds delay
tomos_print_string_with_delay:                          
        pusha                                   ; Save registers
        mov ah, 0Eh                             ; BIOS print function
.loop_print_string_delay:
        lodsb                                   ; Loads the next character from SI register into the AL
        cmp al, 0                               ; Check if at the end of string (string ends with 0)
        je .finish_print_string_delay           ; If yes, jump to return
        int 10h                                 ; Else, print the character in the AL
        pusha                                   ; Save registers as delay interrupt alters them
        mov ah, 86h                             ; BIOS wait function    
        mov cx, 1                               ; Time to wait
        int 15h                                 ; Begin the delay
        popa                                    ; Restore registers
        jmp short .loop_print_string_delay      ; Repeat until end of string
.finish_print_string_delay:
        popa                                    ; Restore registers from before function
        ret                                     ; Return
        jmp tomos_kernel_panic
;-------------------------------------------------------------------------------------------------------------------
; Print string - String in SI register
tomos_print_string:                          
        pusha                                   ; Save registers
        mov ah, 0Eh                             ; BIOS print function
.loop_print_string: 
        lodsb                                   ; Load next character in SI register into the AL
        cmp al, 0                               ; Check if at end of string
        je .finish_print_string                 ; If yes, jump to return
        int 10h                                 ; Else, print the character
        jmp short .loop_print_string            ; Repeat until end of string
.finish_print_string:
        popa                                    ; Restore registers
        ret                                     ; Return
        jmp tomos_kernel_panic
;-----------------------------------------------------------------------------------------------------------------------       
; Print character and increment cursor - Takes character in al register, no. times to print in cx
; Prints a character x times and moves the cursor to the next blank space
tomos_print_char_inc_cursor:
        pusha                                   ; Save registers
        mov ah, 09h                             ; Print character at cursor location
        mov bh, 0                               ; Page number
        mov bl, 0111b                           ; Colour
        int 10h                                 ; Print the character x-times
        popa                                    ; Reset registers
        pusha
.loop_print_char:
        cmp cx, 0                               ; Check if cursor needs to be moved
        je .finish_print_char                   ; If yes, jump to return
        push cx                                 ; Save CX (number of times to move cursor)
        call tomos_get_cursor
        cmp dl, 79                              ; Check if cursor is at end of line (80x25)
        je .new_line_print_char                 ; If yes, jump to new line
        add dl, 1                               ; Else, move the cursor along one space
        mov ah, 02h                             ; Set cursor
        int 10h
        pop cx                                  ; Restore CX
        sub cx, 1                               ; Decrement the CX
        jmp short .loop_print_char              ; Repeat until CX is equal to zero
.new_line_print_char:
        mov dl, 0                               ; Cursor back to left hand side
        add dh, 1                               ; Cursor down one line
        call tomos_set_cursor
        pop cx                                  ; Restore CX
        sub cx, 1                               ; Decrement CX
        jmp short .loop_print_char              ; Repeat until CX is equal to zero
.finish_print_char:
        popa                                    ; Restore registers
        ret                                     ; Return
        jmp tomos_kernel_panic
;----------------------------------------------------------------------------------------------------------------------
; Read character - Reads the character at the cursor position
; Returns the character in AL
tomos_read_char:
        pusha                                   ; Save registers
        mov ah, 08h                             ; Read character at cursor function
        mov bh, 0                               ; Page number
        int 10h                                 ; Text service interrupt
        mov [tmp_char], al                      ; Save the ASCII code of the character to tmp_char
        popa                                    ; Restore registers
        mov al, [tmp_char]                      ; Put ASCII code back into AL
        ret                                     ; Return
        jmp tomos_kernel_panic
        tmp_char db 0
;----------------------------------------------------------------------------------------------------------------------
; Finds the length of a zero-terminated string
; String in SI
; Length returned in AL
tomos_string_length:
        pusha                                   ; Save registers
        mov cl, 0                               ; Length counter to zero
.loop_string_length:
        lodsb                                   ; Load next character from string in SI into AL
        cmp al, 0                               ; Check if end of string
        je .finish_string_length                ; If yes, jump to end
        add cl, 1                               ; Else, increment the length counter
        jmp short .loop_string_length           ; Repeat
.finish_string_length:
        mov [tmp_length], cl                    ; Save length counter to tmp_length
        popa                                    ; Restore registers
        mov al, [tmp_length]                    ; Put final length back into CL
        ret                                     ; Return
        jmp tomos_kernel_panic
        tmp_length db 0  
;----------------------------------------------------------------------------------------------------------------------
; Write character to string
; String in SI, character in AL
; AL will be appended to end of SI and zero terminated
tomos_append_to_string:
        pusha
.loop_append_to_string:
        cmp byte [si], 0
        je .found_end_append_to_string
        inc si
        jmp short .loop_append_to_string
.found_end_append_to_string:
        mov byte [si], al
        inc si
        mov byte [si], 0
        popa
        ret
        jmp tomos_kernel_panic
 ;----------------------------------------------------------------------------------------------------------------------
 ; Remove the end of a string
 ; String in SI, Number of characters to keep in cx
 ; Moves the zero terminator to the byte after the SI+CX
 tomos_remove_end_string:
        pusha                                   ; Save registers
        call tomos_string_length
        cmp ax, cx
        jge .remove_end_panic
        add si, cx                              ; Skip the characters that are to be kept
        mov byte [si], 0                        ; Write the zero terminator to the byte after the last needed character
        popa                                    ; Restore registers
        ret
.remove_end_panic:
        call tomos_kernel_panic
;----------------------------------------------------------------------------------------------------------------------
; Compare two strings of equal length
; Strings in SI/DI
tomos_compare_strings:
        pusha        
.loop_compare_strings:
        mov cl, [si]
        mov dl, [di]
        cmp cl, dl
        jne .not_equal_compare_strings
        cmp cl, 0
        je .equal_compare_strings
        inc di
        inc si
        jmp .loop_compare_strings
.not_equal_compare_strings:
        popa
        mov cx, 0
        ret
.equal_compare_strings:
        popa
        mov cx, 1
        ret
        jmp tomos_kernel_panic

;----------------------------------------------------------------------------------------------------------------------
; Take keyboard input, finished with enter, and store to a string
; String address in AX
tomos_input_string:
        pusha
        mov di, ax
        mov cx, 0
.loop_input_string:
        call tomos_wait_for_key
        cmp al, 13
        je .finished_input_string
        cmp al, 8
        je .backspace_input_string
        cmp al, 32
        jb .loop_input_string
        cmp al, 126
        ja .loop_input_string
.addchar_input_string:
        pusha
        mov ah, 0Eh
        int 10h
        popa
        stosb
        inc cx
        cmp cx, 254
        jae near .finished_input_string
        jmp near .loop_input_string
.backspace_input_string:
        cmp cx, 0
        je .loop_input_string
        cmp cx, 79
        je .secondline_input_string
        dec cx
        dec di
        pusha
        call tomos_get_cursor
        dec dl
        call tomos_set_cursor
        call tomos_get_color
        mov bl, ah
        mov ah, 09h                             ; Print character at cursor location
        mov cx, 1
        mov al, 20h
        mov bh, 0                               ; Page number
        
        
        
        int 10h                                 ; Print the character x-times
        popa      
        jmp .loop_input_string
.secondline_input_string:
        dec cx
        dec di
        pusha
        call tomos_get_cursor
        dec dh
        mov dl, 79
        call tomos_set_cursor
        call tomos_get_color
        mov bl, ah
        mov ah, 09h                             ; Print character at cursor location
        mov cx, 1
        mov al, 20h
        mov bh, 0                               ; Page number

        int 10h       
        popa
        jmp .loop_input_string
.finished_input_string:
        mov ax, 0
        stosb
        popa
        ret
        jmp tomos_kernel_panic
;----------------------------------------------------------------------------------------------------------------------
; Splits a string at a separator character
; String to split in SI, empty string in DI, character to split at in Ah
tomos_separate_string:
        pusha
        mov cx, 0
        push si
.loop_separate_string:
        lodsb                                   
        cmp al, 0                               
        je .done_separate_string
        cmp al, ah             
        je .found_char_separate_string
        add cx, 1                               
        jmp short .loop_separate_string        
.found_char_separate_string:
        cmp byte [si], 0
        je .done_separate_string
        mov dh, [si]
        mov byte [di], dh
        inc di
        inc si
        jmp .found_char_separate_string
.done_separate_string:
        inc di
        mov byte [di], 0
        pop si
        add si, cx
        mov byte [si], 0
        popa
        ret
        jmp tomos_kernel_panic
;---------------------------------------------------------------------------------------------------------------------- 
; String 1 in SI, String 2 in DI - Will add string 2 to the end of string 1
tomos_add_strings:
        pusha
.find_end_add_strings:
        mov al, byte [si]
        cmp al, 0
        je .found_end_add_strings
        inc si
        jmp short .find_end_add_strings
.found_end_add_strings:
        mov bl, byte [di]
        mov byte [si], bl
        
        cmp bl, 0
        je .done_add_strings
        inc di
        inc si
        jmp short .found_end_add_strings
.done_add_strings:
        popa
        ret
jmp tomos_kernel_panic                         ; Should the kernel reach this line, the flow of the OS is wrong and therefore must reboot
