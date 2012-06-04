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
  interface Vector#(Degree, Put#(Packet)) putPacket;
  interface Vector#(Degree, Get#(Packet)) getPacket;
  
  interface Put#(Packet) putPacketNode;
  interface Get#(Packet) getPacketNode;
endinterface

(* synthesize *)
module mkNodeP #(Address thisAddr) (PNode);

   // ---- Instruction memory (modeled here using an array of registers)
   Merger  merger  <- mkMerger();
   Router  router  <- mkRouter(thisAddr, Point);

   FIFO#(Packet) networkoutFIFO[valueOf(Degree)];
   FIFO#(Packet) networkinFIFO[valueOf(Degree)];
   
   for(Integer i = 0; i < valueOf(Degree); i = i+1) begin
      networkoutFIFO[i]  <- mkFIFO();
      networkinFIFO[i]   <- mkFIFO();
   end

   for(Integer i = 0; i < valueOf(Degree); i = i+1) begin
     mkConnection(router.getPacket[i], toPut(networkoutFIFO[i]));
     mkConnection(toGet(networkinFIFO[i]), merger.putPacket[i]);
   end

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
   interface getPacketNode = merger.getPacket;
   interface putPacketNode = router.putPacket;
endmodule: mkNodeP

interface LNode;
  interface Vector#(Degree, Put#(Packet)) putPacket;
  interface Vector#(Degree, Get#(Packet)) getPacket;
endinterface

(* synthesize *)
module mkNodeL #(Address thisAddr) (LNode);

   // ---- Instruction memory (modeled here using an array of registers)
   Merger  merger  <- mkMerger();
   Router  router  <- mkRouter(thisAddr, Line);

   mkConnection(merger.getPacket, router.putPacket);

   FIFO#(Packet) networkoutFIFO[valueOf(Degree)];
   FIFO#(Packet) networkinFIFO[valueOf(Degree)];
   
   for(Integer i = 0; i < valueOf(Degree); i = i+1) begin
      networkoutFIFO[i]  <- mkFIFO();
      networkinFIFO[i]   <- mkFIFO();
   end
   
   for(Integer i = 0; i < valueOf(Degree); i = i+1) begin
     mkConnection(router.getPacket[i], toPut(networkoutFIFO[i]));
     mkConnection(toGet(networkinFIFO[i]), merger.putPacket[i]);
   end

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

