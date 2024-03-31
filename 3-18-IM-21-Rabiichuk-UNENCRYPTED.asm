; Assembler directives
.386
.model flat, stdcall
option casemap :none

include \masm32\include\windows.inc
include \masm32\include\dialogs.inc
include \masm32\macros\macros.asm

include \masm32\include\user32.inc
include \masm32\include\kernel32.inc
include \masm32\include\masm32.inc

includelib \masm32\lib\user32.lib
includelib \masm32\lib\kernel32.lib
includelib \masm32\lib\masm32.lib


; Data section
.data
MY_SUCCESS_TITLE_MESSAGE       db "Successful login", 0
MY_ERROR_TITLE_MESSAGE         db "Login failed", 0
MY_PROMPT_MESSAGE      db "Please, enter your password below:", 0
MY_SUCCESS_MESSAGE     db "Information about student:", 13, 10, \
                    "Name: Rabiichuk D.O.", 13, 10, \
                    "Birthday data: 09.12.2004", 13, 10, \
                    "Score book number: 8915", 0
MY_ERROR_MESSAGE       db "Oops..you entered the wrong password!", 0

.data
    my_password            db "12345", 0
    my_password_length      equ $ - password
    my_password_buffer db 32 dup (?)

; Code section
.code

; Procedure to display a success message box and exit
success_login_message proc
    invoke MessageBox, 0, addr MY_SUCCESS_MESSAGE, addr MY_SUCCESS_TITLE_MESSAGE, 0
    invoke ExitProcess, NULL
    ret
success_login_message endp

; Procedure to display an error message box and exit
error_login_message proc
    invoke MessageBox, 0, addr MY_ERROR_MESSAGE, addr MY_ERROR_TITLE_MESSAGE, 0
    invoke ExitProcess, NULL
    ret
error_login_message endp

; Procedure to check the entered password
checking_my_password proc
    mov ebx, 0
    
checking_password_loop:
    mov al, my_password_buffer[ebx]
    mov ah, my_password[ebx]
    cmp al, ah
    jne wrong_password
    
    inc ebx
    cmp al, 0  ; Check for null-terminator
    jne checking_password_loop  
    
    ret 1  

wrong_password:
    ret 0 
checking_my_password endp

; Procedure for handling dialog window messages
dialogWindow proc hWindow: dword, message: dword, wParam: dword, lParam: dword   
    .if message == WM_COMMAND
        .if wParam == IDOK
            invoke GetDlgItemText, hWindow, 650, addr my_password_buffer, 32
            pushad
            call checking_my_password
            test eax, eax
            jnz @F  
            popad
            call success_login_message
            jmp @EndDialog
@@:
            popad
            call error_login_message
            jmp @EndDialog
@EndDialog:
        .elseif wParam == IDCANCEL
            invoke ExitProcess, NULL
        .endif
    .elseif message == WM_CLOSE
        invoke ExitProcess, NULL
    .endif
    xor eax, eax ; Return 0
    ret
dialogWindow endp

; Main program entry point
main PROC
    ; Dialog box creation
 Dialog "Lab3 Rabiichuk D.O.", "Calibri",14, \
        WS_OVERLAPPED OR WS_SYSMENU OR DS_CENTER, \
        4,8,8,200,80,1024
    DlgStatic "Enter your password",SS_CENTER,30,15,150,30,1000
    DlgEdit WS_BORDER,20,30,160,11,650
    DlgButton "Enter", WS_TABSTOP,20,40,40,20,IDOK
    DlgButton "Decline", WS_TABSTOP,140,40,40,20,IDCANCEL

    CallModalDialog 0, 0, dialogWindow, NULL
    ret
main ENDP

END main 
; End of program