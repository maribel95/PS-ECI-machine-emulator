# PS-ECI-machine-emulator
In this final practice, a program that emulates the execution of programs written for a given elementary machine(In that case, PS-ECI) has been implemented in 68K assembly language. These programs are written using the instruction set of the machine in question, and the emulator works for any program that respects that set.

On the one hand, the program is capable of reading from the 68K memory a sequence of instructions encoded as words, according to the instruction set of the elementary machine itself. For each of these instructions, the program applies a decoding process to determine which instruction in the set it is and will then emulate its execution. Because the given elementary machine is designed following a Von Neumann architecture, along with the instructions that make up the program, data will also be stored. On the other hand, in addition to the memory for the program and data, the emulator also reserves a series of memory locations in the 68K to represent all the registers of the elementary machine to be emulated, as well as a state register that will contain the flags.

Both registers and instruction set are 16 bits. The PS-ECI has the following registers:

- **T0** and **T1**, which are used as an interface with the memory, in addition to being used in ALU type operations as operands;
- **R2**, **R3**, **R4** and **R5**, which are general purpose and are used in ALU type operations, either as source operand or as destination operand;
- **B6** and **B7**, address registers, which are used in some instructions to access memory using an indirect addressing mode.


<img width="794" alt="Captura de pantalla 2023-11-16 a las 18 10 22" src="https://github.com/maribel95/PS-ECI-machine-emulator/assets/61268027/6b4a77f7-4b57-4409-bd3d-7c362efcf15e">

<img width="794" alt="Captura de pantalla 2023-11-16 a las 18 15 31" src="https://github.com/maribel95/PS-ECI-machine-emulator/assets/61268027/1828f287-e119-4411-a673-8f9397d29dba">



The emulation process has been divided into three different phases.

## Fetch phase

This phase consists of fetching an instruction from memory and bringing it to the program, using a register. This way you can start using it.

The process involves the following steps:






- [X] Program Counter (PC): The CPU maintains a register called the Program Counter (PC) that contains the memory address of the next instruction to be executed.
- [X] Memory Access: The CPU uses the address stored in the PC to access the main memory. The PC address is used as an index to obtain the instruction stored at that memory address.
- [X] Instruction Read: The instruction at the memory address indicated by the PC is read from memory and placed in an internal register so that the program can use it.
- [X] Program Counter Increment: After reading the instruction, the PC is incremented to point to the next memory address that contains the next instruction. This prepares the CPU for the next instruction cycle.
- [X] Decoding and Execution: The instruction in the Instruction Register is decoded to determine the operation to be performed by the CPU. Then the CPU executes the corresponding operation.
      
**NOTE**: For all emulated instructions, an e(emulation) is prefixed to the word. Ex: PC = EPC

The instructions of the program to emulate will be given in a vector called eprog.

First of all, the EPROG vector has been used, which is where all the instructions are stored. Its memory location has been reviewed through the LEA instruction. The entire vector has been traversed as the iterations of the program progressed, so that in each step the instructions of the program to be emulated were obtained. To do this, we have based ourselves on the EPC program counter, which increases its value one by one.

```assembly

MOVE.W EPC, D0
LSL.W   #1, D0  ; Multiply by 2 because it's a Word vector
LEA EPROG, A0   ; Load EPROG memory access in A0 register
ADD.W DO,A0     ; Next instruction = EPROG + 2*EPC

MOVE.W (A0), D0 ; A0 content is the instruction we want to process

MOVE.W D0, EIR  ; Set the emulate instruction in EIR
ADDQ.W #1, EPC  ; EPC counter 
```

From this point, the 68k stack is prepared to be able to execute the library subroutine for decoding the instructions.


```assembly

SUBQ.W #2, SP     ; We keep an empty space where we will enter index instruction
MOVE.W EIR, -(SP) ; We also keep space for the EIR
JSR DECOD         ; Jump to a subrutine(for decod instructions)
MOVE.W 2(SP), D1  ; Save result in D1 register
ADDQ.W #4, SP     ; Empty the stack

```
## Decoding phase

In this phase a library subroutine has been used.
In this case, the stack has been used to be able to use registers, since their content is restored once the stack subroutine has finished. This leaves more space for the use of registers within the main program.
Decoding consists of deducing the instruction contained in the EPROG vector. You look at the bits that make up the most significant part of the Word and then you can know which instruction is being processed.


```assembly

DECOD

  MOVE.W DO, -(SP)    ; We push the register that we are going to use in the subroutine
  MOVE.W 6(SP), DO    ; EIR content is in sixth position in the stack

  BTST.L #15, DO      ; We want to check if bit 15 of the instruction is 1 or 0
  BNE BIT_1
  BRA BIT_0

```

An approach based on the Huffman tree has been used to decode each instruction. The idea is to use a binary decision tree, the left branch assigns the bit the value of 1. In each right branch, the value 0 is assigned. In this way, the instruction that needs to be read is constructed in machine language.


<img width="874" alt="Captura de pantalla 2023-11-17 a las 7 13 25" src="https://github.com/maribel95/PS-ECI-machine-emulator/assets/61268027/5a4b59b3-d5d1-4b10-9c13-1dd7d88be7ad">


## Execution phase

From this point on, the fetch phase has already been programmed. As a reminder, what this phase does is look for the instruction in main memory and save it in a register so that the machine can use and process it. Then, a process of decoding the content has been carried out to know what instruction it is.
Finally, the operation of these PS-ECI emulator instructions must be programmed, and their consequent updating of the flags, which indicate the status of the CPU.

Many of the base instructions of the emulated machine are similar to those of the Easy68k assembler. So the conversion has been practically direct. However, it must be taken into account that the results of the flags, registers and operands could vary in some cases.

### Table of subrutines:


<img width="810" alt="Captura de pantalla 2023-11-17 a las 8 31 37" src="https://github.com/maribel95/PS-ECI-machine-emulator/assets/61268027/d8ad934a-8f8f-46ac-a5f5-22429ed5922c">

### 68k registers table


<img width="817" alt="Captura de pantalla 2023-11-17 a las 8 51 16" src="https://github.com/maribel95/PS-ECI-machine-emulator/assets/61268027/cb97a5cf-2e15-4700-bfba-87c283671612">








