#!/usr/bin/sage
# vim: syntax=python

ZZR.<XX> = PolynomialRing(ZZ)
def show_elm(val):
    if val.parent().degree() == 1:
        return "0x%x" % val
    if val == 0:
        return "0"
    vals = [ (ii, vv) for (ii, vv) in enumerate(ZZR(val)) if vv > 0 ]
    ostrs = [None] * len(vals)
    for (idx, (ii, vv)) in enumerate(vals):
        if ii == 0:
            ostrs[idx] = "0x%x" % vv
        elif ii == 1:
            ostrs[idx] = "0x%x * I" % vv
        else:
            ostrs[idx] = "0x%x * I^%d" % (vv, ii)
    return " + ".join(ostrs)

def show_iso(iso):
    (xm, ym) = iso.rational_maps()
    maps = (xm.numerator(), xm.denominator(), ym.numerator(), ym.denominator())
    strs = ("x\\_num", "x\\_den", "y\\_num", "y\\_den")
    mstr = ""
    for (idx, (m, s)) in enumerate(zip(maps, strs), 1):
        max_jdx = -1
        skipped_one = False
        for ((jdx, _), val) in sorted(m.dict().items()):
            if val == 1 and jdx + 1 == len(m.dict()):
                skipped_one = True
                continue
            if jdx > max_jdx:
                max_jdx = jdx
            print("- k\\_(%d,%d) = %s" % (idx, jdx, show_elm(val)))
        if skipped_one:
            max_jdx += 1
            ostr = "x'^%d" % (max_jdx)
        else:
            ostr = "k\\_(%d,%d) * x'^%d" % (idx, max_jdx, max_jdx)
        start = max(0, max_jdx - 2)
        for jdx in reversed(range(start, max_jdx)):
            ostr += " + k\\_(%d,%d)" % (idx, jdx)
            if jdx > 0:
                ostr += " * x'"
                if jdx > 1:
                    ostr += "^%d" % jdx
        if start > 0:
            if start > 1:
                ostr += " + ..."
            ostr += " + k\\_(%d,0)" % idx
        mstr += "  - %s = %s\n" % (s, ostr)
        print()
    print()
    print(mstr)
    print()


# SECP256k1 iso
_iso_secp256k1 = None
def iso_secp256k1():
    global _iso_secp256k1
    if _iso_secp256k1 is not None:
        return _iso_secp256k1
    p = 2^256 - 2^32 - 2^9 - 2^8 - 2^7 - 2^6 - 2^4 - 1
    A = 0
    B = 7
    E = EllipticCurve(GF(p), [A, B])
    Ap = 0x3f8731abdd661adca08a5558f0f5d272e953d363cb6f0e5d405447c01a444533
    Bp = 1771
    Ep = EllipticCurve(GF(p), [Ap, Bp])
    iso = EllipticCurveIsogeny(E=E, kernel=None, codomain=Ep, degree=3).dual()
    if (- iso.rational_maps()[1])(1, 1) > iso.rational_maps()[1](1, 1):
        iso.switch_sign()
    _iso_secp256k1 = iso
    return iso

# BLS12-381 G1 iso
_iso_bls12381g1 = None
def iso_bls12381g1():
    global _iso_bls12381g1
    if _iso_bls12381g1 is not None:
        return _iso_bls12381g1
    p = 0x1a0111ea397fe69a4b1ba7b6434bacd764774b84f38512bf6730d2a0f6b0f6241eabfffeb153ffffb9feffffffffaaab
    A = 0
    B = 4
    E = EllipticCurve(GF(p), [A, B])
    Ap = 0x144698a3b8e9433d693a02c96d4982b0ea985383ee66a8d8e8981aefd881ac98936f8da0e0f97f5cf428082d584c1d
    Bp = 0x12e2908d11688030018b12e8753eee3b2016c1f0f24f4070a0b9c14fcef35ef55a23215a316ceaa5d1cc48e98e172be0
    Ep = EllipticCurve(GF(p), [Ap, Bp])
    iso = EllipticCurveIsogeny(E=E, kernel=None, codomain=Ep, degree=11).dual()
    if (- iso.rational_maps()[1])(1, 1) > iso.rational_maps()[1](1, 1):
        iso.switch_sign()
    _iso_bls12381g1 = iso
    return iso

# BLS12-381 G2 iso
_iso_bls12381g2 = None
def iso_bls12381g2():
    global _iso_bls12381g2
    if _iso_bls12381g2 is not None:
        return _iso_bls12381g2
    p = 0x1a0111ea397fe69a4b1ba7b6434bacd764774b84f38512bf6730d2a0f6b0f6241eabfffeb153ffffb9feffffffffaaab
    F.<II> = GF(p^2, modulus=[1,0,1])
    A = 0
    B = 4 * (1 + II)
    E = EllipticCurve(F, [A, B])
    Ap = 240 * II
    Bp = 1012 * (1 + II)
    Ep = EllipticCurve(F, [Ap, Bp])
    iso_kernel = [6 * (1 - II), 1]
    iso = EllipticCurveIsogeny(E=Ep, kernel=iso_kernel, codomain=E, degree=3)
    if (- iso.rational_maps()[1])(1, 1) > iso.rational_maps()[1](1, 1):
        iso.switch_sign()
    _iso_bls12381g2 = iso
    return iso

# BLS12-381 G1 iso
_iso_bls12377g1 = None
def iso_bls12377g1():
    global _iso_bls12377g1
    if _iso_bls12377g1 is not None:
        return _iso_bls12377g1
    p = 0x01ae3a4617c510eac63b05c06ca1493b1a22d9f300f5138f1ef3622fba094800170b5d44300000008508c00000000001
    A = 0 
    B = 1
    E = EllipticCurve(GF(p), [A, B])
    Ap = 0x1ae3a4617c510ea34b3c4687866d1616212919cefb9b37e860f40fde03873fc0a0bf847bffffff8b9857ffffffffff2
    Bp = 22
    Ep = EllipticCurve(GF(p), [Ap, Bp])
    iso = EllipticCurveIsogeny(E=E, kernel=None, codomain=Ep, degree=2).dual()
    if (- iso.rational_maps()[1])(1, 1) > iso.rational_maps()[1](1, 1):
        iso.switch_sign()
    _iso_bls12377g1 = iso
    return iso

# BLS12-377 G2 iso
_iso_bls12377g2 = None
def iso_bls12377g2():
    global _iso_bls12377g2
    if _iso_bls12377g2 is not None:
        return _iso_bls12377g2
    p = 0x01ae3a4617c510eac63b05c06ca1493b1a22d9f300f5138f1ef3622fba094800170b5d44300000008508c00000000001
    F.<X> = GF(p)[]
    F2.<II> = GF(p^2 , modulus=X^2 + 5)
    A = 0
    B = 0x10222f6db0fd6f343bd03737460c589dc7b4f91cd5fd889129207b63c6bf8000dd39e5c1ccccccd1c9ed9999999999a * II
    E = EllipticCurve(F2, [A, B])
    Ap1 = 0x152964189f4c623685ae0423eb10294ce6458c064f093208504005b37d04d5d336dc9d66a97093f84d62e778f8c82be
    Ap2 = 0x735c455387ab435839e5a5dbc1a30510070300f4becac797642fe56985064e95f7d6521a1a6e71004047f835c1f957
    Bp1 = 0x19e38372e0d4bf401d2fa5f2261e1e3fc95d51a3857fc23b1385d51ea9c973a89c22148a93dff96447700bf1c3aebac
    Bp2 = 0x1579ddb5c1c595b7c08c3a3cef5626143c25757c6b67d0a2677b22fc0c890d8b2b1a17895d047a98c49047069f725
    Ap = Ap1 + Ap2 * II
    Bp = Bp1 + Bp2 * II
    Ep = EllipticCurve(F2, [Ap, Bp])
    iso_kernel = [
        215662182095705906163825408535378893833968379605046219826205367797444707127136004593758135464636175557277941629366*II + 131585078269229414247930432589347377733412777301768390824663996563672235736995655118402297231965373986362546769433,
        149519450227332975721130935525019527758375510640566263034875524976824396511628246893127170982403331692217431295539*II + 6304234990690711334859517929188179197586301626141439253376356481965230979456216751754007403441563428524677907583,
        31264472307723473700812991684315343404735372006990635243112674533122298442027603603204404485548320714043723104177*II + 197341287164692155666347060412940716638278784272556862153203786948984985097939570684565455306808341038248893191360,
        236872054387217814327021223559740033179985637312983952765235199526835949201801501009248760934379848864376645130386*II + 206478750378855510483815994563062185365266786099778519343456424765231175667487949116640662534441869516042245218475,
        703539006063792615342692403837662018037785840351481015820038378382615052451249789022371795396829549653426224027*II + 64417627363990720630871020673150877006201251870745861792822803671793751297518573600066058443563413793035064883515,
        94645056505985402221886844084915883698135224664807650582830238051998304522051756235707642751547449679732578925954*II + 36832919834293750382187761355449874373323065491248987721638921338241386502944480553897570490995673455954242510273,
        2145563503724497756053746914716726713209292144487919667490034939307748181974590629813562628012940150682785202558*II + 66285120741847659819257974995503766282008203869337494924611601663028465912655895108472906206687366654695390834733,
        63495530849998374152345233679411264687343710182708372879088753357614280710454673495988948951717151636208347192834*II + 76640384659711956792152276429471123236566434486518153254493030434995133388093131861743646167705170644640569530812,
        137150783644174155354828470658274603181902316499455599257271293679414246255305478999335709182693673838888205678926*II + 195715317904817891051420053229120168014400752184313745089159883683600143932586737195172359021973814363714940317710,
        91953946508793354394510063029692320710844502218792907146028263100385251757811490116623755026322247783229386971022*II + 77187259974715307499664181674842150559692073341951270180995104687281136451707997688189795129792755615052690588800,
        242736373975260471145138996440383831409933738216327750740538015315247120732568119409712892819410735537021085968464*II + 57382621303259812491200253082952118946735947643781575669729586918943501952658880134470940467998962651241905254085,
        1
    ]
    iso = EllipticCurveIsogeny(E=Ep, kernel=iso_kernel, codomain=E, degree=23)
    if (- iso.rational_maps()[1])(1, 1) > iso.rational_maps()[1](1, 1):
        iso = -iso
    _iso_bls12377g2 = iso
    return iso

if __name__ == "__main__":
    print("** SECP256k1\n")
    show_iso(iso_secp256k1())
    print("** BLS12-381 G1\n")
    show_iso(iso_bls12381g1())
    print("** BLS12-381 G2\n")
    show_iso(iso_bls12381g2())
    print("** BLS12-377 G1\n")
    show_iso(iso_bls12377g1())
    print("** BLS12-377 G2\n")
    show_iso(iso_bls12377g2())
