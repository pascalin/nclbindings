NCLDIR = ./ncl
RUBYDIR = /usr/lib64/ruby/1.8/x86_64-linux

CFLAGS = -fPIC -I$(NCLDIR) -I$(RUBYDIR)

INTERFACES = ncl.i nxsassumptionsblock.i nxsblock.i nxscharactersblock.i nxsdatablock.i nxsdefs.i nxsdiscretedatum.i nxsdiscretematrix.i nxsdistancedatum.i nxsdistancesblock.i nxsexception.i nxsindent.i nxsreader.i nxssetreader.i nxsstring.i nxstaxablock.i nxstoken.i nxstreesblock.i nxsunalignedblock.i

NCL_OBJECTS = nxstoken.o nxsstring.o nxsblock.o nxsreader.o nxsexception.o nxstaxablock.o nxstreesblock.o

ncl.so: ncl_wrap.o
	g++ -shared $(NCL_OBJECTS) ncl_wrap.o -o ncl.so

ncl_wrap.o: ncl_wrap.cxx $(NCL_OBJECTS)
	g++ -c $(CFLAGS) ncl_wrap.cxx

ncl_wrap.cxx: ncl.i
	swig -I$(NCLDIR) -ruby -c++ ncl.i

%.o: ncl/%.cpp
	g++ -c $(CFLAGS) $<

clean:
	rm -rf *.o ncl.so ncl_wrap.cxx
