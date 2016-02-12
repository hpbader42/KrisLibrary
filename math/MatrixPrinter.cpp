#include "MatrixPrinter.h"
#include "complex.h"
#include "ASCIIShade.h"
#include <utils/stringutils.h>
#include <iostream>
using namespace std;

namespace Math {

MatrixPrinter::MatrixPrinter(const fMatrix& m,Mode _mode)
  :fm(&m),dm(NULL),cm(NULL),delim(' '),bracket('['),mode(_mode)
{}

MatrixPrinter::MatrixPrinter(const dMatrix& m,Mode _mode)
  :fm(NULL),dm(&m),cm(NULL),delim(' '),bracket('['),mode(_mode)
{}

MatrixPrinter::MatrixPrinter(const cMatrix& m,Mode _mode)
  :fm(NULL),dm(NULL),cm(&m),delim(' '),bracket('['),mode(_mode)
{}

template<class T>
void PrintMatrix(const MatrixTemplate<T>& x,ostream& out,char delim,char bracket)
{
  char closebracket = CloseBracket(bracket);
  if(bracket) out<<bracket;
  MatrixIterator<T> v=x.begin();
  for(int i=0;i<x.m;i++,v.nextRow()) {
    if(bracket) out<<bracket;
    for(int j=0;j<x.n;j++,v.nextCol())
      out<<*v<<delim;
    if(bracket) out<<closebracket;
    if(i+1 != x.m) out<<endl;
  }
  if(bracket) out<<closebracket;
}

template<class T>
void OutputPlusMinus(ostream& out,const MatrixTemplate<T>& x,T zeroTolerance=Epsilon)
{
  MatrixIterator<T> v=x.begin();
  for(int i=0;i<x.m;i++,v.nextRow()) {
    for(int j=0;j<x.n;j++,v.nextCol()) {
      if(*v < -zeroTolerance) out<<'-';
      else if(*v > zeroTolerance) out<<'+';
      else out<<'0';
    }
    if(i+1 != x.m) out<<endl;
  }
}

void MatrixPrinter::Print(ostream& out) const
{
  switch(mode) {
  case Normal:
    if(fm) PrintMatrix(*fm,out,delim,bracket);
    else if(dm) PrintMatrix(*dm,out,delim,bracket);
    else if(cm) PrintMatrix(*cm,out,delim,bracket);
    break;
  case AsciiShade:
    if(fm) OutputASCIIShade(out,*fm);
    else if(dm) OutputASCIIShade(out,*dm);
    else if(cm) { cerr<<"Unable to output an ASCII-shaded complex matrix"<<endl; }
    break;
  case PlusMinus:
    if(fm) OutputPlusMinus(out,*fm);
    else if(dm) OutputPlusMinus(out,*dm);
    else if(cm) { cerr<<"Unable to output an +/- shaded complex matrix"<<endl; }
    break;
  }
}

ostream& operator << (ostream& out,const MatrixPrinter& mp)
{
  mp.Print(out);
  return out;
}

} //namespace Math
