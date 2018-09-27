org 100h
         mov ax, 13h
         int 10h
         mov ax, 0xA000
         mov es, ax

         mov dx, prompt1
         mov ah, 9
         int 21h

         mov dx, inbuff
         mov word [inbuff], 0505h
         mov ah, 0xA
         int 21h

         mov ax, 3
         int 10h

         mov ax, 4c00h
         int 21h





prompt1  db "Number of lines: $"

section .bss
inbuff resb 20



