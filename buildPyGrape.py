from distutils.core import setup
from Cython.Build import cythonize
import os

ext_modules = cythonize(['pyGrape/*.pyx'])
for mod in ext_modules:
	for f in mod.sources:
		if f.endswith('cython_trees.c'):
			mod.sources.append('pyGrape/ctrees.c') # build cython_trees.pyx with ctrees.c
			break 
	
setup(
  name = 'pyGrape',
  ext_modules = ext_modules,
)