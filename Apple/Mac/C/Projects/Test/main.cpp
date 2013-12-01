#include    <iostream>
#include    <string>
#include    <sstream>
/*------------------------------------------------------------------------------------*/
using   namespace   std;
/*------------------------------------------------------------------------------------*/
int price(){
    string  total;
    float   price;
    float   qty;
    cout    <<  "Price?\n";
    getline (cin,total);
    stringstream(total)  >>  price;
    cout    <<  "Quantity?\n";
    getline (cin,total);
    stringstream(total) >> qty;
    cout    <<  "Total:\n"  <<  price*qty   <<  endl;
    return 0;
}
/*------------------------------------------------------------------------------------*/
int penguin(){
    cout    <<  "   __\n-=(o \'.\n  \'.-.\\\n  /|  \\\\\n  \'|  ||\n  _\\_):,_\n\n" << endl;
    return  0;
}
/*------------------------------------------------------------------------------------*/
int main()
{
    penguin();
    price();
    return  0;
}
/*------------------------------------------------------------------------------------*/
