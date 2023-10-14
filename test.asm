	global	main
	extern	printf
	section	.text

main: 	mov	ecx, 6
	mov	eax, 1
i:	imul	eax, ecx
	dec	ecx
	test	ecx, ecx
	jnz	$i
	push	eax
	push	my_text
	call	printf
	add	esp, 8
	xor	eax, eax
	ret

	section	.rdata
my_text:	db	"number: %i", 0
