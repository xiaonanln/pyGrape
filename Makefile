all: buildlib

buildlib:
	python buildPyGrape.py build_ext --inplace
