from ctrees cimport *

cdef class TreeNode:
	cdef BinaryTree owner
	cdef node_t *node

	cpdef bint moveSucc(self)
	cpdef bint movePrev(self)
	cpdef void remove(self)

cdef class BinaryTree:
	cdef node_t *root
	cdef readonly size_t len

	cpdef void insert(self, object key, object value) except *
	cpdef removeNode(self, TreeNode node)
	cpdef TreeNode findNode(self, object key)
	cpdef TreeNode findMinNode(self)
	cpdef TreeNode findMaxNode(self)
	cpdef int validate(self) except *
	cpdef list keys(self)

cdef class RBTree(BinaryTree):
	pass

