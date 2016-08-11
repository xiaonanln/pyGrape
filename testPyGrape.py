import os

if os.name == 'nt':
	if os.system('buildPyGrape.bat') != 0:
		exit(1)
elif os.name == 'posix':
	if os.system('make buildlib') != 0:
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


def testOperations():
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


def testBinTrees():
	from pyGrape.cython_trees import BinaryTree
	t = BinaryTree()
	t.insert(1, 2)
	print len(t)
	t.insert(2, 100)
	print len(t)
	# t.insert(2, 4)
	t.insert(4, 3)

	cursor = t.find(2)
	print cursor.key, cursor.value

testBinTrees()