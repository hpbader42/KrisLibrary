# Finds KrisLibrary
# defines the following symbols:
# - KRISLIBRARY_INCLUDE_DIRS
# - KRISLIBRARY_LIBRARIES
# - KRISLIBRARY_DEFINITIONS

IF(NOT KRISLIBRARY_ROOT)
  SET(KRISLIBRARY_ROOT "${CMAKE_SOURCE_DIR}/.."
     CACHE PATH
     "Path for finding KrisLibrary external dependencies"
     FORCE)
ENDIF( )

#initialize to empty string
SET(KRISLIBRARY_DEFINITIONS "")
SET(KRISLIBRARY_INCLUDE_DIRS "")
SET(KRISLIBRARY_LIBRARIES "")

#First check CMAKE_COMPILER - 
#MESSAGE(${CMAKE_CXX_COMPILER})

if(CMAKE_VERSION VERSION_LESS "3.1.0")
  MESSAGE("Old version of CMAKE - can't check compiler")
else(CMAKE_VERSION VERSION_LESS "3.1.0")
  include(CheckCXXCompilerFlag) 
  CHECK_CXX_COMPILER_FLAG("-std=c++11" COMPILER_SUPPORTS_CXX11) 

  include(CheckIncludeFileCXX REQUIRED)
  CHECK_INCLUDE_FILE_CXX(thread HAVE_CPP_THREAD)

  if(HAVE_CPP_THREAD)
    SET(C11_ENABLED ON)
    SET(CMAKE_CXX_STANDARD 11)
    MESSAGE("Compling with C++11")
    #SET(CMAKE_CXX_STANDARD_REQUIRED ON)
  else(HAVE_CPP_THREAD)
    MESSAGE("C11 compiler not available")
  endif(HAVE_CPP_THREAD)
endif(CMAKE_VERSION VERSION_LESS "3.1.0")

if(C11_ENABLED)
  set(KRISLIBRARY_DEFINITIONS ${KRISLIBRARY_DEFINITIONS} -DUSE_CPP_THREADS)
else(C11_ENABLED)
  # Boost threads vs pthreads
  SET(Boost_USE_STATIC_LIBS OFF)
  SET(Boost_USE_MULTITHREADED ON)
  SET(Boost_USE_STATIC_RUNTIME OFF)
  # Boost settings
  set(Boost_NO_BOOST_CMAKE ON CACHE BOOL "Enable fix for FindBoost.cmake" )
  add_definitions(-DBOOST_ALL_NO_LIB) # Don't use 'pragma lib' on Windows
  add_definitions(-DBoost_NO_BOOST_CMAKE) # Fix for CMake problem in FindBoost
  if(NOT Boost_USE_STATIC_LIBS)
  add_definitions(-DBOOST_TEST_DYN_LINK) # generates main() for unit tests
  endif()
  FIND_PACKAGE(Boost COMPONENTS thread system)
  IF(Boost_FOUND)
    SET(KRISLIBRARY_DEFINITIONS ${KRISLIBRARY_DEFINITIONS} -DHAVE_BOOST=1 -DUSE_BOOST_THREADS=1)
    SET(KRISLIBRARY_INCLUDE_DIRS ${KRISLIBRARY_INCLUDE_DIRS} ${Boost_INCLUDE_DIR})
    SET(KRISLIBRARY_LIBRARIES ${KRISLIBRARY_LIBRARIES} ${Boost_LIBRARIES})
  ELSE(Boost_FOUND)
    MESSAGE("Boost library not found, trying pthreads for multithreading...")
    FIND_PACKAGE(pthreads)
    IF(pthreads_FOUND) 
      SET(KRISLIBRARY_DEFINITIONS ${KRISLIBRARY_DEFINITIONS} -USE_PTHREADS)
      SET(KRISLIBRARY_LIBRARIES ${KRISLIBRARY_LIBRARIES} pthreads)
    ENDIF(pthreads_FOUND)
  ENDIF(Boost_FOUND)
ENDIF(C11_ENABLED)

# GLUI
OPTION(USE_GLUI "Build with GLUI support" ON)
IF(USE_GLUI)
  SET(GLUI_ROOT_DIR "${KRISLIBRARY_ROOT}/glui-2.36/src" CACHE PATH "Root of src directory in GLUI Package" FORCE)
  # GLUI
  FIND_PACKAGE(GLUI)
  IF(GLUI_FOUND)
    MESSAGE("GLUI library found")
    SET(KRISLIBRARY_DEFINITIONS ${KRISLIBRARY_DEFINITIONS} -DHAVE_GLUI=1)
    SET(KRISLIBRARY_INCLUDE_DIRS ${KRISLIBRARY_INCLUDE_DIRS} ${GLUI_INCLUDE_DIR} )
    SET(KRISLIBRARY_LIBRARIES ${KRISLIBRARY_LIBRARIES} ${GLUI_LIBRARY})
  ELSE(GLUI_FOUND)
    MESSAGE("GLUI library not found, setting HAVE_GLUI=0")
  ENDIF(GLUI_FOUND)
ENDIF(USE_GLUI)

# GLUT
OPTION(USE_GLUT "Build with GLUT support" ON)
IF(USE_GLUT)
  FIND_PACKAGE(GLUT)
  IF(GLUT_FOUND)
    MESSAGE("GLUT library found")
    SET(KRISLIBRARY_DEFINITIONS ${KRISLIBRARY_DEFINITIONS} -DHAVE_GLUT=1)
    SET(KRISLIBRARY_INCLUDE_DIRS ${KRISLIBRARY_INCLUDE_DIRS} ${GLUT_INCLUDE_DIR})
    SET(KRISLIBRARY_LIBRARIES ${KRISLIBRARY_LIBRARIES} ${GLUT_LIBRARIES})
  ELSE(GLUT_FOUND)
    MESSAGE("GLUT library not found, setting HAVE_GLUT=0")
  ENDIF(GLUT_FOUND)
ENDIF(USE_GLUT)

# OpenGL
FIND_PACKAGE(OpenGL REQUIRED)
SET(KRISLIBRARY_INCLUDE_DIRS ${KRISLIBRARY_INCLUDE_DIRS} ${OPENGL_INCLUDE_DIR})
SET(KRISLIBRARY_LIBRARIES ${KRISLIBRARY_LIBRARIES} ${OPENGL_LIBRARIES})

# GLPK
OPTION(USE_GLPK "Build with GLPK support" ON)
IF(USE_GLPK)
  SET(GLPK_ROOT "${KRISLIBRARY_ROOT}/glpk-4.52" CACHE PATH "Root of GLPK Package" FORCE)
  FIND_PACKAGE(GLPK)
  IF(GLPK_FOUND)
    MESSAGE("GLPK library found")
    SET(KRISLIBRARY_DEFINITIONS ${KRISLIBRARY_DEFINITIONS} -DHAVE_GLPK=1)
    SET(KRISLIBRARY_INCLUDE_DIRS ${KRISLIBRARY_INCLUDE_DIRS} ${GLPK_INCLUDE_DIR})
    SET(KRISLIBRARY_LIBRARIES ${KRISLIBRARY_LIBRARIES} ${GLPK_LIBRARY})
  ELSE(GLPK_FOUND)
    MESSAGE("GLPK library not found, setting HAVE_GLPK=0")
  ENDIF(GLPK_FOUND)
ENDIF(USE_GLPK)

# TinyXML
SET(TINYXML_ROOT "${KRISLIBRARY_ROOT}/tinyxml"
  CACHE PATH
  "Root of TinyXML Package"
  FORCE)
FIND_PACKAGE(TinyXML)
IF(TINYXML_FOUND)
  MESSAGE("TinyXML library found")
  SET(KRISLIBRARY_DEFINITIONS ${KRISLIBRARY_DEFINITIONS} -DHAVE_TINYXML=1 -DTIXML_USE_STL)
  SET(KRISLIBRARY_INCLUDE_DIRS ${KRISLIBRARY_INCLUDE_DIRS} ${TINYXML_INCLUDE_DIR})
  SET(KRISLIBRARY_LIBRARIES ${KRISLIBRARY_LIBRARIES} ${TINYXML_LIBRARIES})
ELSE(TINYXML_FOUND)
  MESSAGE("TinyXML library not found, setting HAVE_TINYXML=0")
ENDIF(TINYXML_FOUND)

# Assimp
OPTION(USE_ASSIMP "Build with ASSIMP support" ON)
IF(USE_ASSIMP)
  SET(ASSIMP_ROOT "${KRISLIBRARY_ROOT}/assimp--3.0.1270-sdk" 
     CACHE PATH
     "Root of Assimp package"
     FORCE
  )
  FIND_PACKAGE(Assimp)
  IF(ASSIMP_FOUND)
    MESSAGE("Assimp library found")
    SET(KRISLIBRARY_DEFINITIONS ${KRISLIBRARY_DEFINITIONS} -DHAVE_ASSIMP=1 ${ASSIMP_DEFINITIONS})
    SET(KRISLIBRARY_INCLUDE_DIRS ${KRISLIBRARY_INCLUDE_DIRS} ${ASSIMP_INCLUDE_DIR})
    SET(KRISLIBRARY_LIBRARIES ${KRISLIBRARY_LIBRARIES} ${ASSIMP_LIBRARY})
  ELSE(ASSIMP_FOUND)
    MESSAGE("Assimp library not found, setting HAVE_ASSIMP=0")
  ENDIF(ASSIMP_FOUND)
ENDIF(USE_ASSIMP)

# Open Motion Planning Library

OPTION(USE_OMPL "Build with OMPL support" OFF)
IF(USE_OMPL)
  FIND_PACKAGE(OMPL)
  IF(OMPL_FOUND)
    MESSAGE("OMPL library found")
    SET(KRISLIBRARY_DEFINITIONS ${KRISLIBRARY_DEFINITIONS} -DHAVE_OMPL=1)
    SET(KRISLIBRARY_INCLUDE_DIRS ${KRISLIBRARY_INCLUDE_DIRS} ${OMPL_INCLUDE_DIR})
    SET(KRISLIBRARY_LIBRARIES ${KRISLIBRARY_LIBRARIES} ${OMPL_LIBRARIES})
  ELSE(OMPL_FOUND)
    MESSAGE("OMPL library not found, setting HAVE_OMPL=0")
  ENDIF(OMPL_FOUND)
ENDIF(USE_OMPL)

# FreeImage
OPTION(USE_FREE_IMAGE "Build with FreeImage support" ON)
IF(USE_FREE_IMAGE)
  FIND_PACKAGE(FreeImage)
  IF(FREE_IMAGE_FOUND)
    MESSAGE("FreeImage library found")
    SET(KRISLIBRARY_DEFINITIONS ${KRISLIBRARY_DEFINITIONS} -DHAVE_FREE_IMAGE=1)
    SET(KRISLIBRARY_INCLUDE_DIRS ${KRISLIBRARY_INCLUDE_DIRS} ${FREE_IMAGE_INCLUDE_DIR})
    SET(KRISLIBRARY_LIBRARIES ${KRISLIBRARY_LIBRARIES} ${FREE_IMAGE_LIBRARY})
  ELSE(FREE_IMAGE_FOUND)
    MESSAGE("FreeImage library not found, setting HAVE_FREE_IMAGE=0")
  ENDIF(FREE_IMAGE_FOUND)
ENDIF(USE_FREE_IMAGE)

IF(WIN32)
  SET(KRISLIBRARY_DEFINITIONS ${KRISLIBRARY_DEFINITIONS} -DNOMINMAX -DGLUI_NO_LIB_PRAGMA)
  SET(KRISLIBRARY_LIBRARIES ${KRISLIBRARY_LIBRARIES} Ws2_32.lib Winmm.lib)
ENDIF(WIN32)

#USE_LOGGING
IF(WIN32)
  SET(LOG4CXX_ROOT "${KRISLIBRARY_ROOT}/KrisLibrary/logging/WIN32") 
ELSEIF(UNIX)
  SET(LOG4CXX_ROOT "${KRISLIBRARY_ROOT}/KrisLibrary/logging/UNIX") 
ELSE()
ENDIF()
FIND_PACKAGE(LOG4CXX REQUIRED)
SET(KRISLIBRARY_INCLUDE_DIRS ${KRISLIBRARY_INCLUDE_DIRS} ${LOG4CXX_INCLUDE_DIR})
SET(KRISLIBRARY_LIBRARIES ${KRISLIBRARY_LIBRARIES} ${LOG4CXX_LIBRARIES} )
set(KRISLIBRARY_DEFINITIONS ${KRISLIBRARY_DEFINITIONS} -DLOG4CXX_STATIC)

SET(KRISLIBRARY_INCLUDE_DIRS ${KRISLIBRARY_INCLUDE_DIRS}
  CACHE STRING
  "KrisLibrary include directories"
  FORCE)
SET(KRISLIBRARY_LIBRARIES ${KRISLIBRARY_LIBRARIES}
  CACHE STRING
  "KrisLibrary link libraries"
  FORCE)
SET(KRISLIBRARY_DEFINITIONS ${KRISLIBRARY_DEFINITIONS}
  CACHE STRING
  "KrisLibrary defines"
  FORCE)
