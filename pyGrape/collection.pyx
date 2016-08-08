
from indexing cimport Index 
from indexing cimport IndexTraveller
from indexing cimport MIN_VALUE, MAX_VALUE

cimport objectid
from errors import DuplicateIndexError

cdef tuple PRIMARY_INDEX_KEYS = (('_id', 1), )


cdef bint _matchDocWithQuery(dict doc, dict query):
	"""check if the doc matches the query
	"""
	cdef str field
	for field, v in query.iteritems():
		val = doc.get(field)
		if val != v:
			print '_matchDocWithQuery', doc, query, False
			return False 

	print '_matchDocWithQuery', doc, query, True
	return True 

cdef class Collection:

	def __cinit__(self, str name):
		self.name = name 
		self._idIndex = Index( PRIMARY_INDEX_KEYS )
		self.indexes = {
			PRIMARY_INDEX_KEYS : self._idIndex, 
		}

	cpdef dict insertOne(self, dict doc):
		cdef tuple indexKeys
		cdef Index index
		cdef tuple indexValues

		if '_id' not in doc:
			doc['_id'] = objectid.newObjectId()
		
		for indexKeys, index in self.indexes.iteritems():
			index.insert( doc )

		return doc 

	def updateOne(self, dict query, dict update, bint upsert=False):
		return self._updateOne(query, update, upsert)

	cdef dict _updateOne(self, dict query, dict update, bint upsert):
		# print 'updateOne', query, update, 'upsert', upsert
		cdef list searchPlan = self._generateTravelPlan(query)
		cdef IndexTraveller tr
		cdef dict doc
		cdef dict oneDoc
		cdef int order 
		cdef dict q
		cdef Index index

		for index, minValues, maxValues, order, q in searchPlan:
			print 'travel', index, minValues, '->', maxValues, 'order', order, 'query', q
			tr = IndexTraveller(index, minValues, maxValues, order)

			for doc in tr:
				if _matchDocWithQuery(doc, q):
					oneDoc = doc
					break

		if oneDoc is None:
			return None

		cdef list indexValuesList = [(index, index.getIndexValues(oneDoc)) for index in self.indexes.itervalues()]

		oneDoc.clear()
		oneDoc.update(update) # update the doc

		for index, oldIndexValues in indexValuesList:
			index.update(oneDoc, oldIndexValues)

		return oneDoc

	cpdef list updateMany(self, dict query, dict update):
		# print 'updateOne', query, update, 'upsert', upsert
		cdef list searchPlan = self._generateTravelPlan(query)
		cdef IndexTraveller tr

		cdef set visited = set()
		cdef list docs = []
		cdef dict doc
		cdef int order 
		cdef dict q
		cdef Index index
		cdef int docid

		for index, minValues, maxValues, order, q in searchPlan:
			print 'travel', index, minValues, '->', maxValues, 'order', order, 'query', q
			tr = IndexTraveller(index, minValues, maxValues, order)

			for doc in tr:
				docid = id(doc)
				if docid in visited: continue 
				visited.add(docid)
				if _matchDocWithQuery(doc, q):
					docs.append(doc)

		cdef list indexValuesList
		for doc in docs:
			indexValuesList = [(index, index.getIndexValues(doc)) for index in self.indexes.itervalues()]

			doc.clear()
			doc.update(update) # update the doc

			for index, oldIndexValues in indexValuesList:
				index.update(doc, oldIndexValues)

		return docs 

	cpdef list find(self, dict query):
		# print 'find', query
		cdef list searchPlan = self._generateTravelPlan(query)
		cdef IndexTraveller tr
		cdef list docs = []
		cdef dict doc
		cdef int order 
		cdef dict q
		cdef Index index
		cdef int docid
		cdef set visited = set()

		for index, minValues, maxValues, order, q in searchPlan:
			print 'travel', index, minValues, '->', maxValues, 'order', order, 'query', q
			tr = IndexTraveller(index, minValues, maxValues, order)

			for doc in tr:
				docid = id(doc)
				if docid in visited: continue 
				visited.add(docid)

				if _matchDocWithQuery(doc, q):
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

	cpdef size_t remove(self, dict query) :
		# print 'find', query
		cdef list searchPlan = self._generateTravelPlan(query)
		cdef IndexTraveller tr
		cdef dict doc
		cdef int order 
		cdef dict q
		cdef Index index
		cdef int counter

		cdef int docid
		cdef set visited = set()
		cdef list docs = []

		for index, minValues, maxValues, order, q in searchPlan:
			print 'travel', index, minValues, '->', maxValues, 'order', order, 'query', q
			tr = IndexTraveller(index, minValues, maxValues, order)

			for doc in tr:
				docid = id(doc)
				if docid in visited: continue 
				visited.add(docid)

				if _matchDocWithQuery(doc, q):
					docs.append(doc)

		for doc in docs:
			for index in self.indexes.itervalues():
				index.remove( doc )

		return len(docs)

	cpdef void createIndex(self, keys):
		cdef tuple indexKeys = tuple([tuple(key) for key in keys]) # make sure index keys is tuple of tuple
		if indexKeys in self.indexes:
			raise DuplicateIndexError(indexKeys)

		self.indexes[indexKeys] = Index( indexKeys )
