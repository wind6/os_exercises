#include <stdio.h> 
#include <stdarg.h> 

int tryArg(int a, ...){
	int temp = a, count = 0;
	va_list vl;
	va_start(vl, a);
	while(temp != -1){ 
		printf("arg%d = %d, ", ++count, temp);
		temp = va_arg(vl, int); //将当前参数转换为int类型 
	} 
	va_end(vl); 
	printf("\n");
	return count; 
} 
 
int main(int argc, char* argv[]){ 
	tryArg(1,2,3,4,5,6,7,8,9,-1);
	tryArg(0,1,-1);
}  