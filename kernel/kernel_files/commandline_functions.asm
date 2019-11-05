; Command line functions------------------------------------------------------------------------------------------------

tomos_command_line_newline:
        pusha
        call tomos_newline
        mov ah, 0Eh
        mov al, 3Eh
        int 10h
        popa
        ret
        jmp tomos_kernel_panic

tomos_help_generic:
        pusha
        call tomos_newline
        mov si, tomos_cl_help_msg1
        call tomos_print_string
        call tomos_newline
        mov si, tomos_cl_help_msg2
        call tomos_print_string

        popa
        ret
jmp tomos_kernel_panic
        tomos_cl_help_msg1 dw '[command] [option]', 0
        tomos_cl_help_msg2 dw 'Commands: help, reboot, color, version, shutdown, clear' , 0
tomos_help_clear:
        pusha
        call tomos_newline
        mov si, help_clear_1
        call tomos_print_string        
        popa
        ret
        jmp tomos_kernel_panic
        help_clear_1 dw '"clear" : Clears the screen of all previous commands',0
tomos_help_reboot:
        pusha
        call tomos_newline
        mov si, help_reboot_1
        call tomos_print_string
        call tomos_newline
        mov si, help_reboot_2
        call tomos_print_string
        call tomos_newline
        mov si, help_reboot_3
        call tomos_print_string
        call tomos_newline
        mov si, help_reboot_4
        call tomos_print_string
        popa
        ret
jmp tomos_kernel_panic
        help_reboot_1 dw '"reboot" : Reboots the computer', 0
        help_reboot_2 dw 'Options for this command: hard, soft' ,0
        help_reboot_3 dw '"reboot hard" - Hardware reboot', 0
        help_reboot_4 dw '"reboot soft" - Software reboot', 0
tomos_help_help:
        pusha
        call tomos_newline
        mov si, help_help_1
        call tomos_print_string
        call tomos_newline
        mov si, help_help_2
        call tomos_print_string
        call tomos_newline
        mov si, help_help_3
        call tomos_print_string
        popa
        ret
        jmp tomos_kernel_panic
        help_help_1 dw '"help" : Displays help for a command', 0
        help_help_2 dw 'Entering "help" will show generic help', 0
        help_help_3 dw 'Entering "help [command]" will show help for the entered command', 0
tomos_help_shutdown:
        pusha
        call tomos_newline
        mov si, help_shutdown
        call tomos_print_string
        popa
        ret
        jmp tomos_kernel_panic
        help_shutdown dw '"shutdown" : Performs an APM shutdown - Computer must support APM', 0
tomos_help_version:
        pusha
        call tomos_newline
        mov si, help_version
        call tomos_print_string
        popa
        ret
        jmp tomos_kernel_panic
        help_version dw '"version" : Displays the current version of TomOS', 0
        
tomos_help_color:
        pusha
        call tomos_newline
        mov si, help_color_1
        call tomos_print_string
        call tomos_newline
        mov si, help_color_2
        call tomos_print_string
        popa
        ret
        jmp tomos_kernel_panic
        help_color_1 dw '"color [background] [foreground]" : Changes the background and foreground color', 0
        help_color_2 dd 'Colors: black, blue, green, cyan, red, magenta, brown, lightgray, darkgray,     lightblue, lightgreen, lightcyan, lightred, lightmagenta, yellow, white', 0
tomos_version:
        pusha
        call tomos_newline
        mov si, tomos_version_string
        call tomos_print_string
        popa
        ret
        jmp tomos_kernel_panic
        tomos_version_string db "TOMOS VERSION ", TOMOS_VER, 0