BITS 16
os_welcome_screen:
        pusha
        jmp .draw_pipe
.done_pipe:
        sub dh, 7               ; Prep cursor for T
        add dl, 3
        call set_cursor1

        jmp .draw_T
.done_T:
        add dl, 1
        add dh, 1
        call set_cursor1
        mov ch, 4
        jmp .draw_O
.done_O:
        add dl, 1
        call set_cursor1
        mov ch, 2
        mov bl, 2
jmp $
;-------------------------------------------------------------------------------------------------
;-------------------------------------------------------------------------------------------------
.draw_pipe:
        mov dh, 8               
        mov dl, 1
        call set_cursor1
        call write_char         ; Sorts missing 0 in top left of |
        mov dh, 9
        mov dl, 1
        call set_cursor1
        mov ch, 7               ; Loop counters (8 columns, 7 rows)
        mov cl, 6
        jmp .repeat_pipe
.repeat_pipe:   
        cmp cl, 0               ; Check if 7 downwards is done
        jz .done_column         ; If yes, move to next column
        add dh, 1               ; Else increment row and write 0
        call write_char
        call set_cursor1      
        sub cl, 1               ; Minus one from row counter
        jmp .repeat_pipe
.done_column:
        cmp ch, 0               ; Check if 8 sideways is done
        jz .done_pipe           ; If yes, finish |
        add dl, 1               ; Else increment column
        sub dh, 7               ; Reset column
        pusha                   ; Delay before setting column
        mov cx, 001               ; 10ms ish
        mov ah, 86h             ; Delay function
        int 15h
        popa
        call set_cursor1         
        sub ch, 1               ; Column loop counter
        mov cl, 7               ; Reset row loop counter 
        jmp .repeat_pipe
;-------------------------------------------------------------------------------------------------
;-------------------------------------------------------------------------------------------------
.draw_T:
        call write_char
        mov cl, 3
        jmp .repeat_T_top_start 
.repeat_T_top_start:
        cmp cl, 0
        jz .draw_T_middle
        call write_char
        add dl, 1
        sub cl, 1
        pusha                   ; Delay before setting column
        mov cx, 001               ; 10ms ish
        mov ah, 86h             ; Delay function
        int 15h
        popa
        call set_cursor1
        jmp .repeat_T_top_start
.draw_T_middle:
        mov cl, 7
        mov ch, 1
        jmp .repeat_T_middle
.repeat_T_middle:
        cmp cl, 0
        jz .T_middle_next_row
        call write_char
        sub cl, 1
        add dh, 1
        call set_cursor1
        jmp .repeat_T_middle
.T_middle_next_row:
        cmp ch, 0
        jz .T_top_end
        sub dh, 7
        pusha                   ; Delay before setting column
        mov cx, 001               ; 10ms ish
        mov ah, 86h             ; Delay function
        int 15h
        popa
        add dl, 1
        call set_cursor1
        call write_char
        sub ch, 1
        mov cl, 7
        jmp .repeat_T_middle
.T_top_end:
        sub dh, 7
        add dl, 1
        call set_cursor1
        mov cl, 3
        jmp .repeat_T_top_end 
.repeat_T_top_end:
        cmp cl, 0
        jz .done_T
        pusha                   ; Delay before setting column
        mov cx, 001               ; 10ms ish
        mov ah, 86h             ; Delay function
        int 15h
        popa
        call write_char
        add dl, 1
        sub cl, 1
        call set_cursor1
        jmp .repeat_T_top_end
;-------------------------------------------------------------------------------------------------
;-------------------------------------------------------------------------------------------------
.draw_O:
        add dl, 1
        add dh, 1
        call set_cursor1
        call write_char
        add dh, 1
        call set_cursor1
        call write_char
        add dh, 1
        call set_cursor1
        call write_char
        sub dh, 3
        add dl, 1
        call set_cursor1
        cmp ch, 0
        jnz .O_middle
        jmp .done_O
.O_middle:        
        pusha                   ; Delay before setting column
        mov cx, 001               ; 10ms ish
        mov ah, 86h             ; Delay function
        int 15h
        popa
        call write_char
        add dh, 4
        call set_cursor1
        call write_char
        sub dh, 4
        call set_cursor1
        cmp ch, 0
        jz .draw_O
        jmp .prerepeat_O_middle
.prerepeat_O_middle:
        sub dh, 1
        add dl, 1
        call set_cursor1
        jmp .repeat_O_middle
.repeat_O_middle:
        cmp ch, 0
        jz .after_O_middle
        pusha                   ; Delay before setting column
        mov cx, 001               ; 10ms ish
        mov ah, 86h             ; Delay function
        int 15h
        popa
        call write_char
        add dh, 6
        call set_cursor1
        call write_char
        sub dh, 6
        add dl, 1
        call set_cursor1
        sub ch, 1
        jmp .repeat_O_middle
.after_O_middle:
        add dh, 1
        call set_cursor1
        jmp .O_middle
;-------------------------------------------------------------------------------------------------
;-------------------------------------------------------------------------------------------------        

set_cursor1:                     ;IN - DH=row DL=column | regs preserved
    pusha
    mov bh, 0
    mov ah, 02h
    int 10h
    popa
    ret
write_char:                     ;IN - AL=ASCII of char | regs preserved
    pusha
    mov al, 30h
    mov cx, 001h
    mov bh, 00h
    mov ah, 09h
    int 10h
    popa
    ret

