import os

if os.system('buildPyGrape.bat') != 0:
	exit(1)

import pyGrape
from pyGrape.collection import Collection

c = Collection("test")
print c, c.name
c.createIndex( [('a', 1), ] )
c.createIndex( [('a', -1), ] )

print c.insert({})
print c.insert({'a': 100})
print c.find({})
print c.find({'a': 100})