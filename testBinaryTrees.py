import unittest
import random

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
		N = 10000
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
		for i in xrange(10000):
			bt.insert(i, i)
			self.assertEqual(len(bt), i+1)

if __name__ =='__main__': 
	unittest.main()