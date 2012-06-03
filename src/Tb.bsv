// Chiraag Juvekar - Fano Plane Network
package Tb;

import Connectable::*;
import GetPut::*;

import Device::*;
import Node::*;
import Vector::*;
import FIFO::*;
import Router::*;

typedef 3 Degree;
typedef 7 TotalNodes;

Integer incidence[3] = {
  0, 1, 3
};


// ----------------------------------------------------------------
// The testbench

(* synthesize *)
module mkTb (Empty);
   Reg#(UInt#(32)) ldIndex <- mkReg (0);
   Node nodeP[valueOf(TotalNodes)];
   Node nodeL[valueOf(TotalNodes)];
   
   for(Address i = 0; i < fromInteger(valueOf(TotalNodes)); i = i+1) begin
      nodeP[i] <- mkNode(i, Point);
      nodeL[i] <- mkNode(i, Line);
   end
   
   for(Integer i = 0; i < valueOf(TotalNodes); i = i+1) begin
      for(Integer j = 0; j < valueOf(Degree); j = j+1) begin
        mkConnection(nodeP[i].getPacket[j], nodeL[(i+incidence[j])%valueOf(TotalNodes)].putPacket[j]);
        mkConnection(nodeL[(i+incidence[j])%valueOf(TotalNodes)].getPacket[j], nodeP[i].putPacket[j]);
      end
   end
endmodule: mkTb

endpackage: Tb

