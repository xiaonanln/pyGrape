#include "ctrees.h"

#define LEFT 		(0)
#define RIGHT 		(1)
#define PARENT		(2)

#define KEY(node)	((node)->key)
#define VALUE(node)	((node)->value)
#define LEFT_NODE(node)	((node)->link[LEFT])
#define RIGHT_NODE(node)	((node)->link[RIGHT])
#define PARENT_NODE(node)	((node)->link[PARENT])
#define LINK(node, n)	((node)->link[(n)])
#define XDATA(node)	((node)->xdata)
#define RED(node)	((node)->xdata)

#define ct_compare PyObject_Compare

static node_t *
ct_new_node(node_t *parent, PyObject *key, PyObject *value, int xdata)
{
	node_t *new_node = PyMem_Malloc(sizeof(node_t));

	if (new_node != NULL) {
		KEY(new_node) = key;
		Py_INCREF(key);

		VALUE(new_node) = value;
		Py_INCREF(value);

		LEFT_NODE(new_node) = NULL;
		RIGHT_NODE(new_node) = NULL;
		PARENT_NODE(new_node) = parent;
		XDATA(new_node) = xdata;
	}
	return new_node;
}

static void
ct_delete_node(node_t *node)
{
	Py_XDECREF(KEY(node));
	Py_XDECREF(VALUE(node));
	PyMem_Free(node);
}

void
ct_delete_tree(node_t *root)
{
	if (root == NULL) return ;

	ct_delete_tree(LEFT_NODE(root));
	ct_delete_tree(RIGHT_NODE(root));

	ct_delete_node(root);
}

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

int
ct_bintree_insert(node_t **rootaddr, PyObject *key, PyObject *value)
{
	int cval;
	node_t *parent = NULL;

	while (1) {
		node_t *root = *rootaddr;
		if (root == NULL) {
			node_t *node = ct_new_node(parent, key, value, 0);
			if (node == NULL) return -1;
			*rootaddr = node;
			return 1;
		}

		cval = ct_compare(key, KEY(root));
		if (cval < 0) {
			// use left tree
			rootaddr = &LEFT_NODE(root);
		} else if (cval > 0) {
			rootaddr = &RIGHT_NODE(root);
		} else {
			/* key exists, replace value object? no! */
			return 0;
		}
		parent = root;
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
			// use left sub-tree
			rootaddr = &LEFT_NODE(root);
		} else if (cmp_res > 0) {
			// use right sub-tree
			rootaddr = &RIGHT_NODE(root);
		} else {
			// key found, remove the root node
			if (LEFT_NODE(root) == NULL) {
				// replace the root with the right sub-tree
				*rootaddr = RIGHT_NODE(root);
				ct_delete_node(root);
			} else if (RIGHT_NODE(root) == NULL) {
				// replace the root with the left sub-tree
				*rootaddr = LEFT_NODE(root);
				ct_delete_node(root);
			} else {
				// both left and right sub-tree is non-null, replace by smallest key in right sub-tree
				node_t **pleftmost = &RIGHT_NODE(root);
				node_t *leftmost = RIGHT_NODE(root); // assert leftmost != NULL
				while ((tmp = LEFT_NODE(leftmost)) != NULL) {
					pleftmost = &LEFT_NODE(leftmost);
					leftmost = tmp;
				}
				// found the leftmost node, copy its data to the root, then remove the left most node
				ct_swap_data(root, leftmost);
				*pleftmost = RIGHT_NODE(leftmost);
				ct_delete_node(leftmost);
			}
			return 1;
		}
	}
}

node_t *ct_min_node(node_t *root)
{
	node_t *left;
	if (root == NULL) return NULL;

	while ((left = LEFT_NODE(root)) != NULL) {
		root = left;
	}
	return root;
}

node_t *ct_max_node(node_t *root)
{
	node_t *right;
	if (root == NULL) return NULL;

	while ((right = RIGHT_NODE(root)) != NULL) {
		root = right;
	}
	return root;
}

static node_t *
ct_prev_node_slow(node_t *root, PyObject *key)
{
	node_t *prev = NULL;
	node_t *node = root;
	int cval;

	while (node != NULL) {
		cval = ct_compare(key, KEY(node));
		if (cval == 0)
			break;
		else if (cval < 0)
			node = LEFT_NODE(node);
		else {
			if ((prev == NULL) || (ct_compare(KEY(node), KEY(prev)) > 0))
				prev = node;
			node = RIGHT_NODE(node);
		}
	}
	if (node == NULL) /* stay at dead end (None) */
		return NULL;
	/* found node of key */
	if (LEFT_NODE(node) != NULL) {
		/* find biggest node of left subtree */
		node = LEFT_NODE(node);
		while (RIGHT_NODE(node) != NULL)
			node = RIGHT_NODE(node);
		if (prev == NULL)
			prev = node;
		else if (ct_compare(KEY(node), KEY(prev)) > 0)
			prev = node;
	}
	return prev;
}


node_t *ct_succ_node(node_t *root, node_t *node)
{
	node_t *succ;

	if ( (succ = RIGHT_NODE(node)) != NULL) {
		/* find smallest node of right subtree */
		while (LEFT_NODE(succ) != NULL) {
			succ = LEFT_NODE(succ);
		}
		return succ;
	} else {
		// node has no right tree
		node_t *parent = PARENT_NODE(node);
		while (1) {
				if (parent == NULL) {
					return NULL;
				} else if (RIGHT_NODE(parent) == node) {
					node = parent;
					parent = PARENT_NODE(node);
				} else {
					assert(LEFT_NODE(parent) == node);
					return parent;
				}
		}
	}
}

node_t *ct_prev_node(node_t *root, node_t *node)
{
	return ct_prev_node_slow(root, KEY(node));
}

static int ct_validate_range(node_t *root, PyObject *minkey, PyObject *maxkey)
{
	PyObject *key;
	if (root == NULL) return 1;

	assert(LEFT_NODE(root) == NULL || PARENT_NODE(LEFT_NODE(root)) == root );
	assert(RIGHT_NODE(root) == NULL || PARENT_NODE(RIGHT_NODE(root)) == root );

	key = KEY(root);
	if (minkey != NULL) {
		if (ct_compare(key, minkey) <= 0) {
			return 0;
		}
	}
	if (maxkey != NULL) {
		if (ct_compare(key, maxkey) >= 0) {
			return 0;
		}
	}
	return 1;
}


int ct_validate(node_t *root)
{
	PyObject *key;
	if (root == NULL) return 1;

	assert(PARENT_NODE(root) == NULL);
	assert(LEFT_NODE(root) == NULL || PARENT_NODE(LEFT_NODE(root)) == root );
	assert(RIGHT_NODE(root) == NULL || PARENT_NODE(RIGHT_NODE(root)) == root );

	key = KEY(root);
	return ct_validate_range(LEFT_NODE(root), NULL, key) && ct_validate_range(RIGHT_NODE(root), key, NULL);
}
