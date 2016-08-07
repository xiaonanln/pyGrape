cpdef tuple MIN_VALUE
cpdef tuple MAX_VALUE

cdef class Index:
	cdef tuple indexKeys
	cdef dict docs

	cdef void insert(self, dict doc )
	
	cdef void remove(self, dict doc )

	cdef void update(self, dict doc, tuple oldIndexValues)

	cdef tuple getIndexValues(self, dict doc)

cdef class IndexTraveller:
	cdef Index index
	cdef list indexValuesDocs
	cdef int pos
