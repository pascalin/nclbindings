NCLDIR = ./ncl
PERLDIR = /usr/lib64/perl5/5.8.8/x86_64-linux/CORE

CFLAGS = -fPIC -I$(NCLDIR) -I$(PERLDIR)

INTERFACES = ncl.i

NCL_OBJECTS = nxstoken.o nxsstring.o nxsblock.o nxsreader.o nxsexception.o nxstaxablock.o nxstreesblock.o nxsassumptionsblock.o nxscharactersblock.o nxsdatablock.o nxsdiscretedatum.o nxsdiscretematrix.o nxsdistancesblock.o nxsdistancedatum.o nxssetreader.o

_ncl.so: ncl_wrap.o
	g++ -shared $(NCL_OBJECTS) ncl_wrap.o -o _ncl.so

ncl_wrap.o: ncl_wrap.cpp $(NCL_OBJECTS)
	g++ -c $(CFLAGS) ncl_wrap.cpp 

ncl_wrap.cpp: $(INTERFACES)
	swig -I$(NCLDIR) -perl -c++ -o ncl_wrap.cpp ncl.i

%.o: ncl/%.cpp
	g++ -c $(CFLAGS) $<

clean:
	rm -rf *.o ncl.pm* ncl_wrap.* _ncl.so
