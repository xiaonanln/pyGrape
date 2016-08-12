
from ctrees cimport *
import sys


cdef class BinaryTree:
	cdef node_t *root
	cdef readonly size_t len

	def __cinit__(self):
		self.root = NULL
		self.len = 0

	def __dealloc__(self):
		ct_delete_tree(self.root)

	cpdef insert(self, object key, object value):
		cdef int ret = ct_bintree_insert(&self.root, key, value)
		if ret < 0:
			raise MemoryError()
		elif ret == 0:
			raise KeyError('duplicate key %s' % (key, ))

		self.len += 1

	cpdef remove(self, object key):
		cdef int ret = ct_bintree_remove(&self.root, key)
		if ret == 0:
			raise KeyError(key)
		else:
			self.len -= 1

	cpdef TreeNode find(self, object key):
		cdef node_t *node = ct_find_node(self.root, key)
		if node == NULL:
			raise KeyError(key)

		return TreeNode(self, <long>node)

	cpdef TreeNode findMin(self):
		cdef node_t *node = ct_min_node(self.root)
		if node == NULL:
			return None

		return TreeNode(self, <long>node)

	cpdef TreeNode findMax(self):
		cdef node_t *node = ct_max_node(self.root)
		if node == NULL:
			return None

		return TreeNode(self, <long>node)

	# cpdef TreeNode getSucc(self, TreeNode node):
	# 	cdef node_t *succNode = ct_succ_node(self.root, node.node)
	# 	if succNode == NULL:
	# 		return None

	# 	return TreeNode(self, <long>succNode)

	# cpdef TreeNode getPrev(self, TreeNode node):
	# 	cdef node_t *prevNode = ct_prev_node(self.root, node.node)
	# 	if prevNode == NULL:
	# 		return None

	# 	return TreeNode(self, <long>prevNode)

	def __len__(self):
		return self.len

	cpdef validate(self):
		cdef int valid = ct_validate(self.root)
		if not valid:
			raise AssertionError('invalid tree')

cdef class TreeNode:
	cdef BinaryTree owner
	cdef node_t *node

	def __cinit__(self, BinaryTree tree, _node):
		self.owner = tree
		cdef node_t *node = <node_t *><long>_node;
		self.node = node

	property value:
		def __get__(self):
			return <object>self.node.value

	property key:
		def __get__(self):
			return <object>(self.node.key)

	property item:
		def __get__(self):
			cdef node_t *node = self.node
			return (<object>node.key, <object>node.value)

	cpdef bint moveSucc(self):
		cdef node_t *node = ct_succ_node(self.owner.root, self.node)
		if node != NULL:
			self.node = node
			return True
		else:
			return False

	cpdef bint movePrev(self):
		cdef node_t *node = ct_prev_node(self.owner.root, self.node)
		if node != NULL:
			self.node = node
			return True
		else:
			return False

	def __str__(self):
		return str((self.key, self.value))
