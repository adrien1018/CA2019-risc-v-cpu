#include <cstdio>
#include <random>
#include <string>

const std::string regs[] = {"x0", "t0", "t1", "t2", "a0", "a1", "a2", "a3", "a4", "a5", "a6", "a7"};
const std::string s1[] = {"add", "sub", "or", "and", "mul"};
const std::string s2[] = {"addi"};

const int Nregs = sizeof(regs) / sizeof(*regs);
const int Ns1 = sizeof(s1) / sizeof(*s1);
const int Ns2 = sizeof(s2) / sizeof(*s2);
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
    printf("addi %s, x0, %d\n", regs[i].c_str(), mrand(-Range, Range - 1)(gen));
  }
  for (int i = 0, flag = 0; i < Ninsr; i++, flag--) {
    int c = mrand(0, 5)(gen);
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
    }
  };
}
