#include <iostream>

#include "used1.hpp"
#include "used2.hpp"

using namespace std;

int main(){
	cout << "used1: " << used1::version() << endl;
	cout << "used2: " << used2::version() << endl;
	return 0;
}
