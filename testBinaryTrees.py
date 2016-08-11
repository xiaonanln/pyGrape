import unittest
import random
import sys
import time

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

	def testSuccNode(self):
		N = 1000
		t = self.newRandomTree(4)

		node = t.findMin()
		nodeCount = 0
		while node is not None:
			nodeCount += 1
			print >>sys.stderr, 'getSucc'
			node = t.getSucc(node)
			print >>sys.stderr, 'getSucc end'
			print >>sys.stderr, 'succ', node is None
			if node is not None:
				print >>sys.stderr, node.key

		self.assertEqual(nodeCount, len(t))

	def newRandomTree(self, n):
		keys = set()
		t = BinaryTree()
		for i in xrange(n):
			key  = random.randint(1, n*100)
			while key in keys:
				key  = random.randint(1, n*100)

			keys.add(key)
			print >>sys.stderr, 'insert', key, i
			t.insert(key, i)

		self.assertEqual(len(t), n)
		t.validate()
		return t


if __name__ =='__main__':
	unittest.main()