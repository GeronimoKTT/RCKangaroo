(c) 2024, RetiredCoder (RC)

RCKangaroo is free and open-source (GPLv3).
This software demonstrates efficient GPU implementation of SOTA Kangaroo method for solving ECDLP. 
It's part #3 of my research, you can find more details here: https://github.com/RetiredC

Discussion thread: https://bitcointalk.org/index.php?topic=5517607

<b>Features:</b>

- Lowest K=1.15, it means 1.8 times less required operations compared to classic method with K=2.1, also it means that you need 1.8 times less memory to store DPs.
- Fast, about 8GKeys/s on RTX 4090, 4GKeys/s on RTX 3090.
- Keeps DP overhead as small as possible.
- Supports ranges up to 170 bits.
- Both Windows and Linux are supported.

<b>Limitations:</b>

- No advanced features like networking, saving/loading DPs, etc.

<b>Prerequisites:</b>

- NVIDIA GPU (Compute Capability 6.1+, e.g. GTX 10xx, RTX 20xx, RTX 30xx, RTX 40xx series)
- NVIDIA CUDA Toolkit (version 11.x or 12.x)
- C++ Compiler (`g++` on Linux, Visual Studio MSVC on Windows)

<b>Building:</b>

<b>Linux:</b>

Run `make` to compile the application:
```bash
make
```
If your CUDA Toolkit is installed in a custom directory, you can specify `CUDA_PATH`:
```bash
make CUDA_PATH=/path/to/cuda
```
To clean build outputs:
```bash
make clean
```

<b>Windows:</b>

Open `RCKangaroo.sln` in Visual Studio (with CUDA C++ integration installed) and build the solution in `Release` `x64` configuration.

<b>Command line parameters:</b>

<b>-gpu</b>		which GPUs are used, for example, "035" means that GPUs #0, #3 and #5 are used. If not specified, all available GPUs are used. 

<b>-pubkey</b>		public key to solve, both compressed and uncompressed keys are supported. If not specified, software starts in benchmark mode and solves random keys. 

<b>-start</b>		start offset of the key. Mandatory if "-pubkey" option is specified. Supports hex strings (e.g., "1000000000000000000000" or "0x1000000000000000000000") and exponential expressions (e.g., "2^84" for puzzle #85 or "2^83" for puzzle #84). 

<b>-range</b>		bit range of private the key. Mandatory if "-pubkey" option is specified. For example, for puzzle #85 bit range is "84" (84 bits). Must be in range 32...170. 

<b>-dp</b>		DP bits. Must be in range 14...60. Low DP bits values cause larger DB but reduces DP overhead and vice versa. 

<b>-max</b>		option to limit max number of operations. For example, value 5.5 limits number of operations to 5.5 * 1.15 * sqrt(range), software stops when the limit is reached. 

<b>-tames</b>		filename with tames. If file not found, software generates tames (option "-max" is required) and saves them to the file. If the file is found, software loads tames to speedup solving. 

<b>--modulus</b> (or <b>-modulus</b>)	modulus alignment for kangaroo jumps and distances (default: 2, i.e. even keys). For example, `--modulus 2` aligns all kangaroo steps to even numbers. Setting `--modulus 4` aligns to multiples of 4.

When public key is solved, software displays it and also writes it to "RESULTS.TXT" file. 

<b>Bitcoin Puzzle Parameter Formula:</b>

For any Bitcoin <b>Puzzle #N</b> (which covers the private key range $[2^{N-1}, 2^N - 1]$):
- <b>-start</b>: <code>2^(N-1)</code> (e.g., <code>2^83</code> for Puzzle #84, <code>2^84</code> for Puzzle #85, <code>2^65</code> for Puzzle #66)
- <b>-range</b>: <code>N-1</code> (e.g., <code>83</code> for Puzzle #84, <code>84</code> for Puzzle #85, <code>65</code> for Puzzle #66)

<b>Running Examples:</b>

<b>Benchmark Mode:</b>
```bash
# Linux
./rckangaroo -dp 16 -range 84

# Windows
RCKangaroo.exe -dp 16 -range 84
```

<b>Solving Puzzle #84:</b>
```bash
# Linux
./rckangaroo -dp 16 -range 83 -start 2^83 -pubkey <PUBKEY_84>

# Windows
RCKangaroo.exe -dp 16 -range 83 -start 2^83 -pubkey <PUBKEY_84>
```

<b>Solving Puzzle #85:</b>
```bash
# Linux (using exponential 2^84 or hex 1000000000000000000000)
./rckangaroo -dp 16 -range 84 -start 2^84 -pubkey 0329c4574a4fd8c810b7e42a4b398882b381bcd85e40c6883712912d167c83e73a

# Windows
RCKangaroo.exe -dp 16 -range 84 -start 2^84 -pubkey 0329c4574a4fd8c810b7e42a4b398882b381bcd85e40c6883712912d167c83e73a
```

<b>Generate Tames:</b>
```bash
# Linux
./rckangaroo -dp 16 -range 76 -tames tames76.dat -max 10

# Windows
RCKangaroo.exe -dp 16 -range 76 -tames tames76.dat -max 10
```

Then you can restart software with same parameters to see less K in benchmark mode or add "-tames tames76.dat" to solve some public key in 76-bit range faster.

<b>Some notes:</b>

Fastest ECDLP solvers will always use SOTA/SOTA+ method, as it's 1.4/1.5 times faster and requires less memory for DPs compared to the best 3-way kangaroos with K=1.6. 
Even if you already have a faster implementation of kangaroo jumps, incorporating SOTA method will improve it further. 
While adding the necessary loop-handling code will cause you to lose about 5–15% of your current speed, the SOTA method itself will provide a 40% performance increase. 
Overall, this translates to roughly a 25% net improvement, which should not be ignored if your goal is to build a truly fast solver. 


<b>Changelog:</b>

v3.1:

- fixed "gpu illegal memory access" bug.
- some small improvements.

v3.0:

- added "-tames" and "-max" options.
- fixed some bugs.

v2.0:

- added support for 30xx, 20xx and 1xxx cards.
- some minor changes.

v1.1:

- added ability to start software on 30xx cards.

v1.0:

- initial release.