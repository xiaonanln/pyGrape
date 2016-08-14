
cdef extern from "ctrees.h":
	ctypedef struct PyObject:
		pass

	ctypedef struct node_t:
		node_t *link[2]
		PyObject *key
		PyObject *value

	void ct_delete_tree(node_t *root);

	node_t *ct_find_node(node_t *root, object key);

	int ct_bintree_insert(node_t **root, object key, object value)
	void ct_bintree_remove(node_t **root, node_t *node)


	node_t *ct_min_node(node_t *root)
	node_t *ct_max_node(node_t *root)
	node_t *ct_prev_node(node_t *root, node_t *node)
	node_t *ct_succ_node(node_t *root, node_t *node)

	int ct_validate(node_t *root)


	int rb_insert(node_t **root, object key, object value);
	int rb_remove(node_t **rootaddr, node_t *node); 
	
	void ct_bintree_keys(node_t *root, object list); 