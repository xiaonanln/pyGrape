from . cimport indexing

cdef class Collection:

	cdef readonly str name 
	cdef indexing.Index primary_index

	cpdef insert(self, doc_or_docs)

	cpdef find(self, dict query)

	cpdef remove(self, dict query)

	cpdef create_index(self, keys)
