#include <iostream>
using namespace std;
char * uname;
/* Function pickUName start */
void pickUName(uname){
	/* Code start */
	cout << "Welcome to gtext!\n" << "What is your name?\n";
	cin >> uname;
	cout << "Nice to meet you, " << uname << ".\n";
	/* Code end */
}	
/* Function pickUName end */
void pickRace(){
}
/* Funtion main start */
int main(){
	/* Code start */
	pickUName(uname);
	return 0;
	/* Code end */
}
/* Function main end */
