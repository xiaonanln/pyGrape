
cdef extern from "ctrees.h":
	ctypedef struct PyObject:
		pass

	ctypedef struct node_t:
		node_t *link[2]
		PyObject *key
		PyObject *value

