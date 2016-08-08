
# use tuples as special values
cpdef tuple MIN_VALUE = ('$minValue', )
cpdef tuple MAX_VALUE = ('$maxValue', )

cdef int cmpValues(tuple v1, tuple v2):
	cdef int c
	assert len(v1) == len(v2), (v1, v2)
	for vv1, vv2 in zip(v1, v2):

		if vv2 is MIN_VALUE: # only v2 can be special values
			return 1
		elif vv2 is MAX_VALUE:
			return -1
		
		c = cmp(v1, v2)
		if c != 0:
			return c 

	return 0

cdef class Index:

	def __cinit__(self, tuple indexKeys):
		self.indexKeys = indexKeys
		self.docs = {}

	def __str__(self):
		return "Index<%s>" % ','.join(['%s@%d' % (key, order) for key, order in self.indexKeys])

	cdef void insert( self, dict doc ):
		cdef tuple indexValues = self.getIndexValues( doc ) # get the index value of doc
		# print 'Index.insertOne', self, indexValues, doc
		try:
			self.docs[indexValues].append(doc)
		except KeyError:
			self.docs[indexValues] = [doc]

	cdef void remove(self, dict doc):
		cdef tuple indexValues = self.getIndexValues( doc ) # get the index value of doc
		self.docs[indexValues].remove(doc)

	cdef void update(self, dict doc, tuple oldIndexValues):
		cdef tuple newIndexValues = self.getIndexValues(doc)

		if newIndexValues == oldIndexValues:
			return 

		cdef list docs = self.docs[oldIndexValues]
		docs.remove(doc)
		try:
			self.docs[newIndexValues].append(doc)
		except KeyError:
			self.docs[newIndexValues] = [doc]

	cdef tuple getIndexValues(self, dict doc):
		cdef str key 
		cdef int order
		cdef tuple vals = tuple(doc.get(key) for key, _order in self.indexKeys)
		return vals 

cdef class IndexTraveller:

	def __cinit__(self, Index index, minValues, maxValues, int order):
		self.index = index
		self.indexValuesDocs = []
		self.pos = 0

		cdef tuple indexValues
		cdef list docs

		for indexValues, docs in index.docs.iteritems():
			# print 'check', indexValues, docs, cmpValues(indexValues, minValues), cmpValues(indexValues, maxValues)
			if cmpValues(indexValues, minValues) >= 0 and cmpValues(indexValues, maxValues) <= 0:
				# satisfied
				for doc in docs:
					self.indexValuesDocs.append( (indexValues, doc) )

		self.indexValuesDocs.sort( reverse=order == -1 )
		# print 'indexValuesDocs', self.indexValuesDocs

	def __iter__(self):
		return self

	def __next__(self):
		cdef dict doc

		try: 
			doc = self.indexValuesDocs[self.pos][1]
			self.pos += 1
			return doc 
		except IndexError:
			raise StopIteration()