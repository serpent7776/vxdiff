; vim: set ft=nasm:
DEFAULT REL

section .data
	testno: dq 0
align 64
	;                      R     G     B     A
	purple4x4: times 16 db 0xff, 0x00, 0xff, 0xff
	white4x4:  times 16 db 0xff, 0xff, 0xff, 0xff
	trans4x4:  times 16 db 0x00, 0x00, 0x00, 0x00
	purple5x5: times 25 db 0xff, 0x00, 0xff, 0xff
	white5x5:  times 25 db 0xff, 0xff, 0xff, 0xff
	trans5x5:  times 25 db 0x00, 0x00, 0x00, 0x00

	; pixel 0 fully transparent in both images, pixel 1 black vs white
	transblack4x1: db 0, 0, 0, 0,  0, 0, 0, 0xff,  32, 64, 96, 0xff,  96, 64, 32, 0xff
	transwhite4x1: db 0, 0, 0, 0,  0xff, 0xff, 0xff, 0xff,  32, 64, 96, 0xff,  96, 64, 32, 0xff
	; transparent vs opaque black differs only in pixel 0
	trans4x1: db 0, 0, 0, 0,  5, 5, 5, 0xff,  6, 6, 6, 0xff,  7, 7, 7, 0xff
	black4x1: db 0, 0, 0, 0xff,  5, 5, 5, 0xff,  6, 6, 6, 0xff,  7, 7, 7, 0xff
	; same as the first case, but in the leftover path (width not divisible by 4):
	; pixel 4 fully transparent in both images, pixel 5 black vs white
	transblack7x1: db 1, 2, 3, 0xff,  4, 5, 6, 0xff,  7, 8, 9, 0xff,  10, 11, 12, 0xff
	               db 0, 0, 0, 0,  0, 0, 0, 0xff,  13, 14, 15, 0xff
	transwhite7x1: db 1, 2, 3, 0xff,  4, 5, 6, 0xff,  7, 8, 9, 0xff,  10, 11, 12, 0xff
	               db 0, 0, 0, 0,  0xff, 0xff, 0xff, 0xff,  13, 14, 15, 0xff

section .text
global _start
extern vxdiff

%macro TEST 7
	lea rdi, [%6]
	lea rsi, [%7]
	mov rdx, %1
	mov rcx, %3
	mov r8, %2
	mov r9, %4
	inc qword[testno]
	call vxdiff
	cmp rax, %5
	cmovne rbx, [testno]
	; mov rbx, rax ; debug
	jne .exit
%endmacro

_start:
	TEST 4, 4, 4, 4, 16, purple4x4, white4x4
	TEST 1, 1, 1, 1, 1, purple4x4, white4x4
	TEST 1, 4, 1, 4, 4, purple4x4, white4x4
	TEST 2, 2, 4, 4, 4, purple4x4, white4x4
	TEST 1, 1, 1, 1, 1, purple4x4, white4x4
	TEST 4, 4, 1, 1, 16, purple4x4, white4x4
	TEST 1, 1, 4, 4, 1, purple4x4, white4x4
	TEST 3, 4, 4, 3, 12, purple4x4, white4x4
	TEST 4, 4, 4, 4, 16, trans4x4, purple4x4
	TEST 4, 4, 4, 4, 0, trans4x4, white4x4
	TEST 5, 5, 5, 5, 25, purple5x5, white5x5
	TEST 5, 5, 5, 5, 25, trans5x5, purple5x5
	TEST 5, 5, 5, 5, 0, trans5x5, white5x5
	TEST 4, 4, 5, 5, 0, purple4x4, purple5x5
	; transparent pixel doesn't affect diff of neighbouring pixels
	TEST 4, 1, 4, 1, 1, transblack4x1, transwhite4x1
	TEST 4, 1, 4, 1, 1, trans4x1, black4x1
	TEST 7, 1, 7, 1, 1, transblack7x1, transwhite7x1
.exit_ok:
	xor rbx, rbx
.exit:
	mov eax, 1
	int 0x80

