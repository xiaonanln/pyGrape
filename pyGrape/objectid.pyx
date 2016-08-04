import hashlib
import os
import socket
import struct
import time
import binascii

cdef str getMachineBytes():
    """Get the machine portion of an ObjectId.
    """
    machine_hash = hashlib.md5()
    machine_hash.update(socket.gethostname())
    return machine_hash.digest()[0:3]

cdef str _machineBytes = getMachineBytes()
cdef int _inc = 1

cpdef str newObjectId():
    """Generate a new value for this ObjectId.
    """
    global _inc, _machineBytes

    # 4 bytes current time
    oid = struct.pack(">i", int(time.time()))

    # 3 bytes machine
    oid += _machineBytes

    # 2 bytes pid
    oid += struct.pack(">H", os.getpid() % 0xFFFF)

    oid += struct.pack(">i", _inc)[1:4]
    _inc = (_inc + 1) % 0xFFFFFF

    oid = binascii.hexlify(oid)
    print 'newObjectId', oid
    return oid

