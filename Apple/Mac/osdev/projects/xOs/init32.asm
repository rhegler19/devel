[bits 16]
switch32:
	cli
	lgdt [gdtdesc]
	mov eax, cr0
	or eax, 0x1
	mov cr0, eax
	jmp CODESEG:pminit
[bits 32]
pminit:
	mov ax, DATASEG
	mov ds, ax
	mov ss, ax
	mov es, ax
	mov fs, ax
	mov gs, ax
	mov ebp, 0x90000a
	mov esp, ebp
	call start32
