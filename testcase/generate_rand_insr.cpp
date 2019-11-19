#include <cstdio>
#include <random>
#include <string>

const std::string regs[] = {"x0", "t0", "t1", "t2", "a0", "a1", "a2", "a3", "a4", "a5", "a6", "a7"};
const std::string s1[] = {"add", "sub", "or", "and", "mul",
  "sll", "slt", "sltu", "srl", "sra", "xor", "mulh", "mulhsu", "mulhu", "div", "divu", "rem", "remu"};
const std::string s2[] = {"addi", "xori", "ori", "andi"};
const std::string s3[] = {"slli", "srli", "srai"};
const std::string s4[] = {"beq", "bne", "blt", "bge", "bltu", "bgeu"};
const std::string s5[] = {"lb", "lh", "lw", "lbu", "lhu", "sb", "sh", "sw"};
const std::string s6[] = {"lui", "auipc"};

const int Nregs = sizeof(regs) / sizeof(*regs);
const int Ns1 = sizeof(s1) / sizeof(*s1);
const int Ns2 = sizeof(s2) / sizeof(*s2);
const int Ns3 = sizeof(s3) / sizeof(*s3);
const int Ns4 = sizeof(s4) / sizeof(*s4);
const int Ns5 = sizeof(s5) / sizeof(*s5);
const int Ns6 = sizeof(s6) / sizeof(*s6);
const int Range = 1 << 11;

const int Ninsr = 200;

int main(int argc, char** argv) {
  puts(".globl __start");
  puts("text:");
  puts("__start:");

  std::mt19937_64 gen;
  using mrand = std::uniform_int_distribution<int>;
  if (argc >= 2) gen.seed(std::stoull(argv[1]));
  for (int i = 0; i < Nregs; i++) {
    if (mrand(0, 1)(gen)) {
      printf("lui %s, %d\n", regs[i].c_str(), mrand(0, 1048575)(gen));
    }
    printf("addi %s, x0, %d\n", regs[i].c_str(), mrand(-Range, Range - 1)(gen));
  }
  printf("addi sp, sp, -32\n");
  for (int i = 0; i < Ninsr; i++) {
    printf("L%03d: ", i);
    int c = mrand(0, 11)(gen);
    if (c < 4) {
      printf("%s %s, %s, %s\n", s1[mrand(0, Ns1 - 1)(gen)].c_str(),
          regs[mrand(0, Nregs - 1)(gen)].c_str(),
          regs[mrand(0, Nregs - 1)(gen)].c_str(),
          regs[mrand(0, Nregs - 1)(gen)].c_str());
    } else if (c < 5) {
      printf("%s %s, %s, %d\n", s2[mrand(0, Ns2 - 1)(gen)].c_str(),
          regs[mrand(0, Nregs - 1)(gen)].c_str(),
          regs[mrand(0, Nregs - 1)(gen)].c_str(),
          mrand(-Range, Range - 1)(gen));
    } else if (c < 6) {
      printf("%s %s, %s, %d\n", s3[mrand(0, Ns3 - 1)(gen)].c_str(),
          regs[mrand(0, Nregs - 1)(gen)].c_str(),
          regs[mrand(0, Nregs - 1)(gen)].c_str(),
          mrand(0, 31)(gen));
    } else if (c < 8 && i < Ninsr - 4) {
      printf("%s %s, %s, L%03d\n", s4[mrand(0, Ns4 - 1)(gen)].c_str(),
          regs[mrand(0, Nregs - 1)(gen)].c_str(),
          regs[mrand(0, Nregs - 1)(gen)].c_str(),
          i + mrand(2, 3)(gen));
    } else if (c < 11) {
      printf("%s %s, %d(sp)\n", s5[mrand(0, Ns5 - 1)(gen)].c_str(),
          regs[mrand(0, Nregs - 1)(gen)].c_str(),
          mrand(0, 20)(gen));
    } else if (c < 12) {
      printf("%s %s, %d\n", s6[mrand(0, Ns6 - 1)(gen)].c_str(),
          regs[mrand(0, Nregs - 1)(gen)].c_str(),
          mrand(0, 1048575)(gen));
    }
  };
}
