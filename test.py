import unittest
import os
import random

import pyGrape
from pyGrape.collection import Collection

class Test(unittest.TestCase):
	
	def createSampleCollection(self, addSampleData=True):
		c = Collection("test")
		c.createIndex( [('a', 1), ] )
		c.createIndex( [('b', 1), ] )
		c.createIndex( [('c', -1), ] )

		if addSampleData:
			pass

		return c
	
	def testCreateCollection(self):
		c = self.createSampleCollection(addSampleData=False)
		c.insertOne({})
		for i in xrange(10000):
			c.insertOne({'a': i})
			c.insertOne({'b': random.randint(1, 100), 'c': random.randint(1, 100)})
			self.assertEqual(len(c), (i+1)*2+1)

	def testFind(self):
		c = self.createSampleCollection(addSampleData=True)
		c.find()

if __name__ == '__main__':
	unittest.main()

