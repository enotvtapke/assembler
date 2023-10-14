## Lecture 1
При решении лабы 1 могут быть серьёзные проблемы с флагами.

Ещё могут возникнуть проблемы со знаком. У нас дополнение до двух, плюс перед числом может стоять знак минус.

В файле code.asm примеры того, как писать условия и как их оптимизировать.

Ещё необходимо сохранить регистры, которые нельзя затрагивать.

Не следует разрывать пары типа 
```asm
	cmp eax, 5
	ja l1
```
Последовательности таких команд оптимизированы в современных процессорах.

Такие две команды превращаются в одно действие.

```asm
	; if (eax > 5 && ebx) x
	cmp	eax, 5
	jbe	lend ; JNA is the same (when insigned comparison)
	test	ebx, ebx
	jz	lend
	; x
lend:
```

```asm
	; if (eax > 5 || ebx) x
	cmp	eax, 5
	ja	l1
	test	ebx, ebx
	jz	lend
l1:
	; x
lend:
```
```asm
	; if (eax > 5 || ebx) x else y
	cmp	eax, 5
	ja	l1
	test	ebx, ebx
	jz	l2
l1:	; x
	jmp	lend
l2:	; y
lend:
```
```asm
	; It is the example of optimisation.
	; uint x
	; if (x >= 3 && x < 7) y
	mov	edx, x ; x is the register with value x. It is also possible to use lea ecx, [x - 3]
	sub	edx, 3
	cmp	edx, 4
	jae	lend
	; y
lend:
	; с int это тоже работает
	; int x
	; if (x - 3u < 4u) y
```

Как писать do while.
```
do
	x;
while (eax < 5);
```
```asm
l1:	; x
	cmp	eax, 5
	jb l1
```

А теперь while
```
while (eax < 5) x;
```
Это тупой код, здесь лишний переход.
```asm
l1:	cmp	eax, 5
	jnb 	lend
	; x
	jmp	l1
lend:	
```
А можно
```asm
	cmp	eax, 5
	jnb	lend
l1:	; x
	cmp	eax, 5
	jb l1
lend:
```

Это то же самое, что и код дальше. Компиляторы часто оптимизируют while до do while.
```
if (eax < 5)
	do
		x;
	while (eax < 5);
```

А теперь for.
```
for (eax=0; eax < 5; eax++)
	x;
```

```
eax = 0;
if (eax < 5) // скорее всего будет удалено компилятором
	do
		x;
		eax++;
	while (eax < 5)
```

```asm
l1:	x
	inc	eax
	cmp	eax, ebx
	jb	l1
```

Чтобы оптимизировать данный код можно
```
for (eax = ebx; eax > 0; eax --)
	x;
```
```asm
mov	eax, ebx
l1:	x
	dec	eax
	jnz	l1 ; нельзя писать ja, потому что dec не ставит флаг переноса
```

dec и jnz объединяются. Прямо как cmp и jcc. Это называется macrofusion. При этом dec не макрофьюзится с jcc, которые используют флаг переноса.

Теперь попробуем вправить диапазон, который проходит eax. То есть eax = ebx - 1 .. 0, а не ebx .. 1, как сейчас
```asm
lea	eax, [ebx - 1]
l1:	x
	sub	eax, 1
	jnc 	l1
```
или
```asm
lea	eax, [ebx - 1]
l1:	x
	dec	eax
	jns 	l1
```

Теперь попробуем идти в нужную сторону
```
for (eax = -ebx; eax < 0; eax++)
```

```asm
l1:	x
	inc	eax
	jnz	l1
```
Это круто для массивов. Например
```
for (eax = -ebx; eax < 0; eax++)
	ecx[eax]++ ; ecx это массив dword
```
```asm
	lea	ecx, [ecx + ebx * 4]
	mov	eax, ebx
	neg	eax
l1:	inc 	dword [ecx + eax * 4]
	inc	eax
	jnz	l1
```
Надо не забывать, что во всех этих пример опускается внешний if, потому что предполагается, что все эти циклы выполнятся хотя бы 1 раз.

#### switch
```
switch (eax) {
	case 1:
	case 2:
		x;
		break;
	case 3: y;
	case 5: z;
}
```

В Си есть жёcткие ограничения на switch. Под case только константы времени компиляции. Под switch только целочисленные значения (в том числе enum).<br>
Такие ограничения обусловлены тем, что только при них возможно оптимизировать switch так, чтобы он был быстрее, чем набор if.

```asm
	cmp	eax, 5 ; проверка, что мы не вылезли за табличку
	ja	lend
	jmp	[table + eax * 4]
l1:	x
	jmp	lend
l2:	y
l3:	z
lend:

	.rdata
table:	dd	lend, l1, l1, l2, lend, l3
```

Если значения в case очень далеко друг от друга, то оптимизация не ведётся.

global делает метку видимой снаружи. extern 

```
 extern "C" int _cdecl print(char *p) // _сdecl это конвенция вызова по умолчанию. Её можно не указывать 
```

gdb with gui

olli dbg 2
