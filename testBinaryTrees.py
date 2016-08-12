import unittest
import random
import sys
import time
import cProfile
import os

from pyGrape.cython_trees import BinaryTree

class BinaryTreeTest(unittest.TestCase):
	def __init__(self, *args):
		super(BinaryTreeTest, self).__init__(*args)

	def setUp(self):
		pass

	def tearDown(self):
		pass

	def testLen(self):
		bt = BinaryTree()
		N = 1000
		expectedLen = 0
		for i in xrange(N):
			n = random.randint(1, N//100)
			try:
				bt.insert(n, i)
				expectedLen += 1
			except KeyError:
				pass

			self.assertEqual(len(bt), expectedLen)

		for i in xrange(N):
			n = random.randint(1, N//100)
			try:
				# print 'remove',n
				bt.remove(n)
				expectedLen -= 1
			except KeyError:
				pass

			self.assertEqual(len(bt), expectedLen)

	def testInsert(self):
		bt = BinaryTree()
		for i in xrange(1000):
			bt.insert(i, i)
			self.assertEqual(len(bt), i+1)

	def testRemove(self):
		N = 1000
		keys = []
		bt = BinaryTree()
		for i in xrange(N):
			key = random.randint(1, N * 100)

			try:
				bt.insert(key, key)
				keys.append(key)
			except KeyError:
				continue 

		self.assertEqual(len(keys), len(bt))
		while keys:
			i = random.randint(0, len(keys)-1)
			key = keys[i]
			keys[i:i+1] = []

			bt.remove(key)
			bt.validate()

		bt.validate()

	def testSuccNode(self):
		N = 200000
		t = self.newRandomTree(N)

		startTravelTime = time.time()

		for i in  xrange(10):
			node = t.findMin()
			nodeCount = 0
			lastkey, lastval = node.key, node.value

			while node:
				nodeCount += 1
				# print >>sys.stderr, 'getSucc'
				if not node.moveSucc():
					break

				key, val = node.key, node.value
				assert key > lastkey, (key, lastkey)
				lastkey, lastval = key, val

		print 'travel tree takes %ss' % (time.time() - startTravelTime)

		self.assertEqual(nodeCount, len(t))

	def newRandomTree(self, n):
		keys = set()
		t = BinaryTree()
		for i in xrange(n):
			key  = random.randint(1, n*100)
			while key in keys:
				key  = random.randint(1, n*100)

			keys.add(key)
			t.insert(key, i)

		self.assertEqual(len(t), n)
		t.validate()
		return t


if __name__ =='__main__':
	unittest.main()
