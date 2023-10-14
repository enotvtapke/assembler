## Optimizations
`rdtscp` this command provides the most precise way to test performance. (there is also `rdtsc`, but better use `rdtscp`)
Writes in `edx:eax` number of processor tics from the reset. It also writes something in `ecx`, it is not important, but this register will be marred.

You should notice that `rdtscp` takes a long time to execute. Thus, it is pointless to measure time of really short and fast 
blocks of code.

`rdtscp` uses its own frequency to measure tics, it is unrelated with current work frequency of the processor. 

To understand better why program works slow or fast you may want to use __profilers__. Such programs allows to look for 
percentage of cache misses, time for command decoding etc.

But profilers are processor dependent. Therefore, it may be hard to find docs.
Nevertheless, it is good idea to find profiler for your own processor vendor.

Profilers may determine problematic commands wrong, you should look through near commands.

Amd profiler is worse than intel profiler.

AMD: use __performance counter API__. It has no GUI.

For profiling it is better to close everything and plug in your laptop.
Besides that, it is possible to fix frequency of processor. It also will increase the accuracy of mesurements.
(On windows it can be done using AIDA64 (_Turn off turbo_)).

msr turbo. change bits in register

Если участок кода для оптимизации маленький, можно запустить профайлер на нём много раз. Это придётся делать руками, профайлеры так не умеютю

Как посчитать модуль числа?
Option 1:
```asm
	test	eax, eax
	jns	l1
	neg	eax
l1:	
```

Option 2:
```asm
	mov	ecx, eax
	neg	ecx
	cmovns	eax, ecx
```

Option 3:
```asm
	mov	ecx, eax
	sar	ecx, 31
	xor	eax, ecx
	sub	eax, ecx ; sub -1 from eax if eax is less than 0
```

Есть latency, а есть throughput. Latency измеряет время между зависимыми командами.
Throughput это про независимые команды, которые могут быть оптимизированы процессором.
Например, если запускать option 3 в цикле и не использовать результат, то код будет мерить throughput, но не latency.


0x00FEF7C8
52 32 ed 00


(a * 2**96 + b * 2**64 + c * 2**32 + d) = 10 * q + r


