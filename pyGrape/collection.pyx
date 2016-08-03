from . cimport indexing

cdef class Collection:

	cdef readonly str name 
	cdef indexing.Index primary_index

	def __cinit__(self, str name):
		print '%s.__cinit__ %s' % (self, name)

		self.name = name 

	cpdef insert(self, doc_or_docs):
		print 'insert', doc_or_docs

	cpdef find(self, dict query):
		print 'find', query

	cpdef remove(self, dict query):
		pass

	cpdef create_index(self, keys):
		pass