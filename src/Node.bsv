// Chiraag Juvekar - Sample Network Node

package Node;

import GetPut::*;
import Vector::*;

import NoCTypes::*;
import FIFO::*;
import Device::*;
import Arbiter::*;
import Router::*;

// ----------------------------------------------------------------
// Priority model

interface Node;
  interface Vector#(Degree, Put#(Packet)) putPacket;
  interface Vector#(Degree, Get#(Packet)) getPacket;
endinterface

(* synthesize *)
module mkNodeP #(Address thisAddr) (Node);

   // ---- Instruction memory (modeled here using an array of registers)
   Arbiter arbiter <- mkArbiter();
   Router  router  <- mkRouter(thisAddr, Point);
   Device  dev     <- mkDevice(thisAddr);

   FIFO#(Packet) networkoutFIFO[valueOf(Degree)];
   FIFO#(Packet) networkinFIFO[valueOf(Degree)];
   
   for(Integer i = 0; i < valueOf(Degree); i = i+1) begin
      networkoutFIFO[i]  <- mkFIFO();
      networkinFIFO[i]   <- mkFIFO();
   end
   
   // ----------------
   // RULES
   rule connectDevRouter;
      let outPacket <- dev.popPacket();
      router.pushPacket(outPacket);
   endrule

   rule connectArbiterDev;
      let outPacket <- arbiter.popPacket();
      dev.pushPacket(outPacket);
   endrule

   rule connectRouterNetwork0;
      let outPacket <- router.arbiter0popPacket();
      networkoutFIFO[0].enq(outPacket);
   endrule

   rule connectRouterNetwork1;
      let outPacket <- router.arbiter1popPacket();
      networkoutFIFO[1].enq(outPacket);
   endrule

   rule connectRouterNetwork2;
      let outPacket <- router.arbiter2popPacket();
      networkoutFIFO[2].enq(outPacket);
   endrule

   rule connectNetworkArbiter0;
      let outPacket = networkinFIFO[0].first();
      networkinFIFO[0].deq();
      arbiter.pushPacket0(outPacket);
   endrule

   rule connectNetworkArbiter1;
      let outPacket = networkinFIFO[1].first();
      networkinFIFO[1].deq();
      arbiter.pushPacket1(outPacket);
   endrule

   rule connectNetworkArbiter2;
      let outPacket = networkinFIFO[2].first();
      networkinFIFO[2].deq();
      arbiter.pushPacket2(outPacket);
   endrule

   // ----------------
   // METHODS
   Vector#(Degree, Put#(Packet)) putPacketI;
   Vector#(Degree, Get#(Packet)) getPacketI;
   for (Integer i=0; i<valueOf(Degree); i=i+1) begin
      putPacketI[i] = toPut(networkinFIFO[i]);
      getPacketI[i] = toGet(networkoutFIFO[i]);
   end 
   interface getPacket = getPacketI;
   interface putPacket = putPacketI;
endmodule: mkNodeP

module mkNodeL #(Address thisAddr) (Node);

   // ---- Instruction memory (modeled here using an array of registers)
   Arbiter arbiter <- mkArbiter();
   Router  router  <- mkRouter(thisAddr, Line);

   FIFO#(Packet) networkoutFIFO[valueOf(Degree)];
   FIFO#(Packet) networkinFIFO[valueOf(Degree)];
   
   for(Integer i = 0; i < valueOf(Degree); i = i+1) begin
      networkoutFIFO[i]  <- mkFIFO();
      networkinFIFO[i]   <- mkFIFO();
   end
   
   // ----------------
   // RULES
   rule connectArbiterRouter;
      let outPacket <- arbiter.popPacket();
      router.pushPacket(outPacket);
   endrule

   rule connectRouterNetwork0;
      let outPacket <- router.arbiter0popPacket();
      networkoutFIFO[0].enq(outPacket);
   endrule

   rule connectRouterNetwork1;
      let outPacket <- router.arbiter1popPacket();
      networkoutFIFO[1].enq(outPacket);
   endrule

   rule connectRouterNetwork2;
      let outPacket <- router.arbiter2popPacket();
      networkoutFIFO[2].enq(outPacket);
   endrule

   rule connectNetworkArbiter0;
      let outPacket = networkinFIFO[0].first();
      networkinFIFO[0].deq();
      arbiter.pushPacket0(outPacket);
   endrule

   rule connectNetworkArbiter1;
      let outPacket = networkinFIFO[1].first();
      networkinFIFO[1].deq();
      arbiter.pushPacket1(outPacket);
   endrule

   rule connectNetworkArbiter2;
      let outPacket = networkinFIFO[2].first();
      networkinFIFO[2].deq();
      arbiter.pushPacket2(outPacket);
   endrule

   // ----------------
   // METHODS
   Vector#(Degree, Put#(Packet)) putPacketI;
   Vector#(Degree, Get#(Packet)) getPacketI;
   for (Integer i=0; i<valueOf(Degree); i=i+1) begin
      putPacketI[i] = toPut(networkinFIFO[i]);
      getPacketI[i] = toGet(networkoutFIFO[i]);
   end 
   interface getPacket = getPacketI;
   interface putPacket = putPacketI;
endmodule: mkNodeL

endpackage: Node

