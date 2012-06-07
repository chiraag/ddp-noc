// Chiraag Juvekar - Sample IO Test-Device

package Device;

import GetPut::*;
import Vector::*;
import FIFO::*;
import SpecialFIFOs::*;
import Randomizable::*;

import NoCTypes::*;
typedef UInt#(8) Prob;

// ----------------------------------------------------------------
// Device model

interface Device;
   interface Put#(Packet) putPacket;
   interface Get#(Packet) getPacket;
   method Action init;
endinterface

(* synthesize *)
module mkDevice #(Address thisAddr) (Device);

   // ---- Instruction memory (modeled here using an array of registers)
   FIFO#(Packet) inFIFO  <- mkBypassFIFO();
   FIFO#(Packet) outFIFO <- mkBypassFIFO();
   Reg#(Bool) devInit <- mkReg(False);
   Reg#(Data) dataBase <- mkReg(0);
   Randomize#(Address) destRnd <- mkConstrainedRandomizer(0,fromInteger(valueOf(TotalNodes)-1));
   Randomize#(Prob)    probRnd <- mkConstrainedRandomizer(0,100);
   
   Prob sendProb = 75;

   // ----------------
   // RULES
   rule setupDevice(devInit);
      let rndAddr <- destRnd.next();
      let rndProb <- probRnd.next();
      Packet outPacket = Packet{destAddress: rndAddr, payloadData: (dataBase + unpack(extend(pack(thisAddr))))};
      if(rndProb <= sendProb && (rndAddr != thisAddr)) outFIFO.enq(outPacket);
      dataBase <= dataBase + 32'h00010000;
   endrule
   
   rule offLoadDevice;
      $display("Device %d, Received %x", thisAddr, inFIFO.first().payloadData);
      inFIFO.deq();
   endrule

   // ----------------
   // METHODS
   interface putPacket = toPut(inFIFO);
   interface getPacket = toGet(outFIFO);
   method Action init() if(!devInit);
      destRnd.cntrl.init(); 
      probRnd.cntrl.init();
      devInit <= True;       
   endmethod

endmodule: mkDevice

endpackage: Device

