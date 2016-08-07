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

def testUpdateMany(query, update):
	ret = c.updateMany(query, update)
	print '>>> updateMany %s: %s: %s' % (query, update, ret)

def testRemove(query):
	ret = c.remove(query)
	print '>>> remove %s: %s' % (query, ret)

testInsertOne({})
testInsertOne({'a': 100})

testFind({})
testFind({'a': 100})
testFind({'a': 200})

testUpdateOne({}, {'a': 200})
testFind({})

testUpdateMany({}, {'a': 999})
testFind({})

testFind({'a': 100})
testFind({'a': 999})

testRemove({'a': 100})
testFind({})

testRemove({'a': 999})
testFind({'a': 999})
testFind({})