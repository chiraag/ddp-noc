// Chiraag Juvekar - Fano Circulance Router

package Router;

import GetPut::*;
import Vector::*;
import FIFO::*;

import NoCTypes::*;
import Device::*;

typedef Bit#(TotalNodes) DecodedAddr;
typedef enum {Point, Line} RouterType deriving (Eq, Bits);

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
      let currPacket = inFIFO.first(); inFIFO.deq();
      Integer totalNodes = (valueOf(TotalNodes));
      Address distance = ((fromInteger(totalNodes) + currPacket.destAddress - thisAddr) % fromInteger(totalNodes));
      DecodedAddr toAddr = (1 << distance);

      // (0, 6, 4) (1, 0, 5) (3, 2, 0)
      for(Integer i=0; i<valueOf(Degree); i=i+1) begin
        DecodedAddr pointPattern = 0;
        for(Integer j=0; j<valueOf(Degree); j=j+1) begin
          DecodedAddr currId = (1 << ((totalNodes - incidence[j] + incidence[i])%totalNodes) );          
          if(currId != 1) pointPattern = pointPattern + currId;
        end
        DecodedAddr linePattern = (1 << ((totalNodes - incidence[i])%totalNodes) );

        if(thisType == Point) begin
          if((toAddr & pointPattern) != 0) begin 
            outFIFO[i].enq(currPacket);
            $display("Point:%d Dest %d Pattern %b", thisAddr, currPacket.destAddress, pointPattern);
          end
        end else if(thisType == Line) begin
          if(toAddr == linePattern) begin
            outFIFO[i].enq(currPacket);
            $display("Line:%d Dest %d Pattern %b", thisAddr, currPacket.destAddress, linePattern);
          end
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

