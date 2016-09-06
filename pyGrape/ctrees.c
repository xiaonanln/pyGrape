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

#define my_assert(x, s, ret)	do {	\
	if (!(x)) {					\
		PyErr_SetString(PyExc_AssertionError, (s)); 	\
		return ret; \
	}	\
} while(0)

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
			// Py_XDECREF(VALUE(root)); /* release old value object */
			// VALUE(root) = value;     /* set new value object     */
			// Py_INCREF(value);     /* take new value object    */
			return 0; 
		}
		parent = root;
	}
}

void
ct_bintree_remove(node_t **rootaddr, node_t *node)
{
	node_t **pnode = NULL; 
	node_t *tmp;

	if (*rootaddr == node) {
		// the node is the root
		pnode = rootaddr;
	} else {
		node_t *parent = PARENT_NODE(node); 
		if (LEFT_NODE(parent) == node) {
			pnode = &LEFT_NODE(parent); 
		} else {
			pnode = &RIGHT_NODE(parent); 
		}
	}

	if (LEFT_NODE(node) == NULL) {
		// replace the root with the right sub-tree
		tmp = *pnode = RIGHT_NODE(node);
		if (tmp != NULL) {
			PARENT_NODE(tmp) = PARENT_NODE(node);
		}
		ct_delete_node(node);
	} else if (RIGHT_NODE(node) == NULL) {
		// replace the node with the left sub-tree
		tmp = *pnode = LEFT_NODE(node);
		PARENT_NODE(tmp) = PARENT_NODE(node);
		ct_delete_node(node);
	} else {
		// both left and right sub-tree is non-null, replace by smallest key in right sub-tree
		node_t **pleftmost = &RIGHT_NODE(node);
		node_t *leftmost = RIGHT_NODE(node); // assert leftmost != NULL
		while ((tmp = LEFT_NODE(leftmost)) != NULL) {
			pleftmost = &LEFT_NODE(leftmost);
			leftmost = tmp;
		}
		// found the leftmost node, copy its data to the root, then remove the left most node
		ct_swap_data(node, leftmost);

		tmp = *pleftmost = RIGHT_NODE(leftmost);
		if (tmp != NULL) {
			PARENT_NODE(tmp) = PARENT_NODE(leftmost);
		}
		ct_delete_node(leftmost);
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

node_t *ct_succ_node(node_t *root, node_t *node)
{
	node_t *succ;
	node_t *tmp; 

	if ( (succ = RIGHT_NODE(node)) != NULL) {
		/* find smallest node of right subtree */
		while ( (tmp=LEFT_NODE(succ)) != NULL) {
			succ = tmp;
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
					// assert(LEFT_NODE(parent) == node);
					return parent;
				}
		}
	}
}

node_t *ct_prev_node(node_t *root, node_t *node)
{
	node_t *prev;
	node_t *tmp; 

	if ((prev = LEFT_NODE(node)) != NULL) {
		// find the largest node of left-subtee
		while ( (tmp=RIGHT_NODE(prev)) != NULL) {
			prev = tmp;
		}
		return prev; 
	} else {
		// node has no left sub-tree
		node_t *parent = PARENT_NODE(node); 
		while (1) {
			if (parent == NULL) {
				return NULL; 
			} else if (LEFT_NODE(parent) == node) {
				node = parent; 
				parent = PARENT_NODE(node); 
			} else {
				return parent; 
			}
		}	
	}
}

static int ct_validate_range(node_t *root, PyObject *minkey, PyObject *maxkey)
{
	PyObject *key;
	if (root == NULL) return 1;

	if (!(LEFT_NODE(root) == NULL || PARENT_NODE(LEFT_NODE(root)) == root )) {
		PyErr_SetString(PyExc_AssertionError, "left node parent is wrong");
		return 0;
	}
	if (!(RIGHT_NODE(root) == NULL || PARENT_NODE(RIGHT_NODE(root)) == root )) {
		PyErr_SetString(PyExc_AssertionError, "right node parent is wrong");
		return 0;
	}

	key = KEY(root);
	if (minkey != NULL) {
		if (ct_compare(key, minkey) <= 0) {
			PyErr_SetString(PyExc_AssertionError, "key order is wrong");
			return 0;
		}
	}
	if (maxkey != NULL) {
		if (ct_compare(key, maxkey) >= 0) {
			PyErr_SetString(PyExc_AssertionError, "key order is wrong");
			return 0;
		}
	}
	return 1;
}


int ct_validate(node_t *root)
{
	PyObject *key;
	if (root == NULL) return 1;

	if (PARENT_NODE(root) != NULL) {
		PyErr_SetString(PyExc_AssertionError, "parent of root is not null");
		return 0;
	}
	if (!(LEFT_NODE(root) == NULL || PARENT_NODE(LEFT_NODE(root)) == root )) {
		PyErr_SetString(PyExc_AssertionError, "left node parent is wrong");
		return 0;
	}
	if (!(RIGHT_NODE(root) == NULL || PARENT_NODE(RIGHT_NODE(root)) == root )) {
		PyErr_SetString(PyExc_AssertionError, "right node parent is wrong");
		return 0;
	}

	key = KEY(root);
	return ct_validate_range(LEFT_NODE(root), NULL, key) && ct_validate_range(RIGHT_NODE(root), key, NULL);
}

static int
is_red (node_t *node)
{
	return (node != NULL) && (RED(node) == 1);
}

static node_t *
rb_single(node_t *root, int dir)
{
	node_t *save = root->link[!dir];

	node_t *tmp = root->link[!dir] = save->link[dir];
	// my_assert(tmp != NULL, "tmp is null", NULL);
	if (tmp != NULL) {
		PARENT_NODE(tmp) = root; 
	}

	save->link[dir] = root;
	// my_assert(root != NULL, "root is null", NULL);
	// if (root != NULL) {
		PARENT_NODE(root) = save; 	
	// }

	RED(root) = 1;
	RED(save) = 0;
	return save;
}

static node_t *
rb_double(node_t *root, int dir)
{
	node_t *tmp = root->link[!dir] = rb_single(root->link[!dir], !dir);
	PARENT_NODE(tmp) = root; 
	return rb_single(root, dir);
}

#define rb_new_node(parent, key, value) ct_new_node(parent, key, value, 1)

extern int
rb_insert(node_t **rootaddr, PyObject *key, PyObject *value)
{
    int new_node = 0;
	node_t *root = *rootaddr;

	if (root == NULL) {
		// case 1, root == NULL
		root = rb_new_node(NULL, key, value);
		new_node = 1;
		if (root == NULL)
			return -1; // got no memory
	}
	else {
		node_t head; /* False tree root */
		node_t *g, *t; /* Grandparent & parent */
		node_t *p, *q; /* Iterator & parent */
		int dir = 0;
		int last = 0;

		/* Set up our helpers */
		t = &head;
		g = NULL;
		p = NULL;
		RIGHT_NODE(t) = root;
		LEFT_NODE(t) = NULL;
		q = RIGHT_NODE(t);

		/* Search down the tree for a place to insert */
		for (;;) {
			int cmp_res;
			if (q == NULL) {
				/* Insert a new node at the first null link */
				q = rb_new_node(p, key, value);
				new_node = 1;
				p->link[dir] = q;
				if (q == NULL)
					return -1; // get no memory
			}
			else if (is_red(q->link[0]) && is_red(q->link[1])) {
				/* Simple red violation: color flip */
				RED(q) = 1;
				RED(q->link[0]) = 0;
				RED(q->link[1]) = 0;
			}

			if (is_red(q) && is_red(p)) {
				/* Hard red violation: rotations necessary */
				int dir2 = (t->link[1] == g);

				if (q == p->link[last]) {
					node_t * tmp = t->link[dir2] = rb_single(g, !last);
					PARENT_NODE(tmp) = t; 
				} else {
					node_t *tmp = t->link[dir2] = rb_double(g, !last);
					PARENT_NODE(tmp) = t; 
				}
			}

			/*  Stop working if we inserted a new node. */
			if (new_node)
				break;

			cmp_res = ct_compare(KEY(q), key);
			if (cmp_res == 0) {       /* if key exists            */
				// Py_XDECREF(VALUE(q)); /* release old value object */
				// VALUE(q) = value;      set new value object     
				// Py_INCREF(value);     /* take new value object    */
				break;
			}
			last = dir;
			dir = (cmp_res < 0);

			/* Move the helpers down */
			if (g != NULL)
				t = g;

			g = p;
			p = q;
			q = q->link[dir];
		}
		/* Update the root (it may be different) */
		root = head.link[1];
	}

	/* Make the root black for simplified logic */
	RED(root) = 0;
	(*rootaddr) = root;
	PARENT_NODE(root) = NULL; 
	return new_node;
}

extern int
rb_remove(node_t **rootaddr, node_t *_node)
{
	PyObject *key = KEY(_node);
	node_t *root = *rootaddr;

	node_t head = { { NULL } }; /* False tree root */
	node_t *q, *p, *g; /* Helpers */
	node_t *f = NULL; /* Found item */
	node_t *tmp;
	int dir = 1;

	if (root == NULL)
		return 0;

	/* Set up our helpers */
	q = &head;
	g = p = NULL;
	RIGHT_NODE(q) = root;

	/*
	 Search and push a red node down
	 to fix red violations as we go
	 */
	while (q->link[dir] != NULL) {
		int last = dir;
		int cmp_res;

		/* Move the helpers down */
		g = p, p = q;
		q = q->link[dir];

		cmp_res =  ct_compare(KEY(q), key);

		dir = cmp_res < 0;

		/*
		 Save the node with matching data and keep
		 going; we'll do removal tasks at the end
		 */
		if (cmp_res == 0)
			f = q;

		/* Push the red node down with rotations and color flips */
		if (!is_red(q) && !is_red(q->link[dir])) {
			if (is_red(q->link[!dir])) {
				tmp = rb_single(q, dir);
				PARENT_NODE(tmp) = p;
				p = p->link[last] = tmp;
			}
			else if (!is_red(q->link[!dir])) {
				node_t *s = p->link[!last];

				if (s != NULL) {
					if (!is_red(s->link[!last]) &&
						!is_red(s->link[last])) {
						/* Color flip */
						RED(p) = 0;
						RED(s) = 1;
						RED(q) = 1;
					}
					else {
						int dir2 = g->link[1] == p;

						if (is_red(s->link[last])) {
							tmp = g->link[dir2] = rb_double(p, last);
							PARENT_NODE(tmp) = g;
						}
						else if (is_red(s->link[!last])) {
							tmp = g->link[dir2] = rb_single(p, last);
							PARENT_NODE(tmp) = g;
						}

						/* Ensure correct coloring */
						RED(q) = RED(g->link[dir2]) = 1;
						RED(g->link[dir2]->link[0]) = 0;
						RED(g->link[dir2]->link[1]) = 0;
					}
				}
			}
		}
	}

	/* Replace and remove the saved node */
	if (f != NULL) {
		ct_swap_data(f, q);
		p->link[p->link[1] == q] = q->link[q->link[0] == NULL];
		ct_delete_node(q);
	}

	/* Update the root (it may be different) */
	root = head.link[1];

	/* Make the root black for simplified logic */
	if (root != NULL) {
		RED(root) = 0;
		PARENT_NODE(root) = NULL;
	}
	*rootaddr = root;
	return (f != NULL);
}


void ct_bintree_keys(node_t *root, PyObject *list)
{
	if (root == NULL) {
		return ;
	}

	ct_bintree_keys(LEFT_NODE(root), list);
	PyList_Append(list, KEY(root)); 
	ct_bintree_keys(RIGHT_NODE(root), list);
}
