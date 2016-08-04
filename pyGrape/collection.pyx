from indexing cimport Index 
cimport objectid
from errors import DuplicateIndexError

cdef tuple PRIMARY_INDEX_KEYS = (('_id', 1), )

cdef class Collection:

	def __cinit__(self, str name):
		print '%s.__cinit__ %s %s' % (self, self.name, name)
		self.name = name 
		self._idIndex = Index( PRIMARY_INDEX_KEYS )
		self.indexes = {
			PRIMARY_INDEX_KEYS : self._idIndex, 
		}

	cpdef insert(self, doc_or_docs):
		print 'insert', doc_or_docs
		if isinstance(doc_or_docs, list):
			for doc in doc_or_docs:
				self._insert( doc )
		else:
			self._insert(doc_or_docs)

	cpdef find(self, dict query):
		print 'find', query

	cpdef remove(self, dict query):
		pass

	cpdef createIndex(self, keys):
		cdef tuple indexKeys = tuple([tuple(key) for key in keys]) # make sure index keys is tuple of tuple
		if indexKeys in self.indexes:
			raise DuplicateIndexError(indexKeys)

		self.indexes[indexKeys] = Index( indexKeys )

	cdef _insert(self, dict doc):
		cdef tuple indexKeys
		cdef Index index
		cdef tuple indexValues

		if '_id' not in doc:
			doc['_id'] = objectid.newObjectId()
		
		for indexName, index in self.indexes.iteritems():
			indexValues = index.getIndexValues( doc ) # get the index value of doc
			index.insert( indexValues, doc )
			print index
