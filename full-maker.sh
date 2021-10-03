# MAKE SURE TO INSTALL LIEF
# https://github.com/lief-project/LIEF

# clean previous garbage
echo "cleaning ..."
if [ -d "./build" ]; then
	rm -rf ./build
fi
mkdir build

# OFF-SITE BUILDING; NO CONTROL OVER THIS

# make closed-source .so-s
for i in libv1 libv2; do
	echo "creating $i.so ..."
	g++ -c -o build/$i.o src/$i.cpp
	gcc -shared -o build/$i.so build/$i.o
	rm build/$i.o
done

# ON-SITE BUILDING; THIS IS OUR BIT

# renaming mangled (their) symbols
echo "renaming .so symbols ..."
objcopy --redefine-sym _ZN3lib7versionEv=_ZN3lib7version11 build/libv1.so
objcopy --redefine-sym _ZN3lib7versionEv=_ZN3lib7version22 build/libv2.so
# objcopy is too stupid to rename dynamic symbols, lief used for them
python3 - <<EOF
import lief
for v in [1, 2]:
    loc = f'build/libv{v}.so'
    print('loc: ', loc)
    lib = lief.parse(loc)
    for x in lib.exported_symbols:
        if x.name == '_ZN3lib7versionEv':
            x.name = f'_ZN3lib7version{v}{v}'
    lib.write(loc)
EOF

# make our  .o-s
for i in 1 2; do
	echo "creating used$i.o ..."
	g++ -c -o build/used$i.o src/used$i.cpp
done

# renaming .o (our) symbols
echo "renaming .o symbols ..."
objcopy --redefine-sym _ZN3lib7versionEv=_ZN3lib7version11 build/used1.o
objcopy --redefine-sym _ZN3lib7versionEv=_ZN3lib7version22 build/used2.o

echo "creating main.o ..."
g++ -c -o build/main.o src/main.cpp

# make executable
echo "creating main ..."
g++ -o build/main build/main.o build/used1.o build/used2.o -Lbuild -lv1 -lv2

echo "to run main remember to add .so paths to LD_LIBRARY_PATH"
