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
//   Arbiter_IFC#(Degree) rrArbiter <- mkArbiter (False);

//   rule rl_cycle_counter;
//      cy <= cy + 1;
//   endrule

//   // Generate arbitration requests (based on data availability on input FIFOs)
//   rule rl_gen_arb_reqs;
//      for (Integer r = 0; r < valueof(n); r = r + 1)
//         if (i_fifos [r].notEmpty) rr_arb.clients [r].request;
//   endrule

//   // Generate n rules; each rule forwards from one input FIFO to the common output FIFO
//   for (Integer r = 0; r < valueof(n); r = r + 1) begin
//      rule rl_r (rr_arb.clients [r].grant);    // NOTE: rule conditioned on arbiter 'grant'
//         let x = i_fifos[r].first ();
//         $display ("Cycle %0d: rule r[%0d] forwarded %0d", cy, r, x);
//         i_fifos[r].deq ();
//         o_fifo.enq (x);
//      endrule
//   end
   
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

endmodule: mkMerger

endpackage: Merger

