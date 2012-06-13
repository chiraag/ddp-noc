// Chiraag Juvekar - Sample IO Test-Device

package Device;

import GetPut::*;
import Vector::*;
import FIFO::*;
import FIFOF::*;
import SpecialFIFOs::*;
import Randomizable::*;
import LFSR::*;

import NoCTypes::*;
// ----------------------------------------------------------------
// Device model

interface Device;
   interface Put#(NoCPacket) putPacket;
   interface Get#(NoCPacket) getPacket;
   method Action init;
   method UInt#(32) rxVal;
endinterface

(* synthesize *)
module mkDevice #(Address thisAddr) (Device);

   // ---- Instruction memory (modeled here using an array of registers)
   FIFO#(NoCPacket) inFIFO  <- mkBypassFIFO();
   FIFOF#(NoCPacket) outFIFO <- mkSizedBypassFIFOF(1000000);
   Reg#(Bool) devInit <- mkReg(False);
   Reg#(Data) dataBase <- mkReg(0);
   Reg#(UInt#(32)) txCount <- mkReg(0);
   Reg#(UInt#(32)) rxCount <- mkReg(0);
   
   Randomize#(Address) destRnd <- mkConstrainedRandomizer(0,fromInteger(valueOf(TotalNodes)-1));
   Randomize#(Prob)    probRnd <- mkConstrainedRandomizer(0,100);
   
   // ----------------
   // RULES
   rule txPacket(devInit);
      let rndAddr <- destRnd.next();
      let rndProb <- probRnd.next();
      NoCPacket outPacket = NoCPacket{destAddress: rndAddr, payloadData: (dataBase + unpack(extend(pack(thisAddr))))};
      if(outFIFO.notFull) begin
        if(rndProb <= sendProb && (rndAddr != thisAddr)) begin
          $display("Device %d Created %x for %d", thisAddr, outPacket.payloadData, outPacket.destAddress);
          outFIFO.enq(outPacket);
          txCount <= txCount + 1;
        end 
      end else begin
        $display("Device %d Blocked", thisAddr);
      end
   endrule

   rule cycCount(devInit);
      dataBase <= dataBase + 32'h00000010;
   endrule

   rule rxPacket(devInit);
      $display("Device %d Received %x", thisAddr, inFIFO.first().payloadData);
      inFIFO.deq();
      rxCount <= rxCount + 1;
   endrule

   // ----------------
   // METHODS
   interface putPacket = toPut(inFIFO);
   interface getPacket = toGet(outFIFO);
   
   method Action init() if(!devInit);
      destRnd.cntrl.init(); 
      probRnd.cntrl.init();
      devInit <= True;       
      txCount <= 0;
      rxCount <= 0;
   endmethod
   
   method UInt#(32) rxVal();
      return rxCount;
   endmethod
   
endmodule: mkDevice

(* synthesize *)
module mkDeviceFPGA #(Address thisAddr) (Device);

   // ---- Instruction memory (modeled here using an array of registers)
   FIFO#(NoCPacket) inFIFO  <- mkBypassFIFO();
   FIFOF#(NoCPacket) outFIFO <- mkSizedBypassFIFOF(1000000);
   Reg#(Bool) devInit <- mkReg(False);
   Reg#(Data) dataBase <- mkReg(0);
   Reg#(UInt#(32)) txCount <- mkReg(0);
   Reg#(UInt#(32)) rxCount <- mkReg(0);
   
   LFSR#(Bit#(32)) destRnd <- mkLFSR_32;
   LFSR#(Bit#(32)) probRnd <- mkLFSR_32;
   
   // ----------------
   // RULES
   rule txPacket(devInit);
      Address rndAddr = unpack({1'b0,destRnd.value[25:23]});
      Prob    rndProb = unpack(probRnd.value[25:18]);
      NoCPacket outPacket = NoCPacket{destAddress: rndAddr, payloadData: (dataBase + unpack(extend(pack(thisAddr))))};
      if(outFIFO.notFull) begin
        if(rndProb <= sendProbFPGA && (rndAddr != thisAddr) && (rndAddr != 7))begin
          $display("Device %d Created %x for %d", thisAddr, outPacket.payloadData, outPacket.destAddress);
          outFIFO.enq(outPacket);
          txCount <= txCount + 1;
        end 
      end else begin
        $display("Device %d Blocked", thisAddr);
      end
   endrule

   rule cycCount(devInit);
      dataBase <= dataBase + 32'h00000010;
      destRnd.next();
      probRnd.next();
   endrule

   rule rxPacket(devInit);
      $display("Device %d Received %x", thisAddr, inFIFO.first().payloadData);
      inFIFO.deq();
      rxCount <= rxCount + 1;
   endrule

   // ----------------
   // METHODS
   interface putPacket = toPut(inFIFO);
   interface getPacket = toGet(outFIFO);
   
   method Action init() if(!devInit);
      destRnd.seed({pack(thisAddr),8'hff,pack(thisAddr),16'hffff}); 
      probRnd.seed({pack(thisAddr),8'h0f,pack(thisAddr),16'hf00f});
      devInit <= True;       
      txCount <= 0;
      rxCount <= 0;
   endmethod
   
   method UInt#(32) rxVal();
      return rxCount;
   endmethod
   
endmodule: mkDeviceFPGA

endpackage: Device

