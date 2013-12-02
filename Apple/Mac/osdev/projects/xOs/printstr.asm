printstr:
cmp al, 0
jz endstr
mov ah, 0x0e
int 10h
jmp printstr
endstr:
ret
