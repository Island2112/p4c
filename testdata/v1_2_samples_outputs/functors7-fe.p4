parser p1<T>(in T a) {
    state start {
        T w = a;
    }
}

parser p1_0(in bit<2> a) {
    state start {
        bit<2> w = a;
    }
}

parser simple(in bit<2> a);
package m(simple n);
m(p1_0()) main;