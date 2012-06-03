// Chiraag Juvekar - Fano Circulance Router

package Router;

import Vector::*;
import FIFOF::*;
import FIFO::*;
import Device::*;

typedef 3 Degree;
typedef Bit#(7) DecodedAddr;
typedef enum {Point, Line} RouterType deriving (Eq, Bits);

DecodedAddr decodeTable[7] = { 7'b0000001, 7'b0000010, 7'b0000100, 7'b0001000, 7'b0010000, 7'b0100000, 7'b1000000 };

// ----------------------------------------------------------------
// Priority model

interface Router;
   method Action pushPacket(Packet inputPacket);
   method ActionValue#(Packet) arbiter0popPacket();
   method ActionValue#(Packet) arbiter1popPacket();
   method ActionValue#(Packet) arbiter2popPacket();
   method ActionValue#(Packet) nodepopPacket();
endinterface

(* synthesize *)
module mkRouter #(Address thisAddr, RouterType thisType) (Router);

   // ---- Instruction memory (modeled here using an array of registers)
   FIFO#(Packet) toRouterFIFO <- mkFIFO();

   FIFO#(Packet) toNodeFIFO <- mkFIFO();
   FIFO#(Packet) toArbiterFIFO[valueOf(Degree)];
   for(Integer i =0; i < valueOf(Degree); i=i+1) begin
      toArbiterFIFO[i]  <- mkFIFO();
   end
   
   // ----------------
   // RULES
   rule routeOutgoing;
      let currPacket = toRouterFIFO.first();
      toRouterFIFO.deq();
      Address distance = (7 + currPacket.destAddress - thisAddr) % 7;
      DecodedAddr toAddr = decodeTable[distance];
      DecodedAddr pattern = 7'b0001011;            
      
      if(thisType == Point) begin
        if(toAddr == 7'b0000001) begin
          toNodeFIFO.enq(currPacket);
        end else if((toAddr & 7'b1010000) != 0) begin
          toArbiterFIFO[0].enq(currPacket);
        end else if((toAddr & 7'b0100010) != 0) begin
          toArbiterFIFO[1].enq(currPacket);
        end else if((toAddr & 7'b0001100) != 0) begin
          toArbiterFIFO[2].enq(currPacket);
        end
      end else if(thisType == Line) begin
        if(toAddr == 7'b0000001) begin
          toArbiterFIFO[0].enq(currPacket);
        end else if(toAddr == 7'b1000000) begin
          toArbiterFIFO[1].enq(currPacket);
        end else if(toAddr ==  7'b0010000) begin
          toArbiterFIFO[2].enq(currPacket);
        end
      end
   endrule

   // ----------------
   // METHODS

   method Action pushPacket(Packet inputPacket);
      toRouterFIFO.enq(inputPacket);
   endmethod
   
   method ActionValue#(Packet) arbiter0popPacket();
      toArbiterFIFO[0].deq(); return toArbiterFIFO[0].first();
   endmethod

   method ActionValue#(Packet) arbiter1popPacket();
      toArbiterFIFO[1].deq(); return toArbiterFIFO[1].first();
   endmethod

   method ActionValue#(Packet) arbiter2popPacket();
      toArbiterFIFO[2].deq(); return toArbiterFIFO[2].first();
   endmethod

   method ActionValue#(Packet) nodepopPacket();
      toNodeFIFO.deq(); return toNodeFIFO.first();
   endmethod

endmodule: mkRouter

endpackage: Router

