# Checks that CMake installed version is at least 2.0
IF("${CMAKE_MAJOR_VERSION}.${CMAKE_MINOR_VERSION}" GREATER 1.9)
# This is required before searching for SWIG
SET(CMAKE_SWIG_OUTDIR ${LIBRARY_OUTPUT_PATH})
SET(NCL_SOURCE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/ncl)

# Search for swig
FIND_PATH(SWIG_DIR swig)
FIND_PACKAGE(SWIG)
IF (SWIG_FOUND)

INCLUDE(${SWIG_USE_FILE})

# Include folders containing ncl.i and ncl source
INCLUDE_DIRECTORIES(${CMAKE_CURRENT_SOURCE_DIR})
INCLUDE_DIRECTORIES(${NCL_SOURCE_PATH})

# Show SWIG c++ options is required
SET_SOURCE_FILES_PROPERTIES(ncl.i PROPERTIES CPLUSPLUS ON)

# Set all NCL required source files
SET(NCL_SRCS ${NCL_SOURCE_PATH}/nxstoken.cpp
	     ${NCL_SOURCE_PATH}/nxsstring.cpp
	     ${NCL_SOURCE_PATH}/nxsblock.cpp
	     ${NCL_SOURCE_PATH}/nxsreader.cpp
	     ${NCL_SOURCE_PATH}/nxsexception.cpp
	     ${NCL_SOURCE_PATH}/nxstaxablock.cpp
	     ${NCL_SOURCE_PATH}/nxstreesblock.cpp
	     ${NCL_SOURCE_PATH}/nxsassumptionsblock.cpp
	     ${NCL_SOURCE_PATH}/nxscharactersblock.cpp
	     ${NCL_SOURCE_PATH}/nxsdatablock.cpp
	     ${NCL_SOURCE_PATH}/nxsdiscretedatum.cpp
	     ${NCL_SOURCE_PATH}/nxsdiscretematrix.cpp
	     ${NCL_SOURCE_PATH}/nxsdistancesblock.cpp
	     ${NCL_SOURCE_PATH}/nxsdistancedatum.cpp
	     ${NCL_SOURCE_PATH}/nxssetreader.cpp)


# Process Perl bindings build
IF (CMAKE_CURRENT_BINARY_DIR MATCHES perl[/\\]?$)
FIND_PACKAGE(PerlLibs)

INCLUDE_DIRECTORIES(${PERL_INCLUDE_PATH})
SWIG_ADD_MODULE(ncl perl ncl.i ${NCL_SRCS})
SET_DIRECTORY_PROPERTIES(${CMAKE_CURRENT_BINARY_DIR} ADDITIONAL_MAKE_CLEAN_FILES nclPERL_wrap.h)

ENDIF (CMAKE_CURRENT_BINARY_DIR MATCHES perl[/\\]?$)


# Process Python bindings build
IF (CMAKE_CURRENT_BINARY_DIR MATCHES python[/\\]?$)
FIND_PACKAGE(PythonLibs)

INCLUDE_DIRECTORIES(${PYTHON_INCLUDE_PATH})
SWIG_ADD_MODULE(ncl python ncl.i ${NCL_SRCS})
SET_DIRECTORY_PROPERTIES(${CMAKE_CURRENT_BINARY_DIR} ADDITIONAL_MAKE_CLEAN_FILES nclPYTHON_wrap.h)

ENDIF (CMAKE_CURRENT_BINARY_DIR MATCHES python[/\\]?$)


# Process Ruby bindings build
IF (CMAKE_CURRENT_BINARY_DIR MATCHES ruby[/\\]?$)
FIND_PACKAGE(Ruby)

INCLUDE_DIRECTORIES(${RUBY_INCLUDE_PATH})
SWIG_ADD_MODULE(ncl ruby ncl.i ${NCL_SRCS})
SET_DIRECTORY_PROPERTIES(${CMAKE_CURRENT_BINARY_DIR} ADDITIONAL_MAKE_CLEAN_FILES nclRUBY_wrap.h)

ENDIF (CMAKE_CURRENT_BINARY_DIR MATCHES ruby[/\\]?$)


ENDIF (SWIG_FOUND)
ENDIF("${CMAKE_MAJOR_VERSION}.${CMAKE_MINOR_VERSION}" GREATER 1.9)
