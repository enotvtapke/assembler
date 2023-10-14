## Invocation conventions
### Arguments passing
#### cdecl
_When function is called:_<br>
Arguments of the function are pushed on stack by the caller.
First argument of the function is pushed on stack at last. It makes varargs possible.
Caller is responsible to clear stack from arguments after function invocation.
```asm
;	f(a, b, c)
	push	c
	push	b
	push	a
	call	f
	add	esp, 12	; returns stack to initial stata
```

As such, the first argument of the function `f` can be accessed inside the function by the address `[esp + 4]`.<br>
Invoked function can change its arguments on stack. Thus, it is impossible to invoke several functions provided the arguments for them were pushed on stack only once.

#### stdcall
Called function clears stack from its argument. With this convention vararg functions are not supported.

#### thiscall
The same as `stdcall`. But pointer to `this` is written to register `ecx` before call to function. `this` pointer is just an arbitrary pointer.

#### fastcall
Pass arguments to the function using registers. Unfortunately, there are several variations of `fastcall`.
For example, what registers are used for passing arguments can differ.

### Return values passing
Small values are returned in `eax`. For example, `int` is returned in `eax` and `byte` is returned in `al`.
In addition, 64-bit values can be returned using `edx:eax`.

When values are big, memory allocation is required. <br>
In this situation, caller allocates memory, because only caller can deallocate memory later.

Pointer to the allocated memory is passed to the function as first argument (this argument is prepended to the function's argument list).
Called function copies this pointer to the eax register before return.

_In case of `thiscall` the first argument of the function can be either `this` or return value address depending on implementation._

### Side effects
Values of some registers should be preserved after function call. <br>

Values of those registers before function call should be equal to the value of the corresponding registers after function call:
* `ebx`
* `ebp`
* `esi`
* `edi`

_It means that this registers should be saved in the beginning of the function to be used in the function._

As such, registers `ax`, `cx`, `dx` can be changed during function call.

xy % a = ((x % a) * 10 + y % a) % a