# PS-ECI-machine-emulator
In this final practice, a program that emulates the execution of programs written for a given elementary machine(In that case, PS-ECI) has been implemented in 68K assembly language. These programs are written using the instruction set of the machine in question, and the emulator works for any program that respects that set.

On the one hand, the program is capable of reading from the 68K memory a sequence of instructions encoded as words, according to the instruction set of the elementary machine itself. For each of these instructions, the program applies a decoding process to determine which instruction in the set it is and will then emulate its execution. Because the given elementary machine is designed following a Von Neumann architecture, along with the instructions that make up the program, data will also be stored. On the other hand, in addition to the memory for the program and data, the emulator also reserves a series of memory locations in the 68K to represent all the registers of the elementary machine to be emulated, as well as a state register that will contain the flags.

Both registers and instruction set are 16 bits. The PS-ECI has the following registers:

- **T0** and **T1**, which are used as an interface with the memory, in addition to being used in ALU type operations as operands;
- **R2**, **R3**, **R4** and **R5**, which are general purpose and are used in ALU type operations, either as source operand or as destination operand;
- **B6** and **B7**, address registers, which are used in some instructions to access memory using an indirect addressing mode.


<img width="794" alt="Captura de pantalla 2023-11-16 a las 18 10 22" src="https://github.com/maribel95/PS-ECI-machine-emulator/assets/61268027/6b4a77f7-4b57-4409-bd3d-7c362efcf15e">

<img width="794" alt="Captura de pantalla 2023-11-16 a las 18 15 31" src="https://github.com/maribel95/PS-ECI-machine-emulator/assets/61268027/1828f287-e119-4411-a673-8f9397d29dba">






















