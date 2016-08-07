
from indexing cimport Index 
from indexing cimport Traveller
from indexing cimport MIN_VALUE, MAX_VALUE

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

	cpdef insertOne(self, doc_or_docs):
		if isinstance(doc_or_docs, list):
			for doc in doc_or_docs:
				self._insertOne( doc )
		else:
			self._insertOne(doc_or_docs)

	def updateOne(self, dict query, dict update, bint upsert=False):
		return self._updateOne(query, update, upsert)

	cdef _updateOne(self, dict query, dict update, bint upsert):
		# print 'updateOne', query, update, 'upsert', upsert
		cdef list searchPlan = self._generateTravelPlan(query)
		cdef Traveller tr
		cdef list docs = []
		cdef dict doc
		cdef dict oneDoc
		cdef int order 
		cdef dict q
		cdef Index index

		for index, minValues, maxValues, order, q in searchPlan:
			print 'travel', index, minValues, '->', maxValues, 'order', order, 'query', q
			tr = Traveller(index, minValues, maxValues, order)

			for doc in tr:
				if self._matchDocWithQuery(doc, q):
					oneDoc = doc
					break

		if oneDoc is None:
			return 0

		cdef list indexValuesList = [(index, index.getIndexValues(oneDoc)) for index in self.indexes.itervalues()]

		oneDoc.clear()
		oneDoc.update(update) # update the doc

		for index, oldIndexValues in indexValuesList:
			index.update(oneDoc, oldIndexValues)

	cpdef find(self, dict query):
		# print 'find', query
		cdef list searchPlan = self._generateTravelPlan(query)
		cdef Traveller tr
		cdef list docs = []
		cdef dict doc
		cdef int order 
		cdef dict q
		cdef Index index

		for index, minValues, maxValues, order, q in searchPlan:
			print 'travel', index, minValues, '->', maxValues, 'order', order, 'query', q
			tr = Traveller(index, minValues, maxValues, order)

			for doc in tr:
				if self._matchDocWithQuery(doc, q):
					docs.append(doc)

		return docs  

	cdef list _generateTravelPlan(self, dict query):
		cdef bint allKeysFoundInQuery
		cdef tuple indexKeys
		cdef Index index

		cdef Index longestIndex = None # find the longest matching index 
		cdef size_t longestIndexLen = 0
		cdef size_t indexKeysLen

		cdef list totalTravelPlan

		for indexKeys, index in self.indexes.iteritems():
			# check if this index can be used
			allKeysFoundInQuery = True
			for key, order in indexKeys:
				if key not in query: 
					allKeysFoundInQuery = False
					break 

			if not allKeysFoundInQuery:
				continue 

			indexKeysLen = len(indexKeys)
			if indexKeysLen > longestIndexLen:
				longestIndex = index 
				longestIndexLen = indexKeysLen

		if longestIndex is None:
			totalTravelPlan = [
				(self._idIndex, (MIN_VALUE, ), (MAX_VALUE, ), 1, query), 
			]
			return totalTravelPlan

		minValues = index.getIndexValues(query)
		maxValues = index.getIndexValues(query)
		return [
			(longestIndex, minValues, maxValues, 1, query)
		]

	cdef bint _matchDocWithQuery(self, dict doc, dict query):
		cdef str field
		for field, v in query.iteritems():
			val = doc.get(field)
			if val != v:
				return False 

		return True 

	cpdef remove(self, dict query):
		pass

	cpdef createIndex(self, keys):
		cdef tuple indexKeys = tuple([tuple(key) for key in keys]) # make sure index keys is tuple of tuple
		if indexKeys in self.indexes:
			raise DuplicateIndexError(indexKeys)

		self.indexes[indexKeys] = Index( indexKeys )

	cdef _insertOne(self, dict doc):
		cdef tuple indexKeys
		cdef Index index
		cdef tuple indexValues

		if '_id' not in doc:
			doc['_id'] = objectid.newObjectId()
		
		for indexKeys, index in self.indexes.iteritems():
			index.insert( doc )
