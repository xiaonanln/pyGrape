import os

if os.system('buildPyGrape.bat') != 0:
	exit(1)

import pyGrape
from pyGrape.collection import Collection

c = Collection("test")
c.createIndex( [('a', 1), ] )
c.createIndex( [('a', -1), ] )

def testInsertOne(doc):
	print '>>> insertOne doc %s: %s' % (doc, c.insertOne(doc))

def testFind(query):
	docs = c.find(query)
	print '>>> Find docs %s: %s' % (query, docs)

def testUpdateOne(query, update):
	ret = c.updateOne(query, update)
	print '>>> updateOne %s: %s: %s' % (query, update, ret)

testInsertOne({})
testInsertOne({'a': 100})

testFind({})
testFind({'a': 100})
testFind({'a': 200})

testUpdateOne({}, {'a': 200})
testFind({})
testFind({'a': 100})
testFind({'a': 200})