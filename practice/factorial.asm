	global	main
	extern	printf
	section	.text
; 0x00DFFDD4
;0x00DFFDD4  93 32 c0 00  “2А.
; 0x00DFFDD8  01 00 00 00  ....
; 0x00DFFDDC  00 65 45 01  .eE.
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
