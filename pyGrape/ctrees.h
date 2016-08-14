/*
 * ctrees.h
 *
 */

#ifndef __CTREES_H
#define __CTREES_H

#include <Python.h>

typedef struct tree_node node_t;

struct tree_node {
	node_t *link[3];
	PyObject *key;
	PyObject *value;
	int xdata;
};

PyObject *ct_get_key(node_t *node);
PyObject *ct_get_value(node_t *node); 

void ct_delete_tree(node_t *root);
node_t *ct_find_node(node_t *root, PyObject *key);

int ct_bintree_insert(node_t **root, PyObject *key, PyObject *value);
void ct_bintree_remove(node_t **root, node_t *node);

node_t *ct_min_node(node_t *root);
node_t *ct_max_node(node_t *root);

node_t *ct_succ_node(node_t *root, node_t *node);

node_t *ct_prev_node(node_t *root, node_t *node);

int ct_validate(node_t *root);


int rb_insert(node_t **root, PyObject *key, PyObject *value);
int rb_remove(node_t **rootaddr, node_t *node); 

void ct_bintree_keys(node_t *root, PyObject *list); 

#endif // __CTREES_H

