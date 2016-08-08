/*
 * ctrees.h
 *
 */

#ifndef __CTREES_H
#define __CTREES_H

#include <Python.h>

typedef struct tree_node node_t;

struct tree_node {
	node_t *link[2];
	PyObject *key;
	PyObject *value;
	int xdata;
};

typedef node_t *nodeptr;

void ct_delete_tree(node_t *root);
node_t *ct_find_node(node_t *root, PyObject *key);

int ct_bintree_insert(node_t **root, PyObject *key, PyObject *value);
int ct_bintree_remove(node_t **root, PyObject *key);

#endif // __CTREES_H

