;forget di. make one line.  use labels.
;or make two lines, ibeblack behind.
;or tail for speed 

org 100h
         mov ax, 13h
         int 10h
         mov ax, 0xA000
         mov es, ax

         xor ax, ax
         int 1ah
         mov [rseed], dx

         mov di, freemem
         call random

                 ;00 01  x pos
                 ;02 03  x fraction
                 ;04 05  x vel
                 ;06 07  x dir
                 ;08 09  y pos
                 ;10 11  y fraction
                 ;12 13  y vel
                 ;14 15  y dir
                 ;16 17  absolute 
                 ;18 19  color
                 ;20 21  color fraction

l1:      mov di, freemem

l2:      mov byte [ppflag], 0
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

            mov ah, 1
            int 16h
            jnz stop

            jmp xnc

xpp:        mov byte [ppflag], 1

xnc:     mov ax, [di+12]
         add [di+10], ax
         jnc ync
          cmp word [di+14], 0
          jne up

           inc word [di+8]
           add word [di+16], 320
           jnc ypp
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

                  inc byte [di+18]


nopixel: add di, 19
         cmp di, [maxdi]
         jg nojmpl2
          jmp l2
nojmpl2: jmp l1


stop:    mov ax, 3
         int 10h

         mov ax, 4c00h
         int 21h

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

maxdi    dw freemem
ppflag   db 0

%include 'lincon.asm'

align 2
freemem:
