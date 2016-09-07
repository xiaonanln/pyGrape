all: buildlib

.PHONY: buildlib test testct clean cleantmp

buildlib:
	python buildPyGrape.py build_ext --inplace

test: buildlib
	python test.py

testct:
	python testBinaryTrees.py

clean:
	python buildPyGrape.py clean

cleantmp:
	rm -rf *~
	rm -rf pyGrape/*~
