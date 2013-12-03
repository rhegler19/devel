; ------------------------------------------------------------------------
; \ \/ /   .'    '.    / ___|
;  \  /    | .''. |    \ \__
;  |  |    | '..' |     \__ \
;  /  \    |      |    ___/ /
; / /\ \   '.    .'   |    / 
; ------------------------------------------------------------------------
Based on PolyOS, which is (c)1997 Jeff Weeks of Code X Software.
[BITS 16]
[ORG 0]

;JUMP

jmp start

;DATA

        bootdrv         db 0
        bootmsg         db 'Booting PolyOS (c)1997 Cipher of Code X',13,10,0
        loadmsg         db 'Loading kernel',13,10,0
        jumpmsg         db 'Jumping to kernel',13,10,0
        rebootmsg       db 'Press any key to reboot',13,10,0
        processormsg    db 'Checking for 386+ processor: ',0
        need386         db 'Sorry... 386+ required!',13,10,0
        found386        db 'Excellent!',13,10,0
        a20msg          db 'Setting A20 address line',13,10,0
        pmodemsg        db 'Setting CR0 -> Entering PMode',13,10,0
        pIDT            dw 7FFh         ; IDT slots
                        dd 0000h        ; from 0000
        pGDT            dw 17FFh        ; GDT slots
                        dd 0800h        ; right after the IDT

;FUNCTIONS

        detect_cpu:
                mov si, processormsg    ;print
                call message
                ;TEST FOR i386
                pushf                   ; push all the flags onto stack
                
                xor ah,ah               ; ah = 0
                push ax                 ; copy ax into the flags
                popf                    
                
                pushf                   
                pop ax       
                and ah,0f0h             ; if 12-15 are set, no i386
                cmp ah,0f0h
                je no386                

                ; check for a 286 (bits 12-15 are clear)
                mov ah,0f0h             ; set bits 12-15
                push ax                 ; copy ax onto the flags
                popf
                
                pushf                   ; copy the flags into ax
                pop ax
                and ah,0f0h             ; check if bits 12-15 are clear
                jz no386                ; no 386 detected (80286 present)
                popf                    ; pop the original flags back
                
                mov si, found386
                call message
                
                ret                     ; no 8088/8086 or 286, so ateast 386
         no386:
                mov si,need386          ; tell the user the problem
                call message
                jmp reboot              ; and reboot when key pressed
                     
;       ------------------------------------------------------------------
        message:                        ; Dump ds:si to screen.
                lodsb                   ; load byte at ds:si into al
                or al,al                ; test if character is 0 (end)
                jz done
                mov ah,0eh              ; put character
                mov bx,0007             ; attribute
                int 0x10                ; call BIOS
                jmp message
        done:
                ret
;       ------------------------------------------------------------------
        getkey:
                mov ah, 0               ; wait for key
                int 016h
                ret

;       ------------------------------------------------------------------        
        reboot:
                mov si, rebootmsg       ; be polite, and say we're rebooting
                call message
                call getkey             ; and even wait for a key :)

                db 0EAh                 ; machine language to jump to FFFF:0000 (reboot)
                dw 0000h
                dw 0FFFFh
                ; no ret required; we're rebooting! (Hey, I just saved a byte :)

; -------------------------------------------
; The actual code of our boot loading process
; ------------------------------------------------------------------------
start:
        mov ax,0x7c0    ; BIOS puts us at 0:07C00h, so set DS accordinly
        mov ds,ax       ; Therefore, we don't have to add 07C00h to all our data

        mov [bootdrv], dl ; quickly save what drive we booted from

        cli             ; clear interrupts while we setup a stack
        mov ax,0x9000   ; this seems to be the typical place for a stack
        mov ss,ax
        mov sp,0xffff   ; let's use the whole segment.  Why not?  We can :)
        sti             ; put our interrupts back on
        
        ; Interestingly enough, apparently the processor will disable 
        ; interupts itself when you directly access the stack segment!
        ; Atleast it does in protected mode, I'm not sure about real mode.
        
        mov si,bootmsg  ; display our startup message
        call message

        call detect_cpu ; check if we've got a 386

.386    ; use 386 instructions from now on (I don't want to manually include
        ; operand-size(66h) or address-size(67h) prefixes... it's annoying :)

        mov si,loadmsg  ; tell the user we're loading the kernel
        call message
        call getkey

read_me:
        ; first, reset the disk controller
        xor ax, ax
        int 0x13
        jc reboot       ; reboot on error

        ; then load in the PolyFS superblock
        mov ax,0x09000          ; superblock goes to 9000:0000 (above stack)
        mov es,ax
        xor bx,bx

        ; I could condense a few of these high/low 8-bit movs into one 16-bit
        ; mov, but, for simplicity, I'll leave it as is, unless necessary.
        mov ax,0x0202           ; load one block (two sectors)
        mov ch,0                ; cylinder = 0
        mov cl,3                ; sector = 2 (starts at sector 1 not 0)
        mov dh,0                ; head = 0 = side one
        mov dl,[bootdrv]        ; disk = what we booted from
        int 0x13                ; read it
        jc read_me              ; if there's an error then we'll try again.
                                ; Often there is not error but requires a few
                                ; tries.  Ofcourse, this may end up as an 
                                ; infinite loop... but only on a bad disk...
        
        ; Check if we have a valid super block (BTW: ES still equals 0x9000)
        mov di, 0               ; offset of PolyFS magic signature
        mov si, polymagic       ; offset of PolyFS magic to check for (in ds)
        cmpsw                   ; compare ES:[DI] with DS:[SI]
        jnz reboot              ; reboot on error (otherwise, we've got a PolyFS)

	; Ideally, we'd load the kernel right here

        mov si, a20msg          ; tell the user we're setting the A20 line
        call message

        ; set A20 line
        cli                     ; no more interuptions! :)
        xor cx, cx
clear_buf:
        in al, 64h              ; get input from keyboard status port
        test al, 02h            ; test the buffer full flag
        loopnz clear_buf        ; loop until buffer is empty
        mov al, 0D1h            ; keyboard: write to output port
        out 64h, al             ; output command to keyboard
clear_buf2:
        in al, 64h              ; wait 'till buffer is empty again
        test al, 02h
        loopnz clear_buf2
        mov al, 0dfh            ; keyboard: set A20
        out 60h, al             ; send it to the keyboard controller
        mov cx, 14h
wait_kbc:                       ; this is approx. a 25uS delay to wait
        out 0edh, ax            ; for the kb controler to execute our 
        loop wait_kbc           ; command.

        ; the A20 line is on now.  Let's load in our ITD and GDT tables...
        ; Ideally, there will actually be data in their locations (by loading 
        ; the kernel)
        lidt [pIDT]
        lgdt [pGDT]

        ; now let's enter pmode...
        mov si, pmodemsg
        call message
        call getkey

        mov eax, cr0            ; load the control register in
        or  al, 1               ; set bit 1: pmode bit
        mov cr0, eax            ; copy it back to the control register
        jmp $+2                 ; and clear the prefetch queue
        nop
        nop

        ; jump to the kernel that we've loaded in...
        ; For now, we'll actually just reboot (this really doesn't 
        ; work in protected mode, but it does reboot :)
        db 0xEA
        dw 0x0000
        dw 0xFFFF

        ; The boot sector is supposed to have to have 0xAA55 at the end of 
        ; the sector (the word at 510 bytes) to be loaded by the BIOS...
        times 510-($-$$) db 0
        dw 0xaa55
