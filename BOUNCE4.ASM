org 100h
         call clear
         mov ax, 0xA000
         mov es, ax

         xor ax, ax
         int 1ah
         mov [rseed], dx
         mov [iseed], dx

         call addone
         call addone
                 ;00 01  x pos
                 ;02 03  x fraction
                 ;04 05  x vel
                 ;06 07  x dir
                 ;08 09  y pos
                 ;10 11  y fraction
                 ;12 13  y vel
                 ;14 15  y dir
                 ;16 17  absolute 
                 ;18 color

l1:      mov di, freemem

         mov ecx, [delay]
l1b:     loop l1b, ecx

l2:      cmp di, [maxdi]
         ja l1

         mov byte [ppflag], 0
         mov ax, [di+4]
         add [di+2], ax
         jnc xnc
          cmp word [di+6], 0
          jne left

           inc word [di]
           inc word [di+16]
           cmp word [di], 320
           jne xpp
            dec word [di]
            dec word [di+16]
            not word [di+6]
            jmp xnc

left:      dec word [di+16]
           sub word [di], 1
           jnc xpp
            inc word [di]
            inc word [di+16]
            not word [di+6]

            call getkey

            jmp xnc

xpp:        mov byte [ppflag], 1

xnc:     mov ax, [di+12]
         add [di+10], ax
         jnc ync
          cmp word [di+14], 0
          jne up

           inc word [di+8]
           add word [di+16], 320
           cmp word [di+8], 200
           jne ypp
            dec word [di+8]
            sub word [di+16], 320
            not word [di+14]
            jmp ync

up:        dec word [di+8]
           sub word [di+16], 320
           jnc ypp
            inc word [di+8]
            add word [di+16], 320
            not word [di+14]
            jmp ync

ypp:       mov byte [ppflag], 1

ync:     cmp byte [ppflag], 1
         jne nopixel
          mov si, [di+16]
          mov al, [di+18]
          mov [es:si], al

nopixel: add di, 19
         jmp l2

random:  push dword 320
         call lincon
         pop dword [di]            ;x pos and fraction
         push dword 10000h
         call lincon
         pop dword [di+4]          ;x vel
         push dword 2
         call lincon
         pop dword [di+6]          
         dec word [di+6]           ;x dir: 0 or -1
         push dword 200
         call lincon
         pop dword [di+8]          ;y pos and fraction
         push dword 10000h
         call lincon
         pop dword [di+12]         ;y vel
         push dword 2
         call lincon
         pop dword [di+14]         
         dec word [di+14]          ;y dir: 0 or -1
         mov ax, 320
         xor dx, dx
         mul word [di+8]
         add ax, [di]
         mov [di+16], ax           ;absolute
         push dword 15
         call lincon
         pop dword [di+18]
         inc dword [di+18]         ;color
         ret

addone:  push di
         add word [maxdi], 19
         mov di, [maxdi]
         call random
         pop di
         ret
         
getkey:  mov ah, 11h
         int 16h
         jz nokey
          mov ah, 10h
          int 16h
          cmp ah, 0x48
          je faster
          cmp ah, 0x4D
          je faster
          cmp ah, 0x4B
          je slower
          cmp ah, 0x50
          je slower
          cmp ah, 0x0D
          je more
          cmp ah, 0x0C
          je less
          cmp ah, 0x39
          je clear
          cmp ah, 0x13
          je rerand                 ;remove, superceded by s
          cmp ah, 0x1F
          je newseed1
          cmp ah, 1
          je stop
nokey:    ret

newseed1: jmp newseed

faster:   sub dword [delay], 10
          cmp dword [delay], 1
          jnl nozdel
           mov dword [delay], 1
nozdel:   ret

slower:   add dword [delay], 10
          ret

more:     cmp [maxdi], word 65500
          ja nomore
           call addone
nomore:   ret

less:     cmp [maxdi], word freemem
          je noless
           sub [maxdi], word 19
noless:   ret

clear:    mov ax, 13h
          int 10h
          ret

rerand:   call clear
          mov ax, [rseed]
          mov [iseed], ax
          mov cx, [maxdi]
          mov [maxdi], word freemem-19
rrloop:     push cx
            call addone
            pop cx
            cmp cx, [maxdi]
            jne rrloop
          ret

stop:    mov ax, 3
         int 10h
         mov ah, 9
         mov dx, endmsg
         int 21h
         mov ax, 4c00h
         int 21h

newseed: call clear
         mov ah, 2 
         xor bx, bx
         mov dx, 0b0ah
         int 10h            ;locate 11, 10
         mov dx, osmsg
         mov ah, 9
         int 21h            ;print "First seed was: "
         mov ax, [iseed]
         call alphout       ;print old seed
         mov ah, 2
         xor bx, bx
         mov dx, 0d0ah      
         int 10h            ;locate 13, 10
         mov dx, nsmsg
         mov ah, 9
         int 21h            ;print "Enter new seed: "
         mov dx, getseed
         mov [getseed], word 0505h
         mov ah, 0Ah
         int 21h            ;input new seed
         mov bx, getseed+1
         cmp byte [bx], 0
         je nons            
         mov cx, 4      
nsloop:     inc bx
            shl ax, 4
            sub byte [bx], 'A'
            cmp byte [bx], 15
            jna nolower
             sub byte [bx], 'a'-'A' 
nolower:    or al, [bx]
            loop nsloop     ;if seed <> "" convert value and store
         mov [rseed], ax
nons:    call rerand
         ret

osmsg    db "First seed was: $"
nsmsg    db "Enter new seed: $"

endmsg   db "  or  : slower", 13, 10
         db " ", 26, " or  : faster", 13, 10 
         db " + or = : increase intricacy", 13, 10
         db " - or _ : decrease intricacy", 13, 10
         db "        : clear screen", 13, 10
         db " r or R : re-randomize with current settings", 13, 10
         db " s or S : show/enter random seed and re-randomize with current settings", 13, 10
         db " Esc    : duh", 13, 10
         db 10
         db "Inhahe '98$"

maxdi    dw freemem-19
ppflag   db 0
delay    dd 100

alphout:  mov cx, 4
hoh:        rol ax, 4
            mov dl, al
            and dl, 0Fh
            add dl, 'A'
            mov bx, ax
            mov ah, 2
            int 21h
            mov ax, bx
            loop hoh
          ret

%include 'lincon.asm'

section .bss
iseed   resw 1
getseed resb 8
align 2
freemem:
