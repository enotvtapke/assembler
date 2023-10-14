	global	main
	extern	printf

	section	.text
main:	mov	eax, 123456	; number to convert to string
	push	0		; string terminator
	add	esp, 3		; push always pushes 4 bytes in 32-bit mode. We need only 1 byte to be pushed
; alternatively
;	sub	esp, 1
;	mov	byte [esp], 0
	xor	edx, edx
	mov	ecx, 0

	mov	ebx, 10

l1:	div	ebx
	add	edx, 48
	shl	edx, 24
	push	edx
	add	esp, 3
	xor	edx, edx
	inc	ecx
	test	eax, eax
	jnz	l1

	mov	ebx, ecx
	push	esp
	push	my_text
	call	printf
	add	ebx, 9		; 8 bytes for arg pointers. 1 byte for string terminator
	add	esp, ebx
	xor	eax, eax
	ret

	section	.rdata
my_text:	db	'number: %s'
