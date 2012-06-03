// Chiraag Juvekar - Fano Circulance Router

package Router;

import GetPut::*;
import Vector::*;
import FIFO::*;

import NoCTypes::*;
import Device::*;

typedef Bit#(7) DecodedAddr;
typedef enum {Point, Line} RouterType deriving (Eq, Bits);

DecodedAddr decodeTable[7] = { 7'b0000001, 7'b0000010, 7'b0000100, 7'b0001000, 7'b0010000, 7'b0100000, 7'b1000000 };

// ----------------------------------------------------------------
// Priority model

interface Router;
  interface Put#(Packet) putPacket;
  interface Vector#(Degree, Get#(Packet)) getPacket;
endinterface

(* synthesize *)
module mkRouter #(Address thisAddr, RouterType thisType) (Router);

   // ---- Instruction memory (modeled here using an array of registers)
   FIFO#(Packet) inFIFO <- mkFIFO();
   FIFO#(Packet) outFIFO[valueOf(Degree)];
   for(Integer i =0; i < valueOf(Degree); i=i+1) begin
      outFIFO[i]  <- mkFIFO();
   end
   
   // ----------------
   // RULES
   rule routeOutgoing;
      let currPacket = inFIFO.first();
      inFIFO.deq();
      Address distance = (7 + currPacket.destAddress - thisAddr) % 7;
      DecodedAddr toAddr = decodeTable[distance];
      DecodedAddr pattern = 7'b0001011;            
      
      if(thisType == Point) begin
        if((toAddr & 7'b1010000) != 0) begin
          outFIFO[0].enq(currPacket);
        end else if((toAddr & 7'b0100010) != 0) begin
          outFIFO[1].enq(currPacket);
        end else if((toAddr & 7'b0001100) != 0) begin
          outFIFO[2].enq(currPacket);
        end
      end else if(thisType == Line) begin
        if(toAddr == 7'b0000001) begin
          outFIFO[0].enq(currPacket);
        end else if(toAddr == 7'b1000000) begin
          outFIFO[1].enq(currPacket);
        end else if(toAddr ==  7'b0010000) begin
          outFIFO[2].enq(currPacket);
        end
      end
   endrule

   // ----------------
   // METHODS
   Vector#(Degree, Get#(Packet)) getPacketI;
   for (Integer i=0; i<valueOf(Degree); i=i+1) begin
      getPacketI[i] = toGet(outFIFO[i]);
   end 
   interface getPacket = getPacketI;
   interface putPacket = toPut(inFIFO);

endmodule: mkRouter

endpackage: Router

