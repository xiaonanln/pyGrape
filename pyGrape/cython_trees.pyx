
from ctrees cimport *


cdef class _BaseTree:
	cdef node_t *root

	def __cinit__(self):
		self.root = NULL
		self.count = 0

	def __dealloc__(self):
		pass
		
	def insert(self, key, value):
		cdef int ret = ct_bintree_insert(&self.root, key, value)
		if ret < 0:
			raise MemoryError( (key, value) )

