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
    from sagelib.iso_values import iso_bls12377g2
except ImportError:
    sys.exit("Error loading preprocessed sage files. Try running `make clean pyfiles`")

p = 0x01ae3a4617c510eac63b05c06ca1493b1a22d9f300f5138f1ef3622fba094800170b5d44300000008508c00000000001
F.<X> = GF(p)[]
F2.<II> = GF(p^2, modulus=X^2 + 5)
A = F2(0)
B = F2(0x10222f6db0fd6f343bd03737460c589dc7b4f91cd5fd889129207b63c6bf8000dd39e5c1ccccccd1c9ed9999999999a * II)
# Ap and Bp define isogenous curve y^2 = x^3 + Ap * x + Bp
Ap1 = 0x152964189f4c623685ae0423eb10294ce6458c064f093208504005b37d04d5d336dc9d66a97093f84d62e778f8c82be
Ap2 = 0x735c455387ab435839e5a5dbc1a30510070300f4becac797642fe56985064e95f7d6521a1a6e71004047f835c1f957
Bp1 = 0x19e38372e0d4bf401d2fa5f2261e1e3fc95d51a3857fc23b1385d51ea9c973a89c22148a93dff96447700bf1c3aebac
Bp2 = 0x1579ddb5c1c595b7c08c3a3cef5626143c25757c6b67d0a2677b22fc0c890d8b2b1a17895d047a98c49047069f725
Ap = F2(Ap1 + Ap2 * II)
Bp = F2(Bp1 + Bp2 * II)
h2 = 0x26ba558ae9562addd88d99a6f6a829fbb36b00e1dcc40c8c505634fae2e189d693e8c36676bd09a0f3622fba094800452217cc900000000000000000000001
ell_u = 0x8508c00000000001
h_eff = h2 * (3 * ell_u^2 - 3)
iso_map = iso_bls12377g2()

def bls12377g2_svdw(suite_name, is_ro):
    dst = test_dst(suite_name)
    k = 128
    expander = XMDExpander(dst, hashlib.sha256, k)
    return BasicH2CSuiteDef("BLS12-377 G2", F2, A, B, expander, hashlib.sha256, 64, GenericSvdW, h_eff, k, is_ro, expander.dst)

def bls12377g2_sswu(suite_name, is_ro):
    return IsoH2CSuiteDef(bls12377g2_svdw(suite_name, is_ro)._replace(MapT=GenericSSWU), Ap, Bp, iso_map)

suite_name = "BLS12377G2_XMD:SHA-256_SVDW_RO_"
bls12377g2_svdw_ro = BasicH2CSuite(suite_name,bls12377g2_svdw(suite_name, True))

suite_name = "BLS12377G2_XMD:SHA-256_SSWU_RO_"
bls12377g2_sswu_ro = IsoH2CSuite(suite_name,bls12377g2_sswu(suite_name, True))

suite_name = "BLS12377G2_XMD:SHA-256_SVDW_NU_"
bls12377g2_svdw_nu = BasicH2CSuite(suite_name,bls12377g2_svdw(suite_name, False))

suite_name = "BLS12377G2_XMD:SHA-256_SSWU_NU_"
bls12377g2_sswu_nu = IsoH2CSuite(suite_name,bls12377g2_sswu(suite_name, False))

assert bls12377g2_sswu_ro.m2c.Z == bls12377g2_sswu_nu.m2c.Z == F2(12 + II)
assert bls12377g2_svdw_ro.m2c.Z == bls12377g2_svdw_nu.m2c.Z == F2(2)

bls12377g2_order = 0x12ab655e9a2ca55660b44d1e5c37b00159aa76fed00000010a11800000000001

def test_suite_bls12377g2():
    _test_suite(bls12377g2_sswu_ro, bls12377g2_order, 8)
    _test_suite(bls12377g2_svdw_ro, bls12377g2_order, 8)
    _test_suite(bls12377g2_sswu_nu, bls12377g2_order, 8)
    _test_suite(bls12377g2_svdw_nu, bls12377g2_order, 8)

if __name__ == "__main__":
    test_suite_bls12377g2()
