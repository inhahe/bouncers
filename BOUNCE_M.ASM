l equ 7

color equ 254

org 100h
         mov ax, 0xA000
         mov es, ax

         xor ax, ax
         int 1ah
         mov [rseed], dx
         mov [iseed], dx

mov word [maxdi], freemem+19*1
call rerand

         xor ax, ax
         int 1ah
         add dx, 100
         mov [time], dx

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
           mov bx, [di+16]
           cmp byte [es:bx], color
           je c1       
           cmp word [di], 320
           jne xpp
c1:         dec word [di]
            dec word [di+16]
            not word [di+6]
            jmp xnc

left:      dec word [di+16]
           mov bx, [di+16]
           cmp byte [es:bx], color
           je c2
           sub word [di], 1
           jnc xpp
c2:         inc word [di]
            inc word [di+16]
            not word [di+6]

            call getkey
            caLL timeadd

            jmp xnc

xpp:        mov byte [ppflag], 1

xnc:     mov ax, [di+12]
         add [di+10], ax
         jnc ync
          cmp word [di+14], 0
          jne up

           inc word [di+8]
           add word [di+16], 320
           mov bx, [di+16]
           cmp byte [es:bx], color
           je c3       
           cmp word [di+8], 200
           jne ypp
c3:         dec word [di+8]
            sub word [di+16], 320
            not word [di+14]
            jmp ync

up:        sub word [di+16], 320
           mov bx, [di+16]
           cmp byte [es:bx], color
           je c4
           sub word [di+8], 1
           jnc ypp
c4:         inc word [di+8]
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
         
timeadd: xor ax, ax
         int 1ah
         cmp dx, [time]
         jnae tano
          add dx, 100
          mov [time], dx
          call more
          shr word [delay], 1
          jnz tano
           mov word [delay], 1
tano:    ret

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
          je clear1
          cmp ah, 0x13
          je rerand                 ;remove, superceded by s
          cmp ah, 0x1F
          je newseed1
          cmp ah, 1
          je stop
nokey:    ret

newseed1: jmp newseed

clear1:   jmp clear

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

endmsg   db "Inhahe '98$"

maxdi    dw freemem-19
ppflag   db 0
delay    dd 3000
time     dw 0

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


merrily   db 'Arlandy'
         

clear:    mov ax, 13h
          int 10h
          mov di, merrily
          mov cx, 7
          mov bl, 255
mloop:      mov ah, 14
            mov al, [di]
            xor bh, bh
            int 10h
            inc di
            loop mloop

          xor si, si
          mov di, 320*(200-l*10)/2+(320-l*(56-1-1-1-2-1-1-3-3-1))/2

          mov cx, 10
y1loop:     push cx
            mov cx, l
y2loop:       xor bx, bx
              push cx
              mov word [pixel], 8
x1loop:         cmp word [pixel], 8
                jne noadjust
                 mov word [pixel], 0
                 mov ax, [slacksi+bx]
                 add si, ax
                 add word [pixel], ax
                 sub di, [slackdi+bx]
                 inc bx
                 inc bx
                 cmp bx, 14
                 ja x1stop
noadjust:       inc word [pixel]
                mov al, [es:si]
                neg al
                mul byte [blah]
                mov cx, l
x2loop:           mov [es:di], al
                  inc di
                  loop x2loop
                inc si
                jmp x1loop
x1stop:         add di, 320-l*(56-1-1  -1-2-1-1-3-3)
              sub si, 56
              pop cx
              loop y2loop
            add si, 320
            pop cx
            loop y1loop
          ret


slacksi dw 0, 0,  0, 0, 1,  1, 0, 0
slackdi dw 0, l*1,  l*2, l*1, l*1,  l*3, l*3, 0

pixel   dw 0
letter  db 0

blah    db color 

%include 'lincon.asm'

section .bss
iseed   resw 1
getseed resb 8

freemem:
