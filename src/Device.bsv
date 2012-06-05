// Chiraag Juvekar - Sample IO Test-Device

package Device;

import GetPut::*;
import Vector::*;
import FIFO::*;
import SpecialFIFOs::*;


import NoCTypes::*;

// ----------------------------------------------------------------
// Basic Type Definitions
Packet ldData[4] = {
  Packet{destAddress: 3, payloadData: 32'h00000001},
  Packet{destAddress: 6, payloadData: 32'h00000010},
  Packet{destAddress: 1, payloadData: 32'h00000100},
  Packet{destAddress: 2, payloadData: 32'h00001000}
  };

UInt#(32) arrSize = 4;

// ----------------------------------------------------------------
// Device model

interface Device;
   interface Put#(Packet) putPacket;
   interface Get#(Packet) getPacket;
endinterface

(* synthesize *)
module mkDevice #(Address thisAddr) (Device);

   // ---- Instruction memory (modeled here using an array of registers)
   FIFO#(Packet) inFIFO  <- mkBypassFIFO();
   FIFO#(Packet) outFIFO <- mkBypassFIFO();

   Reg#(UInt#(32)) ldIndex <- mkReg (0);

   // ----------------
   // RULES
   rule setupDevice (ldIndex < arrSize);
      let outPacket = ldData[ldIndex];
      outPacket.destAddress = (outPacket.destAddress + thisAddr) % fromInteger(valueOf(TotalNodes));
      outFIFO.enq(outPacket);
      ldIndex <= ldIndex + 1;
   endrule
   
   rule offLoadDevice;
      $display("Device %d, Received %x", thisAddr, inFIFO.first().payloadData);
      inFIFO.deq();
   endrule

   // ----------------
   // METHODS
   interface putPacket = toPut(inFIFO);
   interface getPacket = toGet(outFIFO);

endmodule: mkDevice

endpackage: Device

