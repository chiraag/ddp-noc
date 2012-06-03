// Chiraag Juvekar - Sample Arbiter

package Arbiter;

import GetPut::*;
import Vector::*;
import FIFOF::*;
import FIFO::*;

import NoCTypes::*;
import Device::*;

// ----------------------------------------------------------------
// Priority model

interface Arbiter;
   interface Vector#(Degree, Put#(Packet)) putPacket;
   interface Get#(Packet) getPacket;
//   method Action pushPacket0(Packet inputPacket);
//   method Action pushPacket1(Packet inputPacket);
//   method Action pushPacket2(Packet inputPacket);
//   method ActionValue#(Packet) popPacket();
endinterface

(* synthesize *)
module mkArbiter (Arbiter);
   FIFO#(Packet) outFIFO <- mkFIFO();
   FIFOF#(Packet) inFIFO[valueOf(Degree)];
   for(Integer i =0; i < valueOf(Degree); i = i+1) begin
      inFIFO[i]  <- mkSizedFIFOF(16);
   end
   
   // ----------------
   // RULES
   rule arbitrate;
      if(inFIFO[0].notEmpty()) begin
        outFIFO.enq(inFIFO[0].first()); inFIFO[0].deq();
      end else if(inFIFO[1].notEmpty()) begin
        outFIFO.enq(inFIFO[1].first()); inFIFO[1].deq();
      end else if(inFIFO[2].notEmpty()) begin
        outFIFO.enq(inFIFO[2].first()); inFIFO[2].deq();
      end
   endrule

   // ----------------
   // METHODS
   Vector#(Degree, Put#(Packet)) putPacketI;
   for (Integer i=0; i<valueOf(Degree); i=i+1) begin
      putPacketI[i] = toPut(inFIFO[i]);
   end 
   interface putPacket = putPacketI;
   interface getPacket = toGet(outFIFO);

endmodule: mkArbiter

endpackage: Arbiter

