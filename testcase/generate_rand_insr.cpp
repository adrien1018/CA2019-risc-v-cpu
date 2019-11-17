#include <cstdio>
#include <random>
#include <string>

const std::string regs[] = {"x0", "t0", "t1", "t2", "a0", "a1", "a2", "a3", "a4", "a5", "a6", "a7"};
const std::string s1[] = {"add", "sub", "or", "and", "mul",
  "sll", "slt", "sltu", "srl", "sra", "xor", "mulh", "mulhsu", "mulhu", "div", "divu", "rem", "remu"};
const std::string s2[] = {"addi", "xori", "ori", "andi"};
const std::string s3[] = {"slli", "srli", "srai"};

const int Nregs = sizeof(regs) / sizeof(*regs);
const int Ns1 = sizeof(s1) / sizeof(*s1);
const int Ns2 = sizeof(s2) / sizeof(*s2);
const int Ns3 = sizeof(s3) / sizeof(*s3);
const int Range = 1 << 11;

int main(int argc, char** argv) {
  puts(".globl __start");
  puts("text:");
  puts("__start:");
  puts("add  t1, x0, x0");
  puts("add  gp, x0, x0");
  puts("add  sp, x0, x0");

  std::mt19937_64 gen;
  using mrand = std::uniform_int_distribution<int>;
  if (argc >= 2) gen.seed(std::stoull(argv[1]));
  for (int i = 0; i < Nregs; i++) {
    printf("addi %s, x0, %d\n", regs[i].c_str(), mrand(-Range, Range - 1)(gen));
  }
  for (int i = 0; i < 128; i++) {
    int c = mrand(0, Ns1 + Ns2 + Ns3 - 1)(gen);
    if (c < Ns1) {
      printf("%s %s, %s, %s\n", s1[mrand(0, Ns1 - 1)(gen)].c_str(),
          regs[mrand(0, Nregs - 1)(gen)].c_str(),
          regs[mrand(0, Nregs - 1)(gen)].c_str(),
          regs[mrand(0, Nregs - 1)(gen)].c_str());
    } else if (c < Ns1 + Ns2) {
      printf("%s %s, %s, %d\n", s2[mrand(0, Ns2 - 1)(gen)].c_str(),
          regs[mrand(0, Nregs - 1)(gen)].c_str(),
          regs[mrand(0, Nregs - 1)(gen)].c_str(),
          mrand(-Range, Range - 1)(gen));
    } else if (c < Ns1 + Ns2 + Ns3) {
      printf("%s %s, %s, %d\n", s3[mrand(0, Ns3 - 1)(gen)].c_str(),
          regs[mrand(0, Nregs - 1)(gen)].c_str(),
          regs[mrand(0, Nregs - 1)(gen)].c_str(),
          mrand(0, 31)(gen));
    }
  };
}
