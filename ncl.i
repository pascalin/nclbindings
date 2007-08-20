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

/* Allowing synonymous employment of certain STL classes */
typedef std::string string;
typedef std::ostream ostream;
typedef std::istream istream;
typedef long file_pos;

/* Working around NCL file_pos conditional typedef */
// #if defined(__MWERKS__) || defined(__DECCXX) || defined(_MSC_VER)
// 	typedef long		file_pos;
// #else
// 	typedef streampos	file_pos;
// #endif


/* Enabling default typemaps for std::strings */
%include std_string.i

/* Ignored members of NCL */
%ignore NxsBlock::CloneBlock;
%ignore	NxsCharactersBlock::GetStateSymbolIndex;

/* Conditional processing based on language of wrappers being produced */
#if defined(SWIGPERL) /* Perl customizations */


/* Perl typemaps for input/output of NxsString data*/
%typemap(in) NxsString
{
   $1.clear();
   $1.append(SvPV($input, PL_na));
}

%typemap(typecheck) NxsString
{
  $1 = SvPOK($input)? 1:0;
}

%typemap(out) NxsString
{
   $result = newSVpv($1.c_str(), 0);
}

/* Perl typemap for output of NxsStringVector */
%typemap(out) NxsStringVector&
{
  NxsStringVector::const_iterator i;
  $result = newRV_inc((SV*) newAV());
  av_extend((AV*) SvRV($result), $1->size());
  for (i=$1->begin();i!=$1->end();i++)
    {
      av_push((AV*) SvRV($result), newSVpv(i->c_str(), 0));
    }
}

/* Perl typemap for methods that receive an input stream */
%typemap(in) istream&
{
//    if (!PyString_Check($input))
//      {
//        PyErr_SetString(PyExc_TypeError, "not a string");
//        return NULL;
//      }
   $1 = new istringstream(string(SvPV($input, PL_na)));
}

/* Perl typemaps for methods that receive an output stream */
%typemap(in, numinputs=0) std::ostream &out (std::ostringstream temp)
{
  $1 = &temp;
}

%typemap(argout) std::ostream &out
{
  std::ostringstream *output = static_cast<std::ostringstream *> ($1);
  //Py_DECREF($result);
  $result = newSVpv(output->str().c_str(), 0);
}

/* Perl argout typemaps for NxsStringVector& */
%typemap(in, numinputs=0) NxsStringVector &names (NxsStringVector temp)
{
  $1 = &temp;
}

%typemap(argout) NxsStringVector &names
{
  NxsStringVector::const_iterator i;
  //Py_DECREF($result);
  $result = newRV_inc((SV*) newAV());
  av_extend((AV*) SvRV($result), $1->size());
  for (i=$1->begin();i!=$1->end();i++)
    {
      av_push((AV*) SvRV($result), newSVpv(i->c_str(), 0));
    }
}

/* Perl argout typemaps for NxsUnsignedSet& */
%typemap(in, numinputs=0) NxsUnsignedSet& (NxsUnsignedSet temp)
{
  $1 = &temp;
}

%typemap(argout) NxsUnsignedSet&
{
  NxsUnsignedSet::const_iterator i;
  //Py_DECREF($result);
  $result = newRV_inc((SV*) newAV());
  av_extend((AV*) SvRV($result), $1->size());
  for (i=$1->begin();i!=$1->end();i++)
    {
      av_push((AV*) SvRV($result), newSVnv(*i));
    }
}

/* Perl out typemap for NxsUnsignedSet& */
%typemap(out) NxsUnsignedSet&
{
  NxsUnsignedSet::const_iterator i;
  //Py_DECREF($result);
  $result = newRV_inc((SV*) newAV());
  av_extend((AV*) SvRV($result), $1->size());
  for (i=$1->begin();i!=$1->end();i++)
    {
      av_push((AV*) SvRV($result), newSVnv(*i));
    }
}

/* Perl input/output director typemaps for NxsString data  */
%typemap(directorin) NxsString
{
   $input = newSVpv($1_name.c_str(), 0);
}

%typemap(directorout) NxsString
{
   $result.clear();
   $result.append(SvPV($1, PL_na));
}

/* Perl input/output director typemaps for NxsString& data  */
%typemap(directorin) NxsString&
{
  $input = newSVpv($1_name.c_str(), 0);
}

%typemap(directorout) NxsString&
{
   $result.clear();
   $result.append(SvPV($1, PL_na));
}


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

/* Python typemap for methods that receive an input stream */
%typemap(in) istream&
{
   if (!PyString_Check($input))
     {
       PyErr_SetString(PyExc_TypeError, "not a string");
       return NULL;
     }
   $1 = new istringstream(string(PyString_AsString($input)));
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

/* Python argout typemaps for NxsStringVector& */
%typemap(in, numinputs=0) NxsStringVector &names (NxsStringVector temp)
{
  $1 = &temp;
}

%typemap(argout) NxsStringVector &names
{
  NxsStringVector::const_iterator i;
  int index=0;
  Py_DECREF($result);
  $result = PyTuple_New($1->size());
  for (i=$1->begin();i!=$1->end();i++)
    {
      PyTuple_SetItem($result, index++, PyString_FromString(i->c_str()));
    }
}

/* Python argout typemaps for NxsUnsignedSet& */
%typemap(in, numinputs=0) NxsUnsignedSet& (NxsUnsignedSet temp)
{
  $1 = &temp;
}

%typemap(argout) NxsUnsignedSet&
{
  NxsUnsignedSet::const_iterator i;
  int index=0;
  Py_DECREF($result);
  $result = PyTuple_New($1->size());
  for (i=$1->begin();i!=$1->end();i++)
    {
      PyTuple_SetItem($result, index++, PyInt_FromLong(*i));
    }
}

/* Python out typemap for NxsUnsignedSet& */
%typemap(out) NxsUnsignedSet&
{
  NxsUnsignedSet::const_iterator i;
  int index=0;
  Py_DECREF($result);
  $result = PyTuple_New($1->size());
  for (i=$1->begin();i!=$1->end();i++)
    {
      PyTuple_SetItem($result, index++, PyInt_FromLong(*i));
    }
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

/* Python input/output director typemaps for NxsString& data  */
%typemap(directorin) NxsString&
{
   $input = PyString_FromString($1_name.c_str());
}

%typemap(directorout) NxsString&
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

/* Ruby typemap for methods that receive an input stream */
%typemap(in) istream&
{
   $1 = new istringstream(string(STR2CSTR($input)));
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

/* Ruby argout typemap for NxsStringVector& */
%typemap(in, numinputs=0) NxsStringVector &names (NxsStringVector temp)
{
  $1 = &temp;
}

%typemap(argout) NxsStringVector &names
{
  NxsStringVector::const_iterator i;
  VALUE arr = rb_ary_new2($1->size());
  for (i=$1->begin();i!=$1->end();i++)
    {
      rb_ary_push(arr, rb_str_new2(i->c_str()));
    }
  $result = arr;
}

/* Ruby argout typemap for NxsUnsignedSet& */
%typemap(in, numinputs=0) NxsUnsignedSet& (NxsUnsignedSet temp)
{
  $1 = &temp;
}

%typemap(argout) NxsUnsignedSet&
{
  NxsUnsignedSet::const_iterator i;
  VALUE $result = rb_ary_new2($1->size());
  for (i=$1->begin();i!=$1->end();i++)
    {
      rb_ary_push($result, INT2FIX(*i));
    }
}

/* Ruby out typemap for NxsUnsignedSet& */
%typemap(out) NxsUnsignedSet&
{
  NxsUnsignedSet::const_iterator i;
  VALUE arr = rb_ary_new2($1->size());
  for (i=$1->begin();i!=$1->end();i++)
    {
      rb_ary_push(arr, INT2FIX(*i));
    }
  $result = arr;
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

/* Ruby input/output director typemaps for NxsString& data  */
%typemap(directorin) NxsString&
{
   $input = rb_str_new2($1_name.c_str());
}

%typemap(directorout) NxsString&
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


%include nxstoken.h
%include nxsblock.h
%include nxsreader.h
%include nxstaxablock.h
%include nxstreesblock.h
%include nxscharactersblock.h
%include nxsassumptionsblock.h
%include nxsdatablock.h
%include nxsdistancesblock.h
%include nxssetreader.h
//%include nxsstring.h
//%include nxsdistancedatum.h
//%include nxsdiscretedatum.h
//%include nxsdiscretematrix.h
//%include nxsunalignedblock.h

/* SWIG extensions to NCL Classes */
#if SWIG_VERSION >= 0x010311
%extend NxsTaxaBlock
{
  NxsStringVector &GetTaxonLabels()
    {
      unsigned int index, num = $self->GetNumTaxonLabels();
      NxsStringVector * output = new NxsStringVector();
      for (index=0;index<num;index++)
	output->push_back($self->GetTaxonLabel(index));
      return *output;
    }
}
#endif
