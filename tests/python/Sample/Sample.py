#!/usr/bin/env python3
'''Test APIs'''

import unittest
import CrossPlatformApi
from CrossPlatformApi.Sample import pySample

if __debug__:
    print(f'version: {CrossPlatformApi.__version__}')
    print(f'CrossPlatformApi: ${dir(CrossPlatformApi)}')
    print(f'CrossPlatformApi.Sample: ${dir(CrossPlatformApi.Sample)}')
    print(f'pySample: ${dir(pySample)}')

class TestpySample(unittest.TestCase):
    '''Test pySample'''
    def test_cnAdd_function(self):
        v = pySample.caAdd(3, 5)
        self.assertEqual(8, v)

    def test_WriteString(self):
        p = bytearray(10)
        ret = pySample.caWriteString(p, "Hello")
        self.assertEqual(5, ret)
        self.assertEqual(ord('H'), p[0])
        self.assertEqual(ord('e'), p[1])
        self.assertEqual(ord('l'), p[2])
        self.assertEqual(ord('l'), p[3])
        self.assertEqual(ord('o'), p[4])
        self.assertEqual(ord('\0'), p[5])

if __name__ == '__main__':
    unittest.main(verbosity=2)
