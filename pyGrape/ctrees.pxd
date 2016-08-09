
cdef extern from "ctrees.h":
	ctypedef struct PyObject:
		pass

	ctypedef struct node_t:
		node_t *link[2]
		PyObject *key
		PyObject *value


	int ct_bintree_insert(node_t **root, object key, object value)
	int ct_bintree_remove(node_t **root, object key)