all: buildlib

buildlib:
	python buildPyGrape.py build_ext --inplace

test:
	python testPyGrape.py

testct:
	python testBinaryTrees.py

clean:
	python buildPyGrape.py clean

cleantmp:
	rm -rf *~
	rm -rf pyGrape/*~
