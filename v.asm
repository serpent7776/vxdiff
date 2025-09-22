; vim: set ft=nasm:
DEFAULT REL

section .data
align 64
img1: times 16000000 db 0xFF, 0xFF, 0xFF, 0xFF
img2: times 16000000 db 0xFE, 0xFF, 0xFF, 0xFF

section .text
global _start

extern vxdiff

_start:
	lea rdi, [img1]
	lea rsi, [img2]
	mov rdx, 2000
	mov rcx, 2000
	mov r8, 8000
	mov r9, 8000
	call vxdiff
.exit:
	xor rbx, rbx
	mov eax, 1
	int 0x80

