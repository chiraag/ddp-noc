// Chiraag Juvekar - Fano Plane Network
package Tb;

import Connectable::*;
import GetPut::*;

import NoCTypes::*;
import Device::*;
import Node::*;
import Vector::*;
import FIFO::*;
import Router::*;

// ----------------------------------------------------------------
// The testbench

(* synthesize *)
module mkTb (Empty);
   Reg#(Bool) initialized <- mkReg(False); 


   PNode nodeP[valueOf(TotalNodes)];
   LNode nodeL[valueOf(TotalNodes)];
   Device devices[valueOf(TotalNodes)];
   
   Reg#(UInt#(32)) cyc <- mkReg(0);
   
   for(Address i = 0; i < fromInteger(valueOf(TotalNodes)); i = i+1) begin
      nodeP[i] <- mkNodeP(i); nodeL[i] <- mkNodeL(i);
      devices[i] <- mkDevice(i);
   end
   
   for(Integer i = 0; i < valueOf(TotalNodes); i = i+1) begin
      mkConnection(devices[i].getPacket, nodeP[i].putPacketNode);
      mkConnection(nodeP[i].getPacketNode, devices[i].putPacket);
      for(Integer j = 0; j < valueOf(Degree); j = j+1) begin
        mkConnection(nodeP[i].getPacket[j], nodeL[(i+incidence[j])%valueOf(TotalNodes)].putPacket[j]);
        mkConnection(nodeL[(i+incidence[j])%valueOf(TotalNodes)].getPacket[j], nodeP[i].putPacket[j]);
      end
   end
   
   rule init (!initialized);
     for(Address i = 0; i < fromInteger(valueOf(TotalNodes)); i = i+1) begin
        devices[i].init();
     end
     initialized <= True; 
   endrule

   rule cycCounter(initialized);
      cyc <= cyc + 1;
      $display("--Cycle %d--",cyc);
   endrule
   
   rule fini (initialized);
      Vector#(TotalNodes, UInt#(32)) devRXVal;
      for(Integer i=0; i<valueOf(TotalNodes); i=i+1) begin
        devRXVal[i] = devices[i].rxVal;
      end
      UInt#(32) nextRXVal = fold(\+ , devRXVal);
      
      if(nextRXVal > fromInteger(valueOf(TotalNodes))*txNodeLimit) begin
        initialized <= False;
        $finish();
      end
   endrule
endmodule: mkTb

endpackage: Tb

