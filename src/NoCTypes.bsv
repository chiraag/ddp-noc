// Network Connectivity Information

typedef 3 Degree;
typedef 7 TotalNodes;

Integer incidence[3] = {
  0, 1, 3
};

// Network Datatype Information
typedef 4  AddressWidth;
typedef 32 DataWidth;
typedef UInt#(AddressWidth) Address;
typedef Bit#(DataWidth)    Data;

typedef struct {
  Address destAddress;
  Data    payloadData;
  } Packet deriving(Bits);



