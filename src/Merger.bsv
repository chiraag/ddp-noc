// Chiraag Juvekar - Sample Arbiter

package Merger;

import GetPut::*;
import Vector::*;
import FIFOF::*;
import FIFO::*;
import SpecialFIFOs::*;
import Arbiter::*;

import NoCTypes::*;
import Device::*;

// ----------------------------------------------------------------
// Priority model

interface Merger;
   interface Vector#(Degree, Put#(Packet)) putPacket;
   interface Get#(Packet) getPacket;
endinterface

(* synthesize *)
module mkMerger (Merger);
   FIFO#(Packet) outFIFO <- mkBypassFIFO();
   FIFOF#(Packet) inFIFO[valueOf(Degree)];
   for(Integer i =0; i < valueOf(Degree); i = i+1) begin
      inFIFO[i]  <- mkSizedBypassFIFOF(16);
   end
   
   // ----------------
   // RULES
   // Instantiate an n-way round-robin arbiter from the BSV library
   Arbiter_IFC#(Degree) rrArbiter <- mkArbiter (False);

   // Generate arbitration requests (based on data availability on input FIFOs)
   rule putArbiterReqTokens;
      for (Integer i = 0; i < valueof(Degree); i = i + 1) begin
        if (inFIFO[i].notEmpty) begin
          rrArbiter.clients[i].request;
//          $display("Arbiter Req: FIFO %d", i);
        end
      end
   endrule

   // Generate n rules; each rule forwards from one input FIFO to the common output FIFO
   Rules arbiterRespRuleSet = emptyRules; 
   for (Integer i=0; i<valueof(Degree); i=i+1) begin 
      Rules nextRule = 
        rules 
          rule getArbiterRespToken(rrArbiter.clients[i].grant);    // NOTE: rule conditioned on arbiter 'grant'
//            $display("Arbiter Grant: FIFO %d", i);
            outFIFO.enq(inFIFO[i].first()); inFIFO[i].deq ();         
          endrule
        endrules; 
      arbiterRespRuleSet = rJoinMutuallyExclusive(arbiterRespRuleSet,nextRule); 
   end 
   addRules(arbiterRespRuleSet);

   
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

