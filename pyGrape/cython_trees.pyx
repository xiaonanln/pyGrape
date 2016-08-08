
from ctrees cimport *


cdef class _BaseTree:
	cdef node_t *root

	def __cinit__(self):
		self.root = NULL
		self.count = 0

	def __dealloc__(self):
		pass



