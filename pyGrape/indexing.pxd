cpdef tuple MIN_VALUE
cpdef tuple MAX_VALUE
cpdef tuple VALUE_NOT_EXISTS 

cdef class Index:
	cdef tuple indexKeys
	cdef dict docs

	cdef insert(self, tuple indexValue, dict doc )

	cdef update(self, tuple oldIndexValue, tuple newIndexValue, dict doc)

	cdef tuple getIndexValues(self, dict doc)

cdef class Traveller:
	cdef Index index
	cdef list indexValuesDocs
	cdef int pos
