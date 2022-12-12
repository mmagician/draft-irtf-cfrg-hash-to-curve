#!/usr/bin/sage
# vim: syntax=python

import hashlib
import sys
from hash_to_field import XMDExpander
try:
    from sagelib.common import test_dst
    from sagelib.h2c_suite import BasicH2CSuiteDef, BasicH2CSuite, IsoH2CSuiteDef, IsoH2CSuite
    from sagelib.svdw_generic import GenericSvdW
    from sagelib.sswu_generic import GenericSSWU
    from sagelib.suite_p256 import _test_suite
    from sagelib.iso_values import iso_bls12377g1
except ImportError:
    sys.exit("Error loading preprocessed sage files. Try running `make clean pyfiles`")

p = 0x01ae3a4617c510eac63b05c06ca1493b1a22d9f300f5138f1ef3622fba094800170b5d44300000008508c00000000001
F = GF(p)
A = F(0)
B = F(1)
# Ap and Bp define isogenous curve y^2 = x^3 + Ap * x + Bp
Ap = F(0x1ae3a4617c510ea34b3c4687866d1616212919cefb9b37e860f40fde03873fc0a0bf847bffffff8b9857ffffffffff2)
Bp = F(0x16)
h_eff = 0x170b5d44300000000000000000000000
iso_map = iso_bls12377g1()

def bls12377g1_svdw(suite_name, is_ro):
    dst = test_dst(suite_name)
    k = 128
    expander = XMDExpander(dst, hashlib.sha256, k)
    return BasicH2CSuiteDef("BLS12-381 G1", F, A, B, expander, hashlib.sha256, 64, GenericSvdW, h_eff, k, is_ro, expander.dst)

def bls12377g1_sswu(suite_name, is_ro):
    return IsoH2CSuiteDef(bls12377g1_svdw(suite_name, is_ro)._replace(MapT=GenericSSWU), Ap, Bp, iso_map)

suite_name = "BLS12377G1_XMD:SHA-256_SVDW_RO_"
bls12377g1_svdw_ro = BasicH2CSuite(suite_name,bls12377g1_svdw(suite_name, True))

suite_name = "BLS12377G1_XMD:SHA-256_SSWU_RO_"
bls12377g1_sswu_ro = IsoH2CSuite(suite_name,bls12377g1_sswu(suite_name, True))

suite_name = "BLS12377G1_XMD:SHA-256_SVDW_NU_"
bls12377g1_svdw_nu = BasicH2CSuite(suite_name,bls12377g1_svdw(suite_name, False))

suite_name = "BLS12377G1_XMD:SHA-256_SSWU_NU_"
bls12377g1_sswu_nu = IsoH2CSuite(suite_name,bls12377g1_sswu(suite_name, False))

assert bls12377g1_sswu_ro.m2c.Z == bls12377g1_sswu_nu.m2c.Z == 15
assert bls12377g1_svdw_ro.m2c.Z == bls12377g1_svdw_nu.m2c.Z == -3

bls12377g1_order = 0x12ab655e9a2ca55660b44d1e5c37b00159aa76fed00000010a11800000000001

def test_suite_bls12377g1():
    _test_suite(bls12377g1_sswu_ro, bls12377g1_order)
    _test_suite(bls12377g1_svdw_ro, bls12377g1_order)
    _test_suite(bls12377g1_sswu_nu, bls12377g1_order)
    _test_suite(bls12377g1_svdw_nu, bls12377g1_order)

if __name__ == "__main__":
    test_suite_bls12377g1()
