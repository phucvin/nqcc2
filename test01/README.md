read ../README.md

cd ../

_build/default/bin/main.exe -s test01/t01.c

_build/default/bin/main.exe -s -o test01/t01.c


cd tmp01 

git clone https://github.com/nlsandler/writing-a-c-compiler-tests.git

cd writing-a-c-compiler-tests

./test_compiler ../../_build/default/bin/main.exe --chapter 4