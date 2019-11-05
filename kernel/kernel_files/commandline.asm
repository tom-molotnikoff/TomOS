; PROCESS FOR ADDING COMMANDS: Add command/options variable
;                              Compare 'command' to the new variable
;                              Compare 'options' to the new options, or to 'empty' if none are present
;                              Add the new command to the help-options comparison section
;                              Add a help function in commandline_functions.asm
tomos_command_line:
        pusha
        mov ax, 1003h
        mov bl, 00h
        int 10h
        popa
        call tomos_clear_registers
        mov dh, 0
        mov dl, 0
        call tomos_set_cursor
        mov si, start_string_command_line
        call tomos_print_string_with_delay
        call tomos_help_generic

; Input loop -----------------------------------------------------------------------------------------------------
take_input:
        call tomos_empty_key_buffer
        call tomos_command_line_newline
        call tomos_clear_registers
        mov di, input_line
        mov cx, 256
        mov ax, 0
        rep stosb
        
        mov di, options
        mov cx, 256
        mov ax, 0
        rep stosb        

        mov di, options1
        mov cx, 256
        mov ax, 0
        rep stosb
        
        mov ax, input_line
        call tomos_input_string

; Command analysis -----------------------------------------------------------------------------------------------

commands:
        mov si, input_line
        mov di, options
        mov ah, ' '        
        call tomos_separate_string
        mov si, input_line
        
        
        mov di, color
        call tomos_compare_strings
        cmp cx, 1
        je color_command
        
        mov di, help
        call tomos_compare_strings
        cmp cx, 1
        je help_command        
        
        mov di, reboot
        call tomos_compare_strings
        cmp cx, 1
        je .reboot        
        
        mov di, clear
        call tomos_compare_strings
        cmp cx, 1
        je .clearscreen    
        
        mov di, shutdown
        call tomos_compare_strings
        cmp cx, 1
        je .shutdown
        
        mov di, version
        call tomos_compare_strings
        cmp cx, 1
        je .version
        jmp not_recognised

; Command preparation - Use this to check options and send back to input loop ------------------------------------
.version:
        mov si, options
        mov di, empty
        call tomos_compare_strings
        cmp cx, 1
        je .version_call
        jmp incorrect_options
.version_call:
        call tomos_version
        jmp take_input
.shutdown:
        mov si, options
        mov di, empty
        call tomos_compare_strings
        cmp cx, 1
        je .shutdown_call
        jmp incorrect_options
.shutdown_call:
        call tomos_shutdown
        jmp take_input
.clearscreen:
        mov si, options
        mov di, empty
        call tomos_compare_strings
        cmp cx, 0
        je incorrect_options
.clearscreen_call:
        call tomos_clear_screen
        mov dh, 0
        mov dl, 0
        call tomos_set_cursor
        jmp take_input

.reboot:
        mov si, options
        mov di, hard
        call tomos_compare_strings
        cmp cx, 1
        je tomos_reboot        
        mov di, soft
        call tomos_compare_strings
        cmp cx, 1
        je .soft_reboot        
        jmp incorrect_options
.soft_reboot:
        mov cx, 0
        jmp tomos_reboot

color_command:
        mov si, options
        mov di, options1
        mov al, ' '
        call tomos_separate_string
        
        mov di, black
        call tomos_compare_strings
        cmp cx, 1
        je .black
        
        mov di, blue
        call tomos_compare_strings
        cmp cx, 1
        je .blue
        
        mov di, green
        call tomos_compare_strings
        cmp cx, 1
        je .green
        
        mov di, cyan
        call tomos_compare_strings
        cmp cx, 1
        je .cyan
        
        mov di, red
        call tomos_compare_strings
        cmp cx, 1
        je .red
        
        mov di, magenta
        call tomos_compare_strings
        cmp cx, 1
        je .magenta
        
        mov di, brown
        call tomos_compare_strings
        cmp cx, 1
        je .brown
        
        mov di, lightgray
        call tomos_compare_strings
        cmp cx, 1
        je .lightgray
        
        mov di, darkgray
        call tomos_compare_strings
        cmp cx, 1
        je .darkgray
        
        mov di, lightblue
        call tomos_compare_strings
        cmp cx, 1
        je .lightblue
        
        mov di, lightgreen
        call tomos_compare_strings
        cmp cx, 1
        je .lightgreen
        
        mov di, lightcyan
        call tomos_compare_strings
        cmp cx, 1
        je .lightcyan
        
        mov di, lightred
        call tomos_compare_strings
        cmp cx, 1
        je .lightred
        
        mov di, lightmagenta
        call tomos_compare_strings
        cmp cx, 1
        je .lightmagenta
        
        mov di, yellow
        call tomos_compare_strings
        cmp cx, 1
        je .yellow
        
        mov di, white
        call tomos_compare_strings
        cmp cx, 1
        je .white
        
        jmp incorrect_options
        
.black:
        mov bh, 0x00  
.Fblack:
        mov si, options1
        mov di, black
        call tomos_compare_strings
        cmp cx, 1
        jne .Fblue
        add bh, 0x00
        call tomos_clear_screen_color
        
        jmp take_input
.blue:
        mov bh, 0x10
        jmp .Fblack
.Fblue:
        mov si, options1
        mov di, blue
        call tomos_compare_strings
        cmp cx, 1
        jne .Fgreen
        add bh, 0x01
        call tomos_clear_screen_color
        jmp take_input
.green:        
        mov bh, 0x20
        jmp .Fblack
.Fgreen:
        mov si, options1
        mov di, green
        call tomos_compare_strings
        cmp cx, 1
        jne .Fcyan
        add bh, 0x02
        call tomos_clear_screen_color        
        jmp take_input
.cyan:
        mov bh, 0x30
        jmp .Fblack
.Fcyan:
        mov si, options1
        mov di, cyan
        call tomos_compare_strings
        cmp cx, 1
        jne .Fred
        add bh, 0x03
        call tomos_clear_screen_color
        jmp take_input
.red:
        mov bh, 0x40
        jmp .Fblack
.Fred:
        mov si, options1
        mov di, red
        call tomos_compare_strings
        cmp cx, 1
        jne .Fmagenta
        add bh, 0x04
        call tomos_clear_screen_color
        jmp take_input
.magenta:
        mov bh, 0x50
        jmp .Fblack
.Fmagenta:
        mov si, options1
        mov di, magenta
        call tomos_compare_strings
        cmp cx, 1
        jne .Fbrown
        add bh, 0x05        
        call tomos_clear_screen_color
        jmp take_input
.brown:
        mov bh, 0x60
        jmp .Fblack
.Fbrown:
        mov si, options1
        mov di, brown
        call tomos_compare_strings
        cmp cx, 1
        jne .Flightgray
        add bh, 0x06
        call tomos_clear_screen_color
        jmp take_input
.lightgray:
        mov bh, 0x70
        
        jmp .Fblack
.Flightgray:
        mov si, options1
        mov di, lightgray
        call tomos_compare_strings
        cmp cx, 1
        jne .Fdarkgray
        add bh, 0x07
        call tomos_clear_screen_color
        jmp take_input
.darkgray:
        mov bh, 0x80
        jmp .Fblack
.Fdarkgray:
        mov si, options1
        mov di, darkgray
        call tomos_compare_strings
        cmp cx, 1
        jne .Flightblue
        add bh, 0x08
        call tomos_clear_screen_color
        jmp take_input
.lightblue:
        mov bh, 0x90
        jmp .Fblack
.Flightblue:
        mov si, options1
        mov di, lightblue
        call tomos_compare_strings
        cmp cx, 1
        jne .Flightgreen
        add bh, 0x09
        call tomos_clear_screen_color
        jmp take_input
.lightgreen:
        mov bh, 0xA0
        jmp .Fblack
.Flightgreen:
        mov si, options1
        mov di, lightgreen
        call tomos_compare_strings
        cmp cx, 1
        jne .Flightcyan
        add bh, 0x0A     
        call tomos_clear_screen_color
        jmp take_input
.lightcyan:
        mov bh, 0xB0
        jmp .Fblack
.Flightcyan:
        mov si, options1
        mov di, lightcyan
        call tomos_compare_strings
        cmp cx, 1
        jne .Flightred
        add bh, 0x0B
        call tomos_clear_screen_color
        jmp take_input
.lightred:
        mov bh, 0xC0
        jmp .Fblack
.Flightred:
        mov si, options1
        mov di, lightred
        call tomos_compare_strings
        cmp cx, 1
        jne .Flightmagenta
        add bh, 0x0C        
        call tomos_clear_screen_color
        jmp take_input
.lightmagenta:
        mov bh, 0xD0
        jmp .Fblack
.Flightmagenta:
        mov si, options1
        mov di, lightmagenta
        call tomos_compare_strings
        cmp cx, 1
        jne .Fyellow
        add bh, 0x0D
        call tomos_clear_screen_color
        jmp take_input
.yellow:
        mov bh, 0xE0
        jmp .Fblack
.Fyellow:
        mov si, options1
        mov di, yellow
        call tomos_compare_strings
        cmp cx, 1
        jne .Fwhite
        add bh, 0x0E
        call tomos_clear_screen_color
        jmp take_input
.white:
        mov bh, 0xF0
        jmp .Fblack
.Fwhite:
        mov si, options1
        mov di, white
        call tomos_compare_strings
        cmp cx, 1
        jne incorrect_options
        add bh, 0x0F        
        call tomos_clear_screen_color
        jmp take_input
        
        
        
        
        
help_command:
        mov si, options
        mov di, clear
        call tomos_compare_strings
        cmp cx, 1
        je .help_clear  
              
        mov di, color
        call tomos_compare_strings
        cmp cx, 1
        je .help_color
        
        mov di, reboot
        call tomos_compare_strings
        cmp cx, 1
        je .help_reboot       
        
        mov di, help
        call tomos_compare_strings
        cmp cx, 1
        je .help_help
        
        mov di, empty
        call tomos_compare_strings
        cmp cx, 1
        je .help_generic  
        
        mov di, shutdown
        call tomos_compare_strings
        cmp cx, 1
        je .help_shutdown      
        
        mov di, version
        call tomos_compare_strings
        cmp cx, 1
        je .help_version
        
        jmp incorrect_options
.help_generic:
        call tomos_help_generic
        jmp take_input
.help_clear:
        call tomos_help_clear
        jmp take_input
.help_color:
        call tomos_help_color
        jmp take_input
.help_reboot:
        call tomos_help_reboot
        jmp take_input
.help_help:
        call tomos_help_help
        jmp take_input       
.help_shutdown:
        call tomos_help_shutdown
        jmp take_input
.help_version:
        call tomos_help_version
        jmp take_input
 
; Errors ---------------------------------------------------------------------------------------------------------   

not_recognised:
        call tomos_newline
        mov si, not_recognised_string
        call tomos_print_string
        jmp take_input
        
incorrect_options:
        call tomos_newline
        mov si, incorrect_options_string
        call tomos_print_string
        jmp take_input
        
        
; Variables ------------------------------------------------------------------------------------------------------
        incorrect_options_string db "Options for command are incorrect, try help [command]", 0
        not_recognised_string db "Command not recognised!", 0
        input_line times 256 db 0
        empty db '',0
        options times 256 db 0
        options1 times 256 db 0
        shutdown db "shutdown", 0
        version db "version", 0
        hard db "hard", 0
        soft db "soft", 0
        clear db "clear", 0
        help db "help", 0
        reboot db "reboot", 0
        
        color db "color", 0
        black db "black", 0
        blue db "blue", 0
        green db "green", 0
        cyan db "cyan", 0
        red db "red", 0
        magenta db "magenta", 0
        brown db "brown", 0
        lightgray db "lightgray", 0        
        darkgray db "darkgray", 0
        lightblue db "lightblue", 0
        lightgreen db "lightgreen", 0
        lightcyan db "lightcyan", 0
        lightred db "lightred", 0
        lightmagenta db "lightmagenta", 0
        yellow db "yellow", 0
        white db "white", 0
        
        start_string_command_line dw '>Welcome to TomOS', 0