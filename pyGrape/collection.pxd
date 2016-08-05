cimport indexing

cdef class Collection:

	cdef readonly str name 
	cdef dict indexes
	cdef indexing.Index _idIndex

	cpdef insert(self, doc_or_docs)

	cpdef find(self, dict query)

	cpdef remove(self, dict query)

	cpdef createIndex(self, keys)

	cdef _insert(self, dict doc)

	cdef _updateOne(self, dict filter, dict update, bint upsert)

	cdef list _getSearchPlan(self, dict query)