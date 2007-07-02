// File : ncl.i


//	Copyright (C) 2007 David Suarez Pascal
//
//	This file is part of NCL (Nexus Class Library) version 2.0.
//
//	NCL is free software; you can redistribute it and/or modify
//	it under the terms of the GNU General Public License as published by
//	the Free Software Foundation; either version 2 of the License, or
//	(at your option) any later version.
//
//	NCL is distributed in the hope that it will be useful,
//	but WITHOUT ANY WARRANTY; without even the implied warranty of
//	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
//	GNU General Public License for more details.
//
//	You should have received a copy of the GNU General Public License
//	along with NCL; if not, write to the Free Software Foundation, Inc., 
//	59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
//


%module ncl
%{
 #include "ncl.h"
%}

%include std_string.i
%include std_vector.i
//%include std_iostream.i

%apply std::string *INPUT {NxsString *};
%apply std::string &INPUT {NxsString &};
%apply std::string &OUTPUT {NxsString *};
%apply std::string *OUTPUT {NxsString &};

%template(NxsStringVector) std::vector<std::string>;

#ifdef SWIGPYTHON

%typemap(in) istream&
{
   if (!PyString_Check($input)) {
      PyErr_SetString(PyExc_TypeError, "not a string");
      return NULL;
   }
   $1 = new istringstream(string(PyString_AsString($input)));
}

// %typemap(in) ostream& {
//    if (!PyString_Check($input)) {
//       PyErr_SetString(PyExc_TypeError, "not a string");
//       return NULL;
//    }
//    $1 = new ostringstream(string(PyString_AsString($input)));
// }

// %typemap(in) NxsString
// {
//    if (!PyString_Check($input)) {
//       PyErr_SetString(PyExc_TypeError, "not a string");
//       return NULL;
//    }
//    $1 = new NxsString(PyString_AsString($input));
// }

// %typemap(out) NxsString
// {
//    $result = PyString_FromString($1.c_str());
// }

//%typemap (out) NxsStringVector

%feature("autodoc",0);

#endif

%include nxstoken.i
%include nxsblock.i
%include nxsreader.i
%include nxstaxablock.i
%include nxstreesblock.i
%include nxscharactersblock.i
%include nxsassumptionsblock.i
%include nxsdatablock.i
%include nxsdistancesblock.h
//%include nxsstring.i
//%include nxssetreader.h
//%include nxsdistancedatum.h
//%include nxsdiscretedatum.h
//%include nxsdiscretematrix.h
//%include nxsunalignedblock.h
