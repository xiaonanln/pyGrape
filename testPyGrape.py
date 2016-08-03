import os

os.system('buildPyGrape.bat')

import pyGrape
from pyGrape.collection import Collection

c = Collection("test")
print c, c.name

c.insert([])
c.find({})