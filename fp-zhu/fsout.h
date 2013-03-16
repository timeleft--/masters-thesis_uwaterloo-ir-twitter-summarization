#ifndef _FSOUT_CLASS
#define _FSOUT_CLASS

#include <stdio.h>

class FSout
{
 public:

  FSout(char *filename);
  ~FSout();

  int isOpen();

  void printset(int length, int *iset);
  void printSet(int length, int *iset, int support);
  void printAsIsEndl(int length, int *iset, int offset);
  void printReverseEndl(int length, int *iset);

  void close();

 private:

  FILE *out;
};

#endif

