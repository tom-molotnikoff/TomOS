; Command line interface---------------------------------------------------------------------------------------------
; Jumped to after start screen is finished - Manages commmands
command_line:
        call tomos_clear_registers
        mov dh, 0
        mov dl, 0
        call tomos_set_cursor
        mov si, start_string_command_line       ; Move the "Welcome to TomOS" into the SI
        call tomos_print_string_with_delay      ; Print the string in the SI with a delay
        mov dh, 1                               ; Move the cursor down 1 row
        mov dl, 0                               ; Move the cursor back to left hand side
        call tomos_set_cursor
        mov si, tomos_cli_help
        call tomos_print_string
        add dh, 1                               ; Move the cursor down 1 row
        mov dl, 0                               ; Move the cursor back to left hand side
        call tomos_set_cursor
        mov si, tomos_cli_help1
        call tomos_print_string
        add dh, 1                               ; Move the cursor down 1 row
        mov dl, 0                               ; Move the cursor back to left hand side
        call tomos_set_cursor
        mov al, 3Eh
        mov cx, 1
        call tomos_print_char_inc_cursor
        
typing_loop_command_line:
        call tomos_wait_for_key                 ; Wait for a keypress, ASCII code is returned in AL, Scan code in AH
        mov [tomos_inp_char], ah
        



cmp_enter_command_line:
        cmp ah, 1Ch                             ; Compare scan code of key-in with enter key
        je .check_syntax_commmand_line              ; If equal to enter key, jump to enter key procedure
        jmp .cmp_backspace_command_line
.check_syntax_commmand_line:
        call tomos_get_cursor
        sub dl, 1
        mov [input_length], dl
        mov dl, 5
        call tomos_set_cursor
        call tomos_read_char
        cmp al, 20h
        jne .inc_syntax_command_line
.loop_check_syntax:
        sub dl, 1
        call tomos_set_cursor
        call tomos_read_char
        cmp al, 20h
        je .inc_syntax_command_line
        cmp dl, 0
        jne short .loop_check_syntax
        jmp .create_input_var_command_line
 .inc_syntax_command_line:
        add dh, 1
        mov dl, 1
        call tomos_set_cursor
        mov si, tomos_syntax_error
        call tomos_print_string
        call tomos_command_line_newline
        jmp typing_loop_command_line
.create_input_var_command_line:
         call tomos_get_cursor
         mov dl, 0
         
.loop_input_var_command_line:
         add dl, 1
         call tomos_set_cursor
         call tomos_read_char
         mov si, tomos_cli_line
         call tomos_append_to_string 
         
         cmp dl, [input_length]
         jne .loop_input_var_command_line
 .compare_commands:
         call tomos_command_line_newline
         call tomos_empty_key_buffer
         jmp typing_loop_command_line
         
                                                     ;help, rebt, cscr, 
        
        

.cmp_backspace_command_line:
        cmp ah, 0Eh                             ; Compare scan code of key-in with backspace 
        jne .output_char_command_line           ; If not equal to backspace
        pusha                                   ; Assuming we are now dealing with backspace, so save registers
        call tomos_get_cursor
        cmp dl, 1                               ; Check if cursor is already at start
        je .cmp_backspace_finish_command_line   ; If yes, skip the rest, backspace will do nothing
        sub dl, 1                               ; Else, minus 1 from cursor column (moves left once)
        call tomos_set_cursor
        mov al, 20h                               ; ASCII code for space
        mov cx, 1                               ; Print once
        call tomos_print_char_inc_cursor
        call tomos_get_cursor
        sub dl, 1                               ; Move cursor back one column
        call tomos_set_cursor
.cmp_backspace_finish_command_line:
        popa                                    ; Restore registers
        jmp typing_loop_command_line     ; Jump back to take more input
.output_char_command_line:                      ; Arrives here if the key is not any of the above
        call tomos_get_cursor
        cmp dl, 17                              ; Check if cursor at end of line
        je typing_loop_command_line            ; If yes, jump to the handler
        mov cx, 1                               ; Else, print character from keypress once
        call tomos_print_char_inc_cursor
        jmp typing_loop_command_line     ; Jump back to take more inputs


;---------------------------------------------------------------------------------------------------------------------------
 call tomos_kernel_panic                        ; Should the kernel reach this line, the flow of the OS is wrong and therefore must reboot
start_string_command_line dw '>Welcome to TOM_OS', 0
end_of_line_error_command_line dw '  END OF LINE!  ', 0
tomos_cli_help dw '>Command syntax: [Command] "[Parameters]"',0
tomos_syntax_bangin dw 'syntax bangin', 0
tomos_syntax_error dw 'Syntax error, commands are 4 letters long starting at byte 0.', 0
tomos_cli_help1 dw '>Possible commands are: HELP',0
tomos_help dw 'help',0
input_length db 0
tomos_cli_line dw '',0
tomos_inp_char db '', 0