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
   
   rule cycCounter;
      cyc <= cyc + 1;
      $display("--Cycle %d--",cyc);
      if(cyc == 100) $finish();
   endrule
endmodule: mkTb

endpackage: Tb

