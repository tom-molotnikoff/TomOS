; Set cursor - Takes in the row(DH) and column(DL)
; Updates the cursor position on page 0
pusha
mov dl, 60
mov dh, 0
mov bh, 0                               ; Page zero
        mov ah, 02h                     ; BIOS set cursor function
        int 10h
        jmp $
popa
ret


