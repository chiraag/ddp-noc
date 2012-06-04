// Chiraag Juvekar - Sample Network Node

package Node;

import Connectable::*;
import GetPut::*;
import Vector::*;
import FIFO::*;

import NoCTypes::*;
import Device::*;
import Merger::*;
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
   Merger  merger  <- mkMerger();
   Router  router  <- mkRouter(thisAddr, Point);
   Device  dev     <- mkDevice(thisAddr);

   mkConnection(dev.getPacket, router.putPacket);
   mkConnection(merger.getPacket, dev.putPacket);

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
endmodule: mkNodeP

module mkNodeL #(Address thisAddr) (Node);

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

