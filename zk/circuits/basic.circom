pragma circom 2.0.3;

include "../../node_modules/circomlib/circuits/comparators.circom";

template basic() {
    signal input a;
    signal input b;
    signal output c;

    component eq = ForceEqualIfEnabled();
    eq.enabled <== 1;
    eq.in[0] <== a + b;
    eq.in[1] <== 14;

    c <== 1;
}

component main { public [a, b]} = basic();