
cdef class Index:
	cdef tuple indexKeys
	cdef dict mapping

	cdef insert(self, tuple indexValue, dict doc )

	cdef update(self, tuple oldIndexValue, tuple newIndexValue, dict doc)

	cdef tuple getIndexValues(self, dict doc)