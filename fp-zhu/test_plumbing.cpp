#include <assert.h>
#include <iostream> //.h
//#include "test_plumbing.h"
#include "data.cpp"

using namespace std;

void scan1_DB(Data* fdat)
{
	int i,j;
	Transaction *Tran = new Transaction;
	assert(Tran!=NULL);

	int TRANSACTION_NO=0;

	while(Tran = fdat->getNextTransaction(Tran))
	{
		for(int i=0; i<Tran->length; i++)
		{
			cout << Tran->t[i] << ",";
		}
		cout << endl;
		TRANSACTION_NO++;
	}
	cout << "read " <<  TRANSACTION_NO << " transactions " << endl;
}

int main(int argc, char **argv)
{
	if (argc < 2)
	{
	  cout << "usage: fmi <infile> " << endl;
	  exit(1);
	}

	Data* fdat=new Data(argv[1]);

	if(!fdat->isOpen()) {
		cerr << argv[1] << " could not be opened!" << endl;
		exit(2);
	}
	scan1_DB(fdat);
	//scan2
	scan1_DB(fdat);

}
