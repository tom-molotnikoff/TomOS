; Set cursor - Takes in the row(DH) and column(DL)
; Updates the cursor position on page 0
mov dl, 20
mov dh, 20
call tomos_set_cursor
jmp $


tomos_set_cursor:                     
        pusha                                   ; Save registers
        mov bh, 0                               ; Page zero
        mov ah, 02h                             ; BIOS set cursor function
        int 10h                                 ; Set
        popa                                    ; Restore regsiters
        ret                                     ; Return