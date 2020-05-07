# sockout utils for ARM #

by Saumil Shah [@therealsaumil][saumil]

[saumil]: https://twitter.com/therealsaumil

## TL;DR: ##
The sockout utilities are set of minimal ARM ELF binaries to facilitate large file transfer into and out of an ARM IoT Linux target, where you only have console I/O (e.g. telnet, minicom, reverse shell, etc).

`sockbind`: listens on TCP port 4444 and dumps the contents to standard output.
`sockconnect`: reads standard input and dumps it to an IP address on port 4444.

`sockbind` behaves exactly like `nc -l -p 4444`
`sockconnect` behaves exactly like `nc <ip_address> 4444`

`sockbind` and `sockconnect` are meant to be recreated on the target using `printf` shell commands. (Refer `sockbind.cmds` and `sockconnect.cmds`)

## Shut up and give me the code ##
Here you are! Copy and paste these lines in your shell and you will have an executable `sockbind` and `sockconnect` binaries, ready to run.

### sockbind commands ###
```
rm -f sockbind
printf "%b" "\x7f\x45\x4c\x46\x01\x00\x00\x00\x00\x00\x00\x00\x00\x00\x20\x00" >> sockbind
printf "%b" "\x02\x00\x28\x00\x20\x00\x20\x00\x20\x00\x20\x00\x04\x00\x00\x00" >> sockbind
printf "%b" "\x09\x10\x8f\xe2\x11\xff\x2f\xe1\x34\x00\x20\x00\x01\x00\x00\x00" >> sockbind
printf "%b" "\x02\x20\x01\x21\x52\x40\xc8\x27\x51\x37\x00\xdf\x04\x1c\x11\xa1" >> sockbind
printf "%b" "\x10\x22\x01\x37\x00\xdf\x20\x1c\x49\x40\x02\x37\x00\xdf\x20\x1c" >> sockbind
printf "%b" "\x52\x40\x01\x37\x00\xdf\x04\x1c\x01\x23\x9b\x02\x69\x46\xc9\x1a" >> sockbind
printf "%b" "\x8d\x46\x20\x1c\x1a\x1c\x03\x27\x00\xdf\x02\x1c\x01\x20\x04\x27" >> sockbind
printf "%b" "\x00\xdf\x00\x2a\xf5\xdc\x20\x1c\x06\x27\x00\xdf\x40\x40\x01\x27" >> sockbind
printf "%b" "\x00\xdf\xc0\x46\x02\x00\x11\x5c\x00\x00\x00\x00" >> sockbind
chmod +x sockbind
```

### sockconnect commands ###
```
rm -f sockconnect
printf "%b" "\x7f\x45\x4c\x46\x01\x00\x00\x00\x00\x00\x00\x00\x00\x00\x20\x00" >> sockconnect
printf "%b" "\x02\x00\x28\x00\x20\x00\x20\x00\x20\x00\x20\x00\x04\x00\x00\x00" >> sockconnect
printf "%b" "\x09\x10\x8f\xe2\x11\xff\x2f\xe1\x34\x00\x20\x00\x01\x00\x00\x00" >> sockconnect
printf "%b" "\x02\x20\x01\x21\x52\x40\xc8\x27\x51\x37\x00\xdf\x04\x1c\x0c\xa1" >> sockconnect
printf "%b" "\x10\x22\x02\x37\x00\xdf\x01\x23\x9b\x02\x69\x46\xc9\x1a\x8d\x46" >> sockconnect
printf "%b" "\x00\x20\x1a\x1c\x03\x27\x00\xdf\x02\x1c\x20\x1c\x04\x27\x00\xdf" >> sockconnect
printf "%b" "\x00\x2a\xf5\xdc\x20\x1c\x06\x27\x00\xdf\x40\x40\x01\x27\x00\xdf" >> sockconnect
printf "%b" "\x02\x00\x11\x5c\x0a\x14\x03\x28" >> sockconnect
chmod +x sockconnect
```
## Files

#### Assembly source code ####
* `sockbind.s` - ARM assembly source for `sockbind`
* `sockconnect.s` - ARM assembly source for `sockconnect`
* `sockbind_nothumb.s` - Pure ARM assembly source for `sockbind` (no Thumb code)
* `sockconnect_nothumb.s` - Pure ARM assembly source for `sockconnect` (no Thumb code)

#### Utilities ####
* `convert_to_printf.sh` - Generates `.cmds` files for re-creating the binaries on a target ARM Linux IoT device, using only the command line
* `patch_ip` - Patches an IPv4 IP address into `sockconnect`/`sockconnect_nothumb`
* `patch_port` - Patches a port number into the `sockbind`/`sockconnect` binaries and their `_nothumb` variants

#### Cut and Paste cmds files ####
* `sockbind.cmds` - Cut and paste the contents to recreate `sockbind` from CLI
* `sockconnect.cmds` - Cut and paste the contents to recreate `sockconnect` from CLI
* `sockbind_nothumb.cmds` - Cut and paste the contents to recreate `sockbind_nothumb` from CLI
* `sockconnect_nothumb.cmds` - Cut and paste the contents to recreate `sockconnect_nothumb` from CLI

## Example 1: Transfer `gdbserver` into a device ##

Transfer a binary `gdbserver` on an ARM Linux system using `sockbind`. We assume the IP address of the ARM Linux system is 10.20.50.15.

First, we create the `sockbind` binary on the target system using the `sockbind.cmds` commands listed above.

Next, transfer `gdbserver` to the target as follows:

On the target, run `./sockbind > gdbserver; chmod +x gdbserver`

On the source system, run

```
nc 10.20.50.15 4444 < gdbserver
```

Sometimes you have to terminate the source `nc` using `Ctrl+C`.

## Example 2: Extract `/dev/mtdblock5` from a device ##

We want to copy the contents of `/dev/mtdblock5` from an ARM Linux system using `sockconnect`. We assume the IP address of the target computer is 10.20.3.40, and it is listening on port 5555.

First, we patch the `sockconnect` binary using the `patch_ip` utility, and convert the resultant binary to printable commands:

```
./patch_ip 10.20.3.40 5555 sockconnect
./convert_to_printf sockconnect > sockconnect.cmds
```

Next, we create the `sockconnect` binary on the target system using the `sockconnect.cmds` commands listed above. Connect to your device's console and paste the commands from `sockconnect.cmds` and lastly run `chmod +x sockconnect`.

Run a netcat listener on the target computer on port 4444:

```
nc -nvv -l -p 4444 > mtdblock5.bin
```

Lastly, transfer the contents of `/dev/mtdblock5` to the target computer 10.20.3.40 using:

```
dd if=/dev/mtdblock5 | ./sockconnect
```

Sometimes you have to terminate the source `nc` using `Ctrl+C`.

## Creating a minimal ELF binary ##

A few clever tricks have been employed to create a minimal `sockbind` and `sockconnect` binaries.

* Use THUMB instructions
* `strip` the binary after linking
* Remove ELF sections that do not cripple the binary (e.g. `.ARM.attributes`)
* Remove the `.shstrtab` section by truncating the ELF binary

Here is the output of `make` for `sockbind`

```
as sockbind.s -o sockbind.o
ld sockbind.o -o sockbind
strip sockbind
objcopy --remove-section .ARM.attributes sockbind
./truncate_elf.sh sockbind
185+0 records in
185+0 records out
185 bytes copied, 0.012916 s, 14.3 kB/s
```
The resultant binary is 185 bytes.

### A better method! ###

This technique is inspired by [mydzor/tinyelf-arm](https://github.com/mydzor/tinyelf-arm). Instead of linking to an ELF binary using `ld`, we shall insert a minimal ELF header directly into the assembly code, and overload certain ELF headers that do not seem to impact the process of loading. The downside with this technique is that `gdb` cannot work with the resultant binary anymore. The advantage is that it produces binaries 45 bytes smaller than my technique.

The assembly code is as follows:

```
.macro bump addr
.word \addr+0x200000
.endm

ehdr:                    /* Elf32_Ehdr                      */
    .byte   0x7F         /* e_ident                         */
    .ascii  "ELF"
    .word   1            /*                    |p_type      */
    .word   0            /*                    |p_offset    */
    .word   0x200000     /*                    |p_vaddr     */
    .word   0x280002     /* e_type & e_machine |p_paddr     */
    bump    main         /* e_version          |p_filesz    */
    bump    main         /* e_entry            |p_memsz     */
    .word   4            /* e_phoff            |p_flags     */

main:
    .code 32
    adr     r1, THUMB+1  /* e_shoff            |p_allign    */
    bx      r1           /* e_flags                         */
    .word   0x00200034   /* e_ehsize & e_phentsize          */
                         /* eoreq r0, r0, r4, lsr r0        */
    .word   0x00000001   /* e_phnum & e_shentsize           */
                         /* andeq r0, r0, r1                */

THUMB:
    .code 16
    // socket(2, 1, 0)
    mov     r0, #2
    mov     r1, #1
...
```
To build the binary, we use the following commands:

```
as program.s -o program.o
objcopy program.o -O binary program
chmod +x program
```

`objcopy` is used to extract the raw assembly code from an object file. Our raw code already contains an ELF header, which results into a smaller ELF binary. The source code in this repository uses this minimal ELF technique. The older technique is mentioned for documentation.

## Avoiding THUMB code ##

Certain older kernels do not support syscalls in THUMB mode. For such cases, we have ARM-only versions of `sockbind` and `sockconnect`. Please refer to `sockbind_nothumb.s`, `sockconnect_nothumb.s` and the respect `sockbind_nothumb.cmds` and `sockconnect_nothumb.cmds` files.

## Static ARM Binaries ##

I routinely use several statically compiled/linked ARM binaries when analysing IoT systems. A growing set of static ARM binaries can be found at https://github.com/therealsaumil/static-arm-bins 

## Closing Comments ##

I have been actively developing the [ARM-X Firmware Emulation Framework](https://armx.exploitlab.net/), for emulating ARM IoT devices. These utilities have been created during my research when I was faced with certain difficult situations.

Saumil Shah
[@therealsaumil][saumil]

