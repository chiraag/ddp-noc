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
   Reg#(UInt#(32)) ldIndex <- mkReg (0);
   Node nodeP[valueOf(TotalNodes)];
   Node nodeL[valueOf(TotalNodes)];
   
   for(Address i = 0; i < fromInteger(valueOf(TotalNodes)); i = i+1) begin
      nodeP[i] <- mkNodeP(i);
      nodeL[i] <- mkNodeL(i);
   end
   
   for(Integer i = 0; i < valueOf(TotalNodes); i = i+1) begin
      for(Integer j = 0; j < valueOf(Degree); j = j+1) begin
        mkConnection(nodeP[i].getPacket[j], nodeL[(i+incidence[j])%valueOf(TotalNodes)].putPacket[j]);
        mkConnection(nodeL[(i+incidence[j])%valueOf(TotalNodes)].getPacket[j], nodeP[i].putPacket[j]);
      end
   end
endmodule: mkTb

endpackage: Tb

