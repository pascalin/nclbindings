// File : nxsassumptionsblock.i

//      Copyright (C) 2007 David Suarez Pascal
//
//      This file is part of NCL (Nexus Class Library) version 2.0.
//
//      NCL is free software; you can redistribute it and/or modify
//      it under the terms of the GNU General Public License as published by
//      the Free Software Foundation; either version 2 of the License, or
//      (at your option) any later version.
//
//      NCL is distributed in the hope that it will be useful,
//      but WITHOUT ANY WARRANTY; without even the implied warranty of
//      MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
//      GNU General Public License for more details.
//
//      You should have received a copy of the GNU General Public License
//      along with NCL; if not, write to the Free Software Foundation, Inc., 
//      59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
//

#if defined(SWIGPERL)

#elif defined(SWIGPYTHON)


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


#elif defined(SWIGRUBY)


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


#else

#endif

%include nxsassumptionsblock.h
