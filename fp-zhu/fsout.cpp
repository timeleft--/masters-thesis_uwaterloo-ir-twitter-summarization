#include "fsout.h"
#include "common.h"

FSout::FSout(char *filename)
{
  out = fopen(filename,"wt");
}

FSout::~FSout()
{
  if(out) fclose(out);
}

int FSout::isOpen()
{
  if(out) return 1;
  else return 0;
}

void FSout::printSet(int length, int *iset, int support)
{
//#ifdef shown 
  for(int i=0; i<length; i++) 
  {
	fprintf(out, "%d ", order_item[iset[i]]);
//	printf("%d ", order_item[iset[i]]);
  }
  fprintf(out, "(%d)\n", support);
//  printf("(%d)\n", support);
//#endif
}

void FSout::printset(int length, int *iset)
{
//#ifdef shown 
  for(int i=0; i<length; i++) 
    fprintf(out, "%d ", order_item[iset[i]]);
//#endif
}

void FSout::printAsIsEndl(int length, int *iset, int offset)
{
//#ifdef shown
  for(int i=offset; i<length; i++)
    fprintf(out, "%d ", iset[i]);
//#endif
  fprintf(out, "\n"); // the line ends in space to make it easier to parse the string
}


void FSout::printReverseEndl(int length, int *iset)
{
//#ifdef shown
  for(int i=length-1; i>=0; --i)
    fprintf(out, "%d ", iset[i]);
//#endif
  fprintf(out, "\n"); // the line ends in space to make it easier to parse the string
}

void FSout::close()
{
	fclose(out);
}

