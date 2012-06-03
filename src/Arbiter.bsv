// Chiraag Juvekar - Sample Arbiter

package Arbiter;

import Vector::*;
import FIFOF::*;
import FIFO::*;

import NoCTypes::*;
import Device::*;

// ----------------------------------------------------------------
// Priority model

interface Arbiter;
//   interface Vector#(Degree, Put#(Packet)) putPacket;
//   interface Vector#(Degree, Get#(Packet)) getPacket;
   method Action pushPacket0(Packet inputPacket);
   method Action pushPacket1(Packet inputPacket);
   method Action pushPacket2(Packet inputPacket);
   method ActionValue#(Packet) popPacket();
endinterface

(* synthesize *)
module mkArbiter (Arbiter);

   // ---- Instruction memory (modeled here using an array of registers)
   FIFO#(Packet) outFIFO <- mkSizedFIFO(16);
   FIFOF#(Packet) inFIFO[valueOf(Degree)+1];
   for(Integer i =0; i <= valueOf(Degree); i = i+1) begin
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

   method Action pushPacket0(Packet inputPacket);
      inFIFO[0].enq(inputPacket);
   endmethod

   method Action pushPacket1(Packet inputPacket);
      inFIFO[1].enq(inputPacket);
   endmethod

   method Action pushPacket2(Packet inputPacket);
      inFIFO[2].enq(inputPacket);
   endmethod
   
   method ActionValue#(Packet) popPacket();
      outFIFO.deq(); return outFIFO.first();
   endmethod

endmodule: mkArbiter

endpackage: Arbiter

