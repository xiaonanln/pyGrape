
cdef class Index:

	def __cinit__(self, tuple indexKeys):
		self.indexKeys = indexKeys

	def __str__(self):
		return str(self.indexKeys)

	cdef insert( self, tuple indexValues, dict doc ):
		print 'Index.insert', indexValues, doc

	cdef update(self, tuple oldIndexValue, tuple newIndexValue, dict doc):
		pass

	cdef tuple getIndexValues(self, dict doc):
		cdef str key 
		cdef int order
		cdef tuple vals = tuple(doc.get(key) for key, _order in self.indexKeys)
		return vals 
