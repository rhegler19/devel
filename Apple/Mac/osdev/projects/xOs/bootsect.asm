[org 0x7c00]
KERNELOFFSET equ 0x1000
mov [bootdev], dl
mov bp, 9000
mov sp, bp
call loadkernelmem
call switch32
jmp $
%include "gdt.asm"
%include "init32.asm"
%include "hdload.asm"
loadkernelmem:
mov bx, KERNELOFFSET
mov dh, 15
mov dl, [bootdev]
call hdload
ret
[bits 32]
start32:
call KERNELOFFSET
jmp $
bootdev db 0
times 510-($-$$) db 0
dw 0xaa55
