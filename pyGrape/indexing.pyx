
# use tuples as special values
cpdef tuple MIN_VALUE = ('$minValue', )
cpdef tuple MAX_VALUE = ('$maxValue', )
cpdef tuple VALUE_NOT_EXISTS = ('$valueNotExists', )

cdef int cmpValues(v1, v2):
	print v1, v2, v2 is MIN_VALUE, v2 is MAX_VALUE
	if v2 is MIN_VALUE: # only v2 can be special values
		return 1
	elif v2 is MAX_VALUE:
		return -1
	else:
		return cmp(v1, v2)

cdef class Index:

	def __cinit__(self, tuple indexKeys):
		self.indexKeys = indexKeys
		self.docs = {}

	def __str__(self):
		return "Index<%s>" % ','.join(['%s@%d' % (key, order) for key, order in self.indexKeys])

	cdef insert( self, tuple indexValues, dict doc ):
		print 'Index.insert', self, indexValues, doc
		try:
			self.docs[indexValues].append(doc)
		except KeyError:
			self.docs[indexValues] = [doc]

	cdef update(self, tuple oldIndexValue, tuple newIndexValue, dict doc):
		pass

	cdef tuple getIndexValues(self, dict doc):
		cdef str key 
		cdef int order
		cdef tuple vals = tuple(doc.get(key, VALUE_NOT_EXISTS) for key, _order in self.indexKeys)
		return vals 

cdef class Traveller:

	def __cinit__(self, Index index, minValues, maxValues, int order):
		self.index = index
		self.indexValuesDocs = []
		self.pos = 0

		for indexValues, docs in index.docs.iteritems():
			print 'check', indexValues, docs, cmpValues(indexValues, minValues), cmpValues(indexValues, maxValues)
			if cmpValues(indexValues, minValues) >= 0 and cmpValues(indexValues, maxValues) < 0:
				# satisfied
				self.indexValuesDocs.append( (indexValues, docs) )

		self.indexValuesDocs.sort( reverse=order == -1 )
		print 'indexValuesDocs', self.indexValuesDocs

	def __iter__(self):
		return self

	def __next__(self):
		cdef dict doc

		try: 
			doc = self.indexValuesDocs[self.pos]
			self.pos += 1
			return doc 
		except IndexError:
			raise StopIteration()