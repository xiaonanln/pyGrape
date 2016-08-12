import os
import random

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

	keys = []
	for i in xrange(100):
		key = random.randint(1, 1000)
		try:
			print 'insert', key
			t.insert(key, key)
			keys.append(key)
		except KeyError:
			pass

	t.validate()
	random.shuffle(keys)
	for key in keys:
		print 'remove', key, 
		node = t.findNode(key)
		assert node
		node.remove()
		# node.remove()
		print 'ok'
		t.validate()

testBinTrees()