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

PyObject *ct_get_key(node_t *node);
PyObject *ct_get_value(node_t *node); 

void ct_delete_tree(node_t *root);
node_t *ct_find_node(node_t *root, PyObject *key);

int ct_bintree_insert(node_t **root, PyObject *key, PyObject *value);
int ct_bintree_remove(node_t **root, PyObject *key);

node_t *ct_min_node(node_t *root);
node_t *ct_max_node(node_t *root);

node_t *ct_succ_node(node_t *node);
node_t *ct_prev_node(node_t *node);

#endif // __CTREES_H

