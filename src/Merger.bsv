// Chiraag Juvekar - Sample Arbiter

package Merger;

import GetPut::*;
import Vector::*;
import FIFOF::*;
import FIFO::*;
import Arbiter::*;

import NoCTypes::*;
import Device::*;

// ----------------------------------------------------------------
// Priority model

interface Merger;
   interface Vector#(Degree, Put#(Packet)) putPacket;
   interface Get#(Packet) getPacket;
//   method Action pushPacket0(Packet inputPacket);
//   method Action pushPacket1(Packet inputPacket);
//   method Action pushPacket2(Packet inputPacket);
//   method ActionValue#(Packet) popPacket();
endinterface

(* synthesize *)
module mkMerger (Merger);
   FIFO#(Packet) outFIFO <- mkFIFO();
   FIFOF#(Packet) inFIFO[valueOf(Degree)];
   for(Integer i =0; i < valueOf(Degree); i = i+1) begin
      inFIFO[i]  <- mkSizedFIFOF(16);
   end
   
   // ----------------
   // RULES
   // Instantiate an n-way round-robin arbiter from the BSV library
   Arbiter_IFC#(Degree) rrArbiter <- mkArbiter (False);

   // Generate arbitration requests (based on data availability on input FIFOs)
   rule putArbiterReqTokens;
      for (Integer i = 0; i < valueof(Degree); i = i + 1) begin
         if (inFIFO[i].notEmpty) rrArbiter.clients[i].request;
      end
   endrule

   // Generate n rules; each rule forwards from one input FIFO to the common output FIFO
   for (Integer i = 0; i < valueof(Degree); i = i + 1) begin
      rule getArbiterRespToken(rrArbiter.clients[i].grant);    // NOTE: rule conditioned on arbiter 'grant'
         outFIFO.enq(inFIFO[i].first()); inFIFO[i].deq ();         
      endrule
   end
   
//   rule arbitrate;
//      if(inFIFO[0].notEmpty()) begin
//        outFIFO.enq(inFIFO[0].first()); inFIFO[0].deq();
//      end else if(inFIFO[1].notEmpty()) begin
//        outFIFO.enq(inFIFO[1].first()); inFIFO[1].deq();
//      end else if(inFIFO[2].notEmpty()) begin
//        outFIFO.enq(inFIFO[2].first()); inFIFO[2].deq();
//      end
//   endrule

   // ----------------
   // METHODS
   Vector#(Degree, Put#(Packet)) putPacketI;
   for (Integer i=0; i<valueOf(Degree); i=i+1) begin
      putPacketI[i] = toPut(inFIFO[i]);
   end 
   interface putPacket = putPacketI;
   interface getPacket = toGet(outFIFO);

endmodule: mkMerger

endpackage: Merger

