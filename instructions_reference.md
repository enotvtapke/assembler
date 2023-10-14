`nasm -f win32 test.asm`
`gcc test.obj -m32`

or

`nasm -f elf test.asm`
`gcc test.o -m32`

These commands are used to compile and run assembler code for linux in 32-bit regime.
The fact I am using WSL is not important.
---
We have eight common registers:

* `ax` accumulator
* `cx` counter
* `dx` data
* `bx` base
* `bp` base (but different)
* `sp` stack pointer
* `si` source
* `di` destination

Currently, registers doesn't bound to data that can be stored in them.
These registers are all 16 bit only. But for registers ending with 'x' it's possible to index 8-bit halfs of them.

There are also extended 32-bit registers ('e' prefix) in 32-bit mode and 64-bit registers ('r' prefix) in 64-bit mode.

**`eax`:**

| 31 &nbsp; 16 | 15 &nbsp; 8 | 7 &nbsp; 0 |
|--------------|-------------|------------|
|              | ah          | al         |


There are other registers that can't be direct accessed by its names, but used implicitly. Some of them are useful. For example, `eflgas`. 
Different bits of `eflags` serve different purpose:
- `cf` stores information about arithmetic overflows.  
- `zf` signals whether the result of the previous operation is zero.  
- `sf` sign flag (signals whether the result of the previous operation is positive or negative)  
- `of`, `df`

Besides `eflags` exist `IP` register.  
`EIP` next command address to execute (32-bit)  
`RIP` 64-bit  

### Absolute memory addressing
In 16-bit mode:  
`[...]` is used to define absolute addresses.  
`[bx + si + offset16]` where offset16 is 16-bit const<br>
`[bp + di + offset16]`

In 32-bit syntax is more elaborated:

|     |     |     |     |     |     |          |
|-----|-----|-----|-----|-----|-----|----------|
| eax |     | eax |     | 1   |     |          |
| ... | +   | ... | *   | 2   | +   | offset32 |
| ... |     | ... |     | 4   |     |          |
| edi |     | edi |     | 8   |     |          |

esp is forbidden.

#### Move commands
`mov eax, ebx` copies value from `ebx` to `eax` <br>
At most one of arguments can index memory. <br>
For example, `mov eax, [eax]`. This command reads 4 bytes from location which address is stored in `eax` to `eax`.

`mov eax, cx` is incorrect, cause `mov` always sends equal number of bytes. <br>
`move al, ah` works fine. <br>
`mov` second argument can be constant

In general alignment is not important. With no alignment code can be just a bit slower, but it's negligible.
As such, you shouldn't think about alignment of constants in absolute addressing. 

_x86 is little endian. It means, that lower bits are written firstly in memory._

`movzx eax, cl` completes higher bits of eax with 0, 16 lower bites are copied from `cl` <br>
`movsx eax, ax` completes higher bits of eax with sign bit of ax<br>

`cmov'cc' eax, ecx` where cc is condition <br>
* `cmovz` zero flag is set
* `cmovnz` zero flag isn't set
* `cmovs` sign flag is set
* `cmovns` sign 
* `..a` (nc & nz)
* `..b` (c)
* `..ae` (nc)
* `..be` (c || z)
* `..g`
* `..l` <br>
_Conditions with 'n' index also available. You can see more in specification (it's recommended to look through spec from both intel and amd)_ <br>
It's worth mentioning that `cmov` lacks features of `mov`, for instance, second arg can't be constant.

Let us return to mov.
`mov [ecx], 5` won't compile because it's unclear how many bytes should be written to memory by `ecx` address. <br>
To resolve this issue one should use next syntax: <br>
`mov dword [ecx], 5`

_In MASM syntax `mov dword ptr [ecx], 5` is similar to the previous command_

`xchg arg1 arg2` - exchange without additional memory. It swaps values in its arguments. <br>
**`xchng` with memory is executed atomically. As such, it works really slow.**

`bswap arg1` changes endianness of the value in `arg1`

`movbe` moves data from memory with endianness alteration (note that this command is rather new) <br>

`lea reg, [mem]` loads mem to reg. This command doesn't load data from memory. Value evaluated in the square brackets is written to the `reg` as is. <br>

`cwd` ax > dx:ax fills dx with highest bit of ax <br>
`cdq` eax > edx:eax

`cbw`
`cwde`

### Arithmetic commands
* `add eax, 5` add 5 to value in `eax`, result is written `eax`. Set flags
* `adc` сложение с учётом переноса
* `sub`
* `sbb` с учётом переноса
* `mul arg32` unsigned multiplication.
* * `edx:eax =eax * arg32`
* * `dx:ax = ax * arg16`
* * `ax = al * arg8` <br>
_arg32 can't be const_
* `imul reg1, reg2` reg1 *= reg2
* * `imul reg1, reg2, const` reg1 = reg2 * const <br>
Moreover, imul supports `mul` syntax.
* `div arg32`
* * `eax = edx:eax / arg32`
* * `edx = edx:eax % arg32` <br>
_arg32 can't be const_ <br>
Division by zero leads to the program failure. OS handles division by zero.<br>
If the result is bigger than 32-bit program end up failing.
* `idiv`
* `inc arg` add 1 but doesn't affect флаг переноса (it's the only difference from `add arg, 1`)
* `dec arg` subtract 1 but doesn't affect флаг переноса
* `neg arg` change number sign (inverse all bits and add 1)

### Logical operations
_Affect flags_
* `and arg1 arg2`
* `or arg1 arg2`
* `xor arg1 arg2` <br>
_`xor eax, eax` is a common way to nullify register_ <br>
In modern processors it evaluates in 0 tact. <br>
Use `move arg1, 0` when flags shouldn't be affected or work with memory.
* `not arg`
* `cmp eax, 5` (`sub`) sets flags but doesn't change arguments
* `test` (`and`) sets flags but doesn't change arguments <br>
test is used to check if arg is zero (`test eax, eax`) <br>
or to check the value of particular bit of the argument
* `shr arg1, arg2` logical shift to the right. arg2 is either const or `cl`. In case of `cl` some higher bits could be ignored. 
For example, shift by 33 in 32-bit mode is similar to shift by 1 <br>
`shr 11111111, 2` 11111111 > 00111111 . Sets CF flag with last bit вытесненный from arg1.
* `shl ` logical shift to the left
* `sar` arithmetic shift to the right <br>
Similar to `shr` but fills result bits with the highest bits of arg1. Like division by power of 2, but round result towards -inf not to 0.
* `shld arg1, arg2` instead of filling the highest bits of the result with zeroes fill them with lower bits of `arg2`
* `shrd`
_These commands are pretty slow_
* `ror` cycle right shift 
* `rol` cycle left shift
* `rcl` cycle right shift with setting of the `CF` flag
* `rcr` cycle left shift with setting of the `CF` flag

### Commands to work with stack
* `push arg` arg can be 32 or 64 bit register or const or memory
Lowers stack pointer and loads value on stack (`sub esp, 4` and `mov [esp] arg`).
Стэк растёт вниз. <br>
Уменьшение стэк поинтера это выделение места на стэке. <br>
Увеличение стэк поинтера это уменьшения места на стэке. (как бы pop без аргумента)<br>
* `pop arg` arg can be register or memory
* `pusha(D)` push on stack all 8 common registers <br>
_`D` is used for 32-bit mod, without `D` 16-bit registers will be written_
* `popa(D)` pop all registers from stack except esp. 7 registers in total  <br>
__Важно сначала увеличивать уменьшать стэк поинтер и потом записывать значения на стэк. Потому что сохранность значений за стэком не гарантируется OS__
* `jmp label/reg/[..]` jump to `label`. address is absolute (you almost will never be using reg and memory arg)
* `jcc label` conditional jump to `label`. `cc` is condition ([cheatsheet](https://www.felixcloutier.com/x86/jcc))
* * jz
* * jns
* * ..
* `call label/reg/[..]` similar to jmp. The only difference is that `call` push on stack address of the command next to call.
* `ret` = `pop eip` (but eip is unavailable)
* `ret const` снимает адрес возврата, а потом увеличивает стэк поинтер на `const`
* `int magic_const` it is used to handle interruptions (`int 80h` invokes OS kernel, это системные вызовы (но медленные, сейчас есть `syscall`)) <br>
Похожа на `call`, но кладёт на стэк больше, чем `call`.
* `iret` обратная к `int`
* `int3` debug break, вывалиться в отладчик (точка останова)
* `nop` = `xchg eax, eax` doesn't do anything. Нужна для выравнивания, занимает 1 байт.
* `ud2 reg/[..]` команда, которой гарантировано нет. При исполнении этой команды проиходит исключение с сообщением о несуществующей команде.

https://www.felixcloutier.com/x86/