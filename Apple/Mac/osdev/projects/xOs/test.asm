%include "printstr.asm"
mov al, [msg] 
call printstr
msg db "Hello", 0
times 510-($-$$) 0
dw 0xaa55
