; vim: set ft=nasm:
DEFAULT REL

section .data
	testno: dq 0
align 64
	purple4x4: times 16 db 0xff, 0x00, 0xff, 0xff
	white4x4:  times 16 db 0xff, 0xff, 0xff, 0xff

section .text
global _start
extern vxdiff

%macro TEST 5
	lea rdi, [purple4x4]
	lea rsi, [white4x4]
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
	TEST 4, 4, 4, 4, 16
	TEST 1, 1, 1, 1, 1
	TEST 1, 4, 1, 4, 4
	TEST 2, 2, 4, 4, 4
	TEST 1, 1, 1, 1, 1
	TEST 4, 4, 1, 1, 16
	TEST 1, 1, 4, 4, 1
	TEST 3, 4, 4, 3, 12
.exit_ok:
	xor rbx, rbx
.exit:
	mov eax, 1
	int 0x80

