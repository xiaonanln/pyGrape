
from ctrees cimport *
import sys
from errors import InternalError

cdef class BinaryTree:

	def __cinit__(self):
		self.root = NULL
		self.len = 0

	def __dealloc__(self):
		ct_delete_tree(self.root)

	cpdef void insert(self, object key, object value) except *:
		cdef int ret = ct_bintree_insert(&self.root, key, value)
		if ret < 0:
			raise MemoryError()
		elif ret == 0:
			raise KeyError(key)

		self.len += 1

	# cpdef remove(self, object key):
	# 	cdef node_t *node = ct_find_node(self.root, key)
	# 	if node == NULL:
	# 		raise KeyError(key)

	# 	ct_bintree_remove(&self.root, node)
	# 	self.len -= 1

	cpdef removeNode(self, TreeNode node):
		ct_bintree_remove(&self.root,  node.node)
		node.node = NULL
		self.len -= 1

	cpdef TreeNode findNode(self, object key):
		cdef node_t *node = ct_find_node(self.root, key)
		if node == NULL:
			raise KeyError(key)

		return TreeNode(self, <long>node)

	cpdef TreeNode findMinNode(self):
		cdef node_t *node = ct_min_node(self.root)
		if node == NULL:
			return None

		return TreeNode(self, <long>node)

	cpdef TreeNode findMaxNode(self):
		cdef node_t *node = ct_max_node(self.root)
		if node == NULL:
			return None

		return TreeNode(self, <long>node)

	def __len__(self):
		return self.len

	cpdef int validate(self) except *:
		cdef int valid = ct_validate(self.root)
		return valid

	cpdef list keys(self):
		cdef list a = []
		ct_bintree_keys(self.root, a)
		return a

cdef class RBTree(BinaryTree):
	cpdef void insert(self, object key, object value) except *:
		cdef int ret = rb_insert(&self.root, key, value)
		if ret == -1:
			raise MemoryError()
		elif ret == 0:
			raise KeyError(key)

		self.len += 1

	cpdef removeNode(self, TreeNode node):
		rb_remove(&self.root,  node.node)
		node.node = NULL
		self.len -= 1

_nullTreeNodeError = InternalError('TreeNode is null')

cdef class TreeNode:

	def __cinit__(self, BinaryTree tree, _node):
		self.owner = tree
		cdef node_t *node = <node_t *><long>_node;
		self.node = node

	property value:
		def __get__(self):
			if self.node != NULL:
				return <object>self.node.value 
			else:
				raise _nullTreeNodeError

	property key:
		def __get__(self):
			if self.node != NULL:
				return <object>(self.node.key)
			else:
				raise _nullTreeNodeError

	property item:
		def __get__(self):
			cdef node_t *node = self.node
			if node != NULL:
				return (<object>node.key, <object>node.value)
			else:
				raise _nullTreeNodeError

	cpdef bint moveSucc(self):
		if self.node == NULL:
			raise _nullTreeNodeError

		cdef node_t *node = ct_succ_node(self.owner.root, self.node)
		if node != NULL:
			self.node = node
			return True
		else:
			return False

	cpdef bint movePrev(self):
		if self.node == NULL:
			raise _nullTreeNodeError
			
		cdef node_t *node = ct_prev_node(self.owner.root, self.node)
		if node != NULL:
			self.node = node
			return True
		else:
			return False

	cpdef void remove(self):
		if self.node != NULL:
			self.owner.removeNode(self)
		else:
			raise _nullTreeNodeError

	def __str__(self):
		return str((self.key, self.value))
