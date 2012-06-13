// Chiraag Juvekar - Sample Network Node

package Node;

import Connectable::*;
import GetPut::*;
import Vector::*;
import FIFO::*;

import NoCTypes::*;
import Merger::*;
import Router::*;

// ----------------------------------------------------------------
// Priority model

interface PNode;
  interface Vector#(Degree, Put#(NoCPacket)) putPacket;
  interface Vector#(Degree, Get#(NoCPacket)) getPacket;
  
  interface Put#(NoCPacket) putPacketNode;
  interface Get#(NoCPacket) getPacketNode;
endinterface

(* synthesize *)
module mkNodeP #(Address thisAddr) (PNode);
   // ---- Instruction memory (modeled here using an array of registers)
   Merger  merger  <- mkMerger();
   Router  router  <- mkRouter(thisAddr, Point);

   // ----------------
   // METHODS
   interface getPacket = router.getPacket;
   interface putPacket = merger.putPacket;
   interface getPacketNode = merger.getPacket;
   interface putPacketNode = router.putPacket;
endmodule: mkNodeP

interface LNode;
  interface Vector#(Degree, Put#(NoCPacket)) putPacket;
  interface Vector#(Degree, Get#(NoCPacket)) getPacket;
endinterface

(* synthesize *)
module mkNodeL #(Address thisAddr) (LNode);
   // ---- Instruction memory (modeled here using an array of registers)
   Merger  merger  <- mkMerger();
   Router  router  <- mkRouter(thisAddr, Line);

   mkConnection(merger.getPacket, router.putPacket);

   // ----------------
   // METHODS
   interface getPacket = router.getPacket;
   interface putPacket = merger.putPacket;
endmodule: mkNodeL

endpackage: Node

