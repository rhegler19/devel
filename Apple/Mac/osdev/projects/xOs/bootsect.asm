[org     0x7C00]
[BITS 16]

        push    cs 
        pop     ds
        cli
        mov ax, 0x9000
        mov ss, ax
        mov sp, 0x0
        mov sp, 0xF800
        sti

        mov    [bootdrv],dl

        mov si, loading_msg
        call printstr 

loadsect: 
        mov     ax,0x1000
        mov     es,ax
        mov     bx,0x0

        mov     dl,[bootdrv]
        mov     dh,0x0
        mov     cl,0x02
        mov     ch,0x0

        mov     ah,0x02
        mov     al,0x11

        int     0x13
        jnc     noloaderr

        mov si, error_msg
        call printstr 
        jmp loadsect

noloaderr: 

        mov si, ok_msg
        call printstr

        mov sp, 0

        mov ax, 0x1000 
        mov es, ax 
        mov ds, ax 
        push word 0x1000 
        push word 0 
        retf 

printstr: 
        lodsb 
        or al,al 
        jz  printstrj 
        mov ah,0x0E 
        mov bx,0x0007 
        int 0x10 
        jmp putstr 
printstrj: 
        retn 

bootdrv                 db 0
loading_msg             db 'Booting...',13,10,0 
ok_msg                  db 'OK!',13,10,0 
error_msg               db 'Error!',13,10,0 

       times 510-($-$$) db 0
       dw 0xaa55 
