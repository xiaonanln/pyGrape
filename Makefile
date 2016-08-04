all: buildlib

buildlib:
	python buildPyGrape.py build_ext --inplace

test:
	python testPyGrape.py
