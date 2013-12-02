hdload:
	push dx
	mov ah, 0x02
	mov al, dh
	mov ch, 0x00
	mov dh, 0x00
	mov cl, 0x02
	int 0x13
	jc loaderror
	cmp dh, al
	jne loaderror
	ret
loaderror:
	mov al, ERRORLOAD
	call printstr
	jmp $
ERRORLOAD db "Disk load error...", 0
%include "printstr.asm"
