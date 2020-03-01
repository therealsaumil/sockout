# sockout-ARM #

by Saumil Shah [@therealsaumil][saumil]

[saumil]: https://twitter.com/therealsaumil

A minimal ARM ELF binary (185 bytes) to listen on TCP port 4444 and dump the contents to standard output. Use `sockout` to transfer larger binaries on an ARM Linux target where you have only console I/O. (e.g. telnet, minicom, reverse shell, etc).

`sockout` is meant to be recreated on the target using `printf` shell commands.

## TL;DR: Give me the code ##

Here you are! Copy and paste these 13 lines in your shell and you will have an executable `sockout` binary, ready to run.

```
printf "%b" "\x7f\x45\x4c\x46\x01\x01\x01\x00\x00\x00\x00\x00\x00\x00\x00\x00" >> sockout
printf "%b" "\x02\x00\x28\x00\x01\x00\x00\x00\x54\x00\x01\x00\x34\x00\x00\x00" >> sockout
printf "%b" "\xcc\x00\x00\x00\x00\x02\x00\x05\x34\x00\x20\x00\x01\x00\x28\x00" >> sockout
printf "%b" "\x03\x00\x02\x00\x01\x00\x00\x00\x00\x00\x00\x00\x00\x00\x01\x00" >> sockout
printf "%b" "\x00\x00\x01\x00\xb8\x00\x00\x00\xb8\x00\x00\x00\x05\x00\x00\x00" >> sockout
printf "%b" "\x00\x00\x01\x00\x01\x10\x8f\xe2\x11\xff\x2f\xe1\x02\x20\x01\x21" >> sockout
printf "%b" "\x52\x40\xc8\x27\x51\x37\x00\xdf\x04\x1c\x11\xa1\x10\x22\x01\x37" >> sockout
printf "%b" "\x00\xdf\x20\x1c\x49\x40\x02\x37\x00\xdf\x20\x1c\x52\x40\x01\x37" >> sockout
printf "%b" "\x00\xdf\x04\x1c\x01\x23\x9b\x02\x69\x46\xc9\x1a\x8d\x46\x20\x1c" >> sockout
printf "%b" "\x1a\x1c\x03\x27\x00\xdf\x02\x1c\x01\x20\x04\x27\x00\xdf\x00\x2a" >> sockout
printf "%b" "\xf5\xdc\x20\x1c\x06\x27\x00\xdf\x40\x40\x01\x27\x00\xdf\xc0\x46" >> sockout
printf "%b" "\x02\x00\x11\x5c\x00\x00\x00\x00\x00" >> sockout
chmod +x sockout
```

## Usage ##

`sockout` behaves exactly like `nc -l -p 4444`

### Example: ###

Transfer a binary `gdbserver` on an ARM Linux system using `sockout`. We assume the IP address of the ARM Linux system is 10.20.50.15.

First, we create the `sockout` binary on the target system using the 13 commands listed above.

## Creating a minimal ELF binary ##

A few clever tricks have been employed to create a minimal `sockout` binary. The binary is currently 158 bytes long.

* Use THUMB instructions
* `strip` the binary after linking
* Remove ELF sections that do not cripple the binary (e.g. `.ARM.attributes`)
* Remove the `.shstrtab` section by truncating the ELF binary

Here is the output of `make`

```
krafty@arm6:~/sockout$ make
as sockout.s -o sockout.o
ld sockout.o -o sockout
strip sockout
objcopy --remove-section .ARM.attributes sockout
./truncate_elf.sh sockout
185+0 records in
185+0 records out
185 bytes copied, 0.012916 s, 14.3 kB/s
./convert_to_printf.sh sockout
printf "%b" "\x7f\x45\x4c\x46\x01\x01\x01\x00\x00\x00\x00\x00\x00\x00\x00\x00" >> sockout
printf "%b" "\x02\x00\x28\x00\x01\x00\x00\x00\x54\x00\x01\x00\x34\x00\x00\x00" >> sockout
printf "%b" "\xcc\x00\x00\x00\x00\x02\x00\x05\x34\x00\x20\x00\x01\x00\x28\x00" >> sockout
printf "%b" "\x03\x00\x02\x00\x01\x00\x00\x00\x00\x00\x00\x00\x00\x00\x01\x00" >> sockout
printf "%b" "\x00\x00\x01\x00\xb8\x00\x00\x00\xb8\x00\x00\x00\x05\x00\x00\x00" >> sockout
printf "%b" "\x00\x00\x01\x00\x01\x10\x8f\xe2\x11\xff\x2f\xe1\x02\x20\x01\x21" >> sockout
printf "%b" "\x52\x40\xc8\x27\x51\x37\x00\xdf\x04\x1c\x11\xa1\x10\x22\x01\x37" >> sockout
printf "%b" "\x00\xdf\x20\x1c\x49\x40\x02\x37\x00\xdf\x20\x1c\x52\x40\x01\x37" >> sockout
printf "%b" "\x00\xdf\x04\x1c\x01\x23\x9b\x02\x69\x46\xc9\x1a\x8d\x46\x20\x1c" >> sockout
printf "%b" "\x1a\x1c\x03\x27\x00\xdf\x02\x1c\x01\x20\x04\x27\x00\xdf\x00\x2a" >> sockout
printf "%b" "\xf5\xdc\x20\x1c\x06\x27\x00\xdf\x40\x40\x01\x27\x00\xdf\xc0\x46" >> sockout
printf "%b" "\x02\x00\x11\x5c\x00\x00\x00\x00\x00" >> sockout
chmod +x sockout
```

