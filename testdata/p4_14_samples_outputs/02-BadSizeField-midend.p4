#include <core.p4>
#include <v1model.p4>

struct ingress_metadata_t {
    bit<1> drop;
    bit<8> egress_port;
}

header ethernet_t {
    bit<48> dstAddr;
    bit<48> srcAddr;
    bit<15> ethertype;
}

header vag_t {
    bit<33> f1;
    bit<7>  f2;
}

struct metadata {
    @name("ing_metadata") 
    ingress_metadata_t ing_metadata;
}

struct headers {
    @name("ethernet") 
    ethernet_t ethernet;
    @name("vag") 
    vag_t      vag;
}

parser ParserImpl(packet_in packet, out headers hdr, inout metadata meta, inout standard_metadata_t standard_metadata) {
    @name("start") state start {
        packet.extract<ethernet_t>(hdr.ethernet);
        packet.extract<vag_t>(hdr.vag);
        transition accept;
    }
}

control egress(inout headers hdr, inout metadata meta, inout standard_metadata_t standard_metadata) {
    @name("NoAction_2") action NoAction() {
    }
    @name("nop") action nop_0() {
    }
    @name("e_t1") table e_t1() {
        actions = {
            nop_0();
            NoAction();
        }
        key = {
            hdr.ethernet.srcAddr: exact;
        }
        default_action = NoAction();
    }
    apply {
        e_t1.apply();
    }
}

control ingress(inout headers hdr, inout metadata meta, inout standard_metadata_t standard_metadata) {
    @name("NoAction_3") action NoAction_0() {
    }
    @name("nop") action nop_1() {
    }
    @name("set_egress_port") action set_egress_port_0(bit<8> egress_port) {
        meta.ing_metadata.egress_port = egress_port;
    }
    @name("i_t1") table i_t1() {
        actions = {
            nop_1();
            set_egress_port_0();
            NoAction_0();
        }
        key = {
            hdr.ethernet.dstAddr: exact;
        }
        default_action = NoAction_0();
    }
    apply {
        i_t1.apply();
    }
}

control DeparserImpl(packet_out packet, in headers hdr) {
    apply {
        packet.emit<ethernet_t>(hdr.ethernet);
        packet.emit<vag_t>(hdr.vag);
    }
}

control verifyChecksum(in headers hdr, inout metadata meta, inout standard_metadata_t standard_metadata) {
    apply {
    }
}

control computeChecksum(inout headers hdr, inout metadata meta, inout standard_metadata_t standard_metadata) {
    apply {
    }
}

V1Switch<headers, metadata>(ParserImpl(), verifyChecksum(), ingress(), egress(), computeChecksum(), DeparserImpl()) main;