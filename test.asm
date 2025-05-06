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
.exit_ok:
	xor rbx, rbx
.exit:
	mov eax, 1
	int 0x80

