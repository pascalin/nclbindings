NCLDIR = ./ncl
RUBYDIR = /usr/lib64/ruby/1.8/x86_64-linux

CFLAGS = -fPIC -I$(NCLDIR) -I$(RUBYDIR)

INTERFACES = ncl.i nxstoken.i nxsstring.i nxsblock.i nxsreader.i nxsexception.i nxstaxablock.i nxstreesblock.i nxsassumptionsblock.i nxscharactersblock.i nxsdatablock.i nxsdistancesblock.i nxssetreader.i

NCL_OBJECTS = nxstoken.o nxsstring.o nxsblock.o nxsreader.o nxsexception.o nxstaxablock.o nxstreesblock.o nxsassumptionsblock.o nxscharactersblock.o nxsdatablock.o nxsdiscretedatum.o nxsdiscretematrix.o nxsdistancesblock.o nxsdistancedatum.o nxssetreader.o

ncl.so: ncl_wrap.o
	g++ -shared $(NCL_OBJECTS) ncl_wrap.o -o ncl.so

ncl_wrap.o: ncl_wrap.cpp $(NCL_OBJECTS)
	g++ -c $(CFLAGS) ncl_wrap.cpp

ncl_wrap.cpp: $(INTERFACES)
	swig -I$(NCLDIR) -ruby -c++ -o ncl_wrap.cpp ncl.i

%.o: ncl/%.cpp
	g++ -c $(CFLAGS) $<

clean:
	rm -rf *.o ncl.so ncl_wrap.*
