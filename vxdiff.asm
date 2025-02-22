section .data
align 64
	rgb2y: times 4 dd 0.29889531,  0.58662247,  0.11448223, 0.0
	rgb2i: times 4 dd 0.59597799, -0.27417610, -0.32180189, 0.0
	rgb2q: times 4 dd 0.21147017, -0.52261711,  0.31114694, 0.0

	delta_coef: times 4 dd 0.5053, 0.299, 0.1957, 0.0

	purple4x4: times 16 db 0xff, 0x00, 0xff, 0xff
	white4x4:  times 16 db 0xff, 0xff, 0xff, 0xff

	max_delta: dd 352.15 ; 35215.0 * 0.1^2

section .text
global _vxdiff
global _start

_start:
	mov rdi, purple4x4
	mov rsi, white4x4
	mov rdx, 16
	mov rcx, 16
	call _vxdiff
	mov ebx, eax
	mov eax, 1
	int 0x80

_vxdiff:
	; RDI base image pixels encoded as RGBA bytes
	; RSI second image pixels encoded as RGBA bytes
	; RDX base image size in pixels
	; RCX second image size in pixels
	mov rax, 0b0001000100010001000100010001000100010001000100010001000100010001
	kmovq k1, rax ; Rs
	kshiftlq k2, k1, 1 ; Gs
	kshiftlq k3, k2, 1 ; Bs
	kshiftlq k4, k3, 1 ; As
	knotq k5, k4 ; RGBs

	xor al, al
	vpbroadcastb zmm0, al ; 0
	dec al
	vpbroadcastb zmm31, al ; 255
	vpmovzxbd zmm30, xmm31
	vcvtudq2ps zmm30, zmm30 ; 255.0f

	vmovups zmm7, [rgb2y]
	vmovups zmm8, [rgb2i]
	vmovups zmm9, [rgb2q]

	vbroadcastss xmm28, [max_delta]

	vmovups zmm29, [delta_coef]

	cmp rdx, rcx
	cmovl rcx, rdx
	mov rdx, rcx ; number of pixels to compare
	shr rcx, 2 ; number of steps

	xor rbx, rbx ; number of differences found

.loop:
	cmp rcx, 0
	je .done

	vmovdqu8 xmm1, [rdi]
	vmovdqu8 xmm2, [rsi]

	add rdi, 16
	add rsi, 16
	dec rcx

	; replace pixels having alpha=0 with white
	vpcmpequb k6 {k4}, xmm1, xmm0
	vmovdqu8 xmm1 {k6}, xmm31
	vpcmpequb k7 {k4}, xmm2, xmm0
	vmovdqu8 xmm2 {k7}, xmm31

	; convert bytes to floats
	vpmovzxbd zmm1, xmm1
	vcvtudq2ps zmm1, zmm1
	vpmovzxbd zmm2, xmm2
	vcvtudq2ps zmm2, zmm2

	; normalise alpha
	vdivps zmm1 {k4}, zmm1, zmm30
	vdivps zmm2 {k4}, zmm2, zmm30

	; blend rgb with white pixel using alpha
	vsubps zmm1 {k5}, zmm1, zmm30
	vshufps zmm10, zmm1, zmm1, 0xff
	vmulps zmm1 {k5}, zmm1, zmm10
	vaddps zmm1 {k5}, zmm1, zmm30
	;
	vsubps zmm2 {k5}, zmm2, zmm30
	vshufps zmm20, zmm2, zmm2, 0xff
	vmulps zmm2 {k5}, zmm2, zmm20
	vaddps zmm2 {k5}, zmm2, zmm30

	; rgb to yiq
	vmulps zmm10, zmm1, zmm7 ; y
	vmulps zmm11, zmm1, zmm8 ; i
	vmulps zmm12, zmm1, zmm9 ; q
	vmulps zmm20, zmm2, zmm7 ; y
	vmulps zmm21, zmm2, zmm8 ; i
	vmulps zmm22, zmm2, zmm9 ; q

	; yiq(R)
	vxorps zmm13, zmm13, zmm13
	vshufps zmm13 {k1}, zmm10, zmm10, 0b00000000
	vshufps zmm13 {k2}, zmm11, zmm11, 0b00000000
	vshufps zmm13 {k3}, zmm12, zmm12, 0b00000000
	; yiq(G)
	vxorps zmm14, zmm14, zmm14
	vshufps zmm14 {k1}, zmm10, zmm10, 0b00000001
	vshufps zmm14 {k2}, zmm11, zmm11, 0b00000100
	vshufps zmm14 {k3}, zmm12, zmm12, 0b00010000
	; yiq(B)
	vxorps zmm15, zmm15, zmm15
	vshufps zmm15 {k1}, zmm10, zmm10, 0b00000010
	vshufps zmm15 {k2}, zmm11, zmm11, 0b00001000
	vshufps zmm15 {k3}, zmm12, zmm12, 0b00100000

	; yiq(R)
	vxorps zmm23, zmm23, zmm23
	vshufps zmm23 {k1}, zmm20, zmm20, 0b00000000
	vshufps zmm23 {k2}, zmm21, zmm21, 0b00000000
	vshufps zmm23 {k3}, zmm22, zmm22, 0b00000000
	; yiq(G)
	vxorps zmm24, zmm24, zmm24
	vshufps zmm24 {k1}, zmm20, zmm20, 0b00000001
	vshufps zmm24 {k2}, zmm21, zmm21, 0b00000100
	vshufps zmm24 {k3}, zmm22, zmm22, 0b00010000
	; yiq(B)
	vxorps zmm25, zmm25, zmm25
	vshufps zmm25 {k1}, zmm20, zmm20, 0b00000010
	vshufps zmm25 {k2}, zmm21, zmm21, 0b00001000
	vshufps zmm25 {k3}, zmm22, zmm22, 0b00100000

	; yiq
	vaddps zmm16, zmm13, zmm14
	vaddps zmm16, zmm16, zmm15
	vaddps zmm26, zmm23, zmm24
	vaddps zmm26, zmm26, zmm25

	; YIQ
	vsubps zmm16, zmm16, zmm26

	; YIQ*YIQ
	vmulps zmm16, zmm16, zmm16

	vmulps zmm16, zmm16, zmm29

	vxorps zmm17, zmm17, zmm17
	vxorps zmm18, zmm18, zmm18
	vxorps zmm19, zmm19, zmm19
	vshufps zmm17 {k1}, zmm16, zmm16, 0b00101010
	vshufps zmm18 {k1}, zmm16, zmm16, 0b01010101
	vshufps zmm19 {k1}, zmm16, zmm16, 0b00000000

	; delta
	vaddps zmm16, zmm19, zmm18
	vaddps zmm16, zmm16, zmm17

	vcompressps zmm16 {k1}, zmm16
	vcmpgtps k6, xmm16, xmm28
	kmov eax, k6
	popcnt eax, eax

	add rbx, rax
	jmp .loop

.done:
	mov eax, ebx
	ret
