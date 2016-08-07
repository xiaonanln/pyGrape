cimport indexing

cdef class Collection:

	cdef readonly str name 
	cdef dict indexes
	cdef indexing.Index _idIndex

	cpdef dict insertOne(self, dict doc)

	cpdef list find(self, dict query)

	cpdef size_t remove(self, dict query) 

	cpdef void createIndex(self, keys)

	cdef dict _updateOne(self, dict filter, dict update, bint upsert)

	cpdef list updateMany(self, dict query, dict update)

	cdef list _generateTravelPlan(self, dict query)
