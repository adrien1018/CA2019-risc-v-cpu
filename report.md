# 2019 Computer Architecture Project 1

## Member
* 資工三 b06902021 吳聖福
    * Design the datapath(include pipline).
    * Design and implement all the instructions.
    * Design and implement the hazard detection.
    * Design and implement fowarding control.
* 資工三 b06902026 吳秉柔
    * Split the datapath into five stages(IF, ID, EX, MEM, WB).
    * Design and implement the IF-ID, ID-EX, and EX-MEM pipline register.
    * Design the MEM-WB pipline register.
* 資工三 b06902093 王彥仁
    * Implement the MEM-WB stage pipline register.
    * Calculate the number of stall and flush.
    * Test and check the correctness of all the components and the output.
    * Write the report.

## Design & implementation
### Datapath
![](https://i.imgur.com/4gCP1hI.jpg)


### CPU.v
Connect each wire as in our datapath.

### MUX32.v
There are two kinds of MUX32 in our MUX32.v. 

The first is MUX32_2, which has two inputs and one control signal to decide which one is the output.
D
The second is MUX32_4, which has four inputs and one control signal to decide which one is the output.

### Sign_Extend.v
For each type instruction, calculate the result of Immediate_Gen.

### Pipline_Reg.v
This file contains four modules -- IF_ID, ID_EX, and EX_MEM, MEM_WB. Each module is used to represent a pipeline register between two stages.

### Opcode.v
Just define all the opcode we use.

### Hazard_Detection.v
In this project, hazard appears only in the following two situations:
1. an arithmetic instruction behind a load instruction, and the following is an example:
    ```
    load x1 offset(x2)
    add x1 x3 x4
    ```
    For this situation, we need **one stall, and then EX stage forward to ID stage**.
2. an store instruction behind a load instruction as following:
    ```
    ld x1 offset(x2)
    sd x3 offset(x4)
    ```
    and this situations can be splited into the following two cases:
    * if x1 = x3 -> **WB stage forward to MEM stage**
    * if x1 = x4 -> **one stall, and then EX stage foward to ID stage**

Because the above three cases, there are three fowarding in our datapath, and this file is to implement the above idea.

### Control.v
A module which decide all the control signals.

### ALU.v
Our ALU would complete the following operations:
1. ADD: calculate the **sum** of two values.
2. SUB, BEQ, BNE: need to calculate the **difference** of two values.
5. SLL: **left shift**.
6. SRL, SRA: need to calculate **right shift**.
7. SLT, BLT, BGE: need to **compare** two signed values
8. SLTU, BLTU, BGEU: need to **compare** two unsigned values
9. XOR: calculate the **exclusive or** of two values.
10. OR: calculate the **or** of two values.
11. AND: calculate the **and** of two values.
12. MUL: Multiply RS1 register and RS2 register. The result of $2 \times$ $64$-bit operation will be generated, and the lowest $64$ bit of the result will be written into Rd register.
13. MULH, MULHSU, MULHU: Multiply RS1 register and RS2 register. The result of $2 \times$ $64$-bits will be generated, and the highest $64$ bit of the result will be written into Rd register. Mulh is $signed \times signed$, mulhu is $unsigned \times unsigned$, mulhsu is $signed \times unsigned$
14. DIV: divide two signed values.
15. DIV: divide two unsigned values.
16. REM: calculate the remainder of two signed values.
17. REMU: calculate the remainder of two unsigned values.


### Adder.v
Input two 32-bit integers and output the sum of two inputs.

### Branch_Decision.v
Decide whether the branch needs to jump.

### testbench.v

Because of Data_Memory.v, Instruction_Memory.v, Registers.v, and PC.v must remove, we didn't list in the report.

## Difficulties encountered and solutions of this projects
1. Our first design is as the following picture. We miss one pipeline register(write-back), so the writing back to the register is earlier one cycle than the standard answer.
![](https://i.imgur.com/yixu3mq.png)

It's obvious to add a MEM-WB pipeline register to resolve the problem.
