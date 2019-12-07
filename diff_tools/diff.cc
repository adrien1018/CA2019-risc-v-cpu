#include <vector>
#include <string>
#include <cassert>
#include <fstream>
#include <iostream>
#include <algorithm>

using namespace std;

void readData(const char *file_name, 
              vector<int> &cycles,
              vector<int> &starts, 
              vector<int> &stalls,
              vector<int> &flushes,
              vector<int> &pcs, 
              vector<vector<pair<string, int> > > &registers, 
              vector<vector<pair<string, int> > > &data_mems) {
  fstream fs;
  fs.open(file_name, ios::in);
  
  if (!fs) {
    cerr << "[Error] Open file error.\n";
    exit(1);
  }

  string var, eq;
  int value;
  string comma;
  string tag, tag1, tag2;
  
  while (fs >> var >> eq >> value >> comma) {
    assert(var == "cycle" && eq == "=" && comma == ",");
    cycles.push_back(value);

    assert(fs >> var >> eq >>value >> comma);
    assert(var == "Start" && eq == "=" && comma == ",");
    starts.push_back(value);

    assert(fs >> var >> eq >>value >> comma);
    assert(var == "Stall" && eq == "=" && comma == ",");
    stalls.push_back(value);

    assert(fs >> var >> eq >>value);
    assert(var == "Flush" && eq == "=");
    flushes.push_back(value);

    assert(fs >> var >> eq >>value);
    assert(var == "PC" && eq == "=");
    pcs.push_back(value);

    assert(fs >> tag);
    assert(tag == "Registers");

    vector<pair<string, int> > now_register, now_data_mem;

    for (int row = 1; row <= 8; row++) {
      for (int column = 1; column <= 3; column++) {
        assert(fs >> var >> eq >>value >> comma);
        assert(eq == "=" && comma == ",");
        now_register.emplace_back(var, value);
      }

      assert(fs >> var >> eq >>value);
      assert(eq == "=");
      now_register.emplace_back(var, value);
    }

    for (int row = 1; row <= 8; row++) {
      assert(fs >> tag1 >> tag2 >> var >> eq >>value);
      assert(tag1 == "Data" && tag2 == "Memory:" && eq == "=");
      now_data_mem.emplace_back(var, value);
    }

    sort(now_register.begin(), now_register.end());
    sort(now_data_mem.begin(), now_data_mem.end());

    registers.push_back(now_register);
    data_mems.push_back(now_data_mem);
  }
}

template<typename T>
int calc(const vector<T> &vs1, const vector<T> &vs2) {
  assert(vs1.size() == vs2.size());
  for (int i = 0; i < (int)vs1.size(); i++) {
    bool eq = 1;
    for (int j = 0; j < (int)vs1.size() - i; j++) {
      if (vs1[j + i] != vs2[j]) {
        eq = 0;
        break;
      }
    }
    if (eq) {
      return i;
    }

    eq = 1;
    for (int j = 0; j < (int)vs2.size() - i; j++) {
      if (vs1[j] != vs2[j + i]) {
        eq = 0;
        break;
      }
    }
    if (eq) {
      return i;
    }

  }
  return -1;
}

int main(int argc, char **argv) {
  vector<int> cycles[2];
  vector<int> starts[2];
  vector<int> stalls[2];
  vector<int> flushes[2];
  vector<int> pcs[2];
  vector<vector<pair<string, int> > > registers[2];
  vector<vector<pair<string, int> > > data_mems[2];

  assert(argc == 3);
  for (int i = 0; i < 2; i++) {
    readData(argv[i + 1], cycles[i], starts[i], stalls[i], flushes[i], pcs[i], registers[i], data_mems[i]);
  }
  
  printf("cycle: %d\n", calc(cycles[0], cycles[1]));
  printf("start: %d\n", calc(starts[0], starts[1]));
  printf("stall: %d\n", calc(stalls[0], stalls[1]));
  printf("flush: %d\n", calc(flushes[0], flushes[1]));
  printf("pc: %d\n", calc(pcs[0], pcs[1]));
  printf("register: %d\n", calc(registers[0], registers[1]));
  printf("data memory: %d\n", calc(data_mems[0], data_mems[1]));
  
  return 0;
}
