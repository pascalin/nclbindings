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

/* Setting modulename to "ncl" with directors enabled */
%module(directors="1") ncl
%{
 #include "ncl.h"
%}

/* Enabling directors for classes that can be subclassed */
%feature("director") NxsReader;
%feature("director") NxsToken;
%feature("director") NxsBlock;

/* Redirecting to C++ exception found running wrapper code */
%feature("director:except") {
    if ($error != NULL) {
        throw Swig::DirectorMethodException();
    }
}

/* Preventing synonimous employment of certain STL classes */
typedef std::string string;
typedef std::ostream ostream;
typedef std::istream istream;

/* Enabling default typemaps for std::strings */
%include std_string.i

/* Conditional processing based on language of wrappers being produced */
#if defined(SWIGPERL) /* Perl customizations */

#elif defined(SWIGPYTHON) /* Python customizations */


/* Python typemaps for input/output of NxsString data*/
%typemap(in) NxsString
{
   $1.clear();
   $1.append(PyString_AsString($input));
}

%typemap(typecheck) NxsString
{
  $1 = PyString_Check($input)? 1:0;
}

%typemap(out) NxsString
{
   $result = PyString_FromString($1.c_str());
}

/* Python typemap for output of NxsStringVector */
%typemap(out) NxsStringVector&
{
  NxsStringVector::const_iterator i;
  int index=0;
  $result = PyTuple_New($1->size());
  for (i=$1->begin();i!=$1->end();i++)
    {
      PyTuple_SetItem($result, index++, PyString_FromString(i->c_str()));
    }
}

/* Python typemaps for methods that receive an output stream */
%typemap(in, numinputs=0) std::ostream &out (std::ostringstream temp)
{
  $1 = &temp;
}

%typemap(argout) std::ostream &out
{
  std::ostringstream *output = static_cast<std::ostringstream *> ($1);
  Py_DECREF($result);
  $result = PyString_FromString(output->str().c_str());
}

/* Python input/output director typemaps for NxsString data  */
%typemap(directorin) NxsString
{
   $input = PyString_FromString($1_name.c_str());
}

%typemap(directorout) NxsString
{
   $result.clear();
   $result.append(PyString_AsString($1));
}

/* Enabling autogeneration of Python docstrings */
%feature("autodoc",0);

/* Modified Python docstrings for methods modified with typemaps */
%feature("autodoc", "__init__(self) -> Nxstoken") NxsToken::NxsToken;
%feature("autodoc", "Report(self) -> string") *::Report;
%feature("autodoc", "WriteAsNexus(self) -> string") *::WriteAsNexus;
%feature("autodoc", "WriteTaxLabelsCommand(self) -> string") *::WriteTaxLabelsCommand;
%feature("autodoc", "WriteTitleCommand(self) -> string") *::WriteTitleCommand;
%feature("autodoc", "GetCharSetNames(self) -> (names)") *::GetCharSetNames;
%feature("autodoc", "GetExSetNames(self) -> (names)") *::GetExSetNames;
%feature("autodoc", "GetTaxSetNames(self) -> (names)") *::GetTaxSetNames;


#elif defined(SWIGRUBY) /* Ruby customizations */

/* Sets SWIG to not warn when renaming constants according to Ruby convention */
#pragma SWIG nowarn=801

/* Ruby typemaps for input/output of NxsString data */
%typemap(in) NxsString
{
   $1.clear();
   $1.append(STR2CSTR($input));
}

%typemap(typecheck) NxsString
{
  $1 = (TYPE($input) == T_STRING)? 1:0;
}

%typemap(out) NxsString
{
  $result = rb_str_new2($1.c_str());
}

/* Ruby typemap for output of NxsStringVector */
%typemap(out) NxsStringVector&
{
  NxsStringVector::const_iterator i;
  VALUE arr = rb_ary_new2($1->size());
  for (i=$1->begin();i!=$1->end();i++)
    {
      rb_ary_push(arr, rb_str_new2(i->c_str()));
    }
  $result = arr;
}

/* Ruby typemaps for methods that receive an output stream */
%typemap(in, numinputs=0) std::ostream &out (std::ostringstream temp)
{
  $1 = &temp;
}

%typemap(argout) std::ostream &out
{
  std::ostringstream *output = static_cast<std::ostringstream *> ($1);
  $result = rb_str_new2(output->str().c_str());
}

/* Ruby input/output director typemaps for NxsString data  */
%typemap(directorin) NxsString
{
   $input = rb_str_new2($1_name.c_str());
}

%typemap(directorout) NxsString
{
   $result.clear();
   $result.append(STR2CSTR($1));
}

/* Defining NCL methods that return a bool value as Ruby predicate methods */
%predicate *::Abbreviation;
%predicate *::AtEOF;
%predicate *::AtEOL;
%predicate *::Begins;
%predicate *::BlockListEmpty;
%predicate *::EnteringBlock;
%predicate *::Equals;
%predicate *::GetActiveCharArray;
%predicate *::GetActiveTaxonArray;
%predicate *::IsActiveChar;
%predicate *::IsActiveTaxon;
%predicate *::IsAlreadyDefined;
%predicate *::IsDefaultTree;
%predicate *::IsDeleted;
%predicate *::IsDiagonal;
%predicate *::IsEliminated;
%predicate *::IsEmpty;
%predicate *::IsEnabled;
%predicate *::IsExcluded;
%predicate *::IsGapState;
%predicate *::IsInterleave;
%predicate *::IsLabels;
%predicate *::IsLowerTriangular;
%predicate *::IsMissing;
%predicate *::IsMissingState;
%predicate *::IsPlusMinusToken;
%predicate *::IsPolymorphic;
%predicate *::IsPunctuationToken;
%predicate *::IsRectangular;
%predicate *::IsRespectCase;
%predicate *::IsRootedTree;
%predicate *::IsTokens;
%predicate *::IsTranspose;
%predicate *::IsUpperTriangular;
%predicate *::IsUserSupplied;
%predicate *::IsWhitespaceToken;
%predicate *::NeedsQuotes;
%predicate *::Run;
%predicate *::StoppedOn;


#else


#warning the languages supported by this set of interfaces are Python, Perl and Ruby


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
%include nxssetreader.i
//%include nxsstring.i
//%include nxsdistancedatum.h
//%include nxsdiscretedatum.h
//%include nxsdiscretematrix.h
//%include nxsunalignedblock.h
