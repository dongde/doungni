#include <stdio.h>

int fun(char *shellcode)
{
    char str[4] = "";
    strcpy(str, shellcode);
    printf("%s", str);

    return 1;
}

int main()
{
    char str[]="bbbbbbbbb";
    fun(str);

    return 0;
}
