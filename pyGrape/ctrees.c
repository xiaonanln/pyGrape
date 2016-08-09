#include "ctrees.h"

#define KEY(node)	((node)->key)
#define VALUE(node)	((node)->value)
#define LEFT(node)	((node)->link[0])
#define RIGHT(node)	((node)->link[1])
#define LINK(node, n)	((node)->link[(n)])
#define XDATA(node)	((node)->xdata)
#define RED(node)	((node)->xdata)

void initctrees(void)
{
}

static node_t *
ct_new_node(PyObject *key, PyObject *value, int xdata)
{
	node_t *new_node = PyMem_Malloc(sizeof(node_t));
	if (new_node != NULL) {
		KEY(new_node) = key;
		Py_INCREF(key);
		VALUE(new_node) = value;
		Py_INCREF(value);
		LEFT(new_node) = NULL;
		RIGHT(new_node) = NULL;
		XDATA(new_node) = xdata;
	}
	return new_node;
}

static void
ct_delete_node(node_t *node)
{
	if (node != NULL) {
		Py_XDECREF(KEY(node));
		Py_XDECREF(KEY(node));
		LEFT(node) = NULL;
		RIGHT(node) = NULL;
		PyMem_Free(node);
	}
}

void
ct_delete_tree(node_t *root)
{
	if (root == NULL) return ;

	if (LEFT(root) != NULL) {
		ct_delete_tree(LEFT(root));
	}
	if (RIGHT(root) != NULL) {
		ct_delete_tree(RIGHT(root));
	}
	ct_delete_node(root);
}

#if 0
static void
ct_swap_data(node_t *node1, node_t *node2)
{
	PyObject *tmp;
	tmp = KEY(node1);
	KEY(node1) = KEY(node2);
	KEY(node2) = tmp;

	tmp = VALUE(node1);
	VALUE(node1) = VALUE(node2);
	VALUE(node2) = tmp;
}
#endif

int
ct_compare(PyObject *key1, PyObject *key2)
{
	int res;
	res = PyObject_RichCompareBool(key1, key2, Py_LT);
	if (res > 0)
		return -1;
	else if (res < 0) {
		PyErr_SetString(PyExc_TypeError, "invalid type for key");
		return 0;
	}

	return PyObject_RichCompareBool(key1, key2, Py_GT);
}

node_t *
ct_find_node(node_t *root, PyObject *key)
{
	int res;
	while (root != NULL) {
		 res = ct_compare(key, KEY(root));
		 if (res == 0) {
			 return root;
		 } else {
			 root = LINK(root, (res > 0));
		 }
	}
	return NULL;
}

int ct_bintree_insert(node_t **rootaddr, PyObject *key, PyObject *value)
{
	int cval;
	while (1) {
		node_t *root = *rootaddr;
		if (root == NULL) {
			node_t *node = ct_new_node(key, value, 0);
			if (node == NULL) return -1;
			*rootaddr = node;
			return 1;
		}

		cval = ct_compare(key, KEY(root));
		if (cval < 0) {
			// use left tree
			rootaddr = &LEFT(root);
		} else if (cval > 0) {
			rootaddr = &RIGHT(root);
		} else {
			/* key exists, replace value object? no! */
			PyErr_SetString(PyExc_ValueError, "duplicate key");
			return 0;
		}
	}
}

int
ct_bintree_remove(node_t **rootaddr, PyObject *key)
{
	int cmp_res;
	node_t *tmp;

	while (1) {
		node_t *root = *rootaddr;
		if (root == NULL) {
			// can not find the key
			return 0;
		}

		cmp_res = ct_compare(key, KEY(root));
		if (cmp_res < 0) {
			// use left tree
			rootaddr = &LEFT(root);
		} else if (cmp_res > 0) {
			rootaddr = &RIGHT(root);
		} else {
			// key found, remove the root node
			if (LEFT(root) == NULL) {
				// replace the root with the right subtree
				*rootaddr = RIGHT(root);
				ct_delete_node(root);
			} else if (RIGHT(root) == NULL) {
				// replace the root with the left subtree
				*rootaddr = LEFT(root);
				ct_delete_node(root);
			} else {
				// both left and right sub-tree is non-null, replace by smallest key in right sub-tree
				node_t *leftmost = RIGHT(root); // assert leftmost != NULL
				while ((tmp = LEFT(leftmost)) != NULL) {
					leftmost = tmp; 
				}
			}
		}
	}
}

