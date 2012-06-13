#include <iostream>
#include <string>
#include <vector>

#define NSIZE 7
#define HEURISTICLIMIT 10000
#define DRAINLIMIT 100000
#define HEURISTICBIN 100
#define BIGBINS 30

using namespace std;

int main(){
  int cycle=0, maxlatency=2;
  vector< vector< vector<int> > > latencyTable (NSIZE, std::vector<std::vector<int> >(NSIZE, vector<int>(maxlatency+1, 0))) ;
  vector<int> netlatencyTable(maxlatency+1, 0);

  vector<double> runAvgLatency;
  int runPackets=0, runDelaySum=0;
  int netPackets=0, netDelaySum=0;

  vector<vector<int> > offeredLoad  (NSIZE, vector<int>(NSIZE, 0));
  vector<vector<int> > acceptedLoad (NSIZE, vector<int>(NSIZE, 0));
  
  bool saturation = false; int blocked = 0;
  
  while(!cin.eof()){
    string lineStart, lineEnd;
    cin >> lineStart;
    
    //Get the current Cycle Number
    if(lineStart.find("--Cycle")==0){
      cin >> cycle;
      getline(cin, lineEnd);
    } else {
      int devId;
      unsigned int message;
      string messageType;
      cin >> devId >> messageType;
      if(messageType.find("Received")==0){
        cin >> std::hex >> message >> std::dec;

        int sender = message & 0xf;
        int receiver = devId;
        int packetCycle = (message >> 4);
        int latency = cycle - packetCycle;
//        cout << cycle << ": " <<devId << " " << messageType << " " << std::hex << message  << std::dec << endl;
//        cout << sender << " " << receiver << " " << latency << endl;
        
        if(packetCycle > HEURISTICLIMIT ) {
          if(latency > maxlatency){
            maxlatency = latency;
            for(int i=0; i<NSIZE; i++){
              for(int j=0; j<NSIZE; j++){
                latencyTable[i][j].resize(maxlatency+1, 0);
              }
              netlatencyTable.resize(maxlatency+1, 0);
            }
          }
          
          ++latencyTable[sender][receiver][latency];
          ++netlatencyTable[latency];
          
          if(cycle < DRAINLIMIT) ++acceptedLoad[sender][receiver];
        }
        
        ++runPackets;
        runDelaySum += latency;
        if(runPackets == HEURISTICBIN){
          runAvgLatency.push_back((double)runDelaySum/(double)runPackets);
          if(cycle > HEURISTICLIMIT){
            netPackets += runPackets;
            netDelaySum += runDelaySum;
          }
          runPackets = 0;
          runDelaySum = 0;
        }                 
      } else if (messageType.find("Created")==0){
        int sender = devId;
        int receiver; string sfor;
        cin >> std::hex >> message >> std::dec >> sfor >> receiver;
        int packetCycle = (message >> 4);
        
        if((packetCycle > HEURISTICLIMIT) && (packetCycle < DRAINLIMIT)){
          ++offeredLoad[sender][receiver];
        }        
      } else if (messageType.find("Blocked")==0){
        saturation = true; ++blocked;
        if((cycle > HEURISTICLIMIT) && (cycle < DRAINLIMIT)){
          ++offeredLoad[devId][((cycle%(NSIZE-1))+devId+1)%NSIZE]; //Poor man's random function
        }        
      }
      getline(cin, lineEnd);
    }
  }
  cout << "Cycles: " << cycle << ", Maximum Latency: " << maxlatency << endl;
  if(saturation) cout << "Source FIFO saturated, " << blocked << " Blocked" << endl;
  int netRecvd = 0;
  double throughput = 1e10;
  int netOfferedLoad = 0, netAcceptedLoad = 0;
  for(int i=0; i<NSIZE; i++){
    for(int j=0; j<NSIZE; j++){
      if(offeredLoad[i][j] != 0){
        double thputij =  (double)acceptedLoad[i][j]/(double)offeredLoad[i][j];
        if(thputij < throughput) throughput =  thputij;
        netAcceptedLoad += acceptedLoad[i][j];
        netOfferedLoad += offeredLoad[i][j];
//        cout << thputij << "\t";
        cout << "(" << offeredLoad[i][j] << "," << acceptedLoad[i][j] << ")";
      } else {
        cout << "(0   ,   0)" << "\t\t";
      }
    }
    cout << endl;
  }
  cout << "Min-Througput: " << throughput << " Avg-Througput: " << (double)netAcceptedLoad/(double)netOfferedLoad <<endl;
  cout << "Histogram: " << endl;
  for(int i=0; i<=maxlatency; i++)
    cout << i << "\t" << netlatencyTable[i] << endl;

  cout << "Average Latency: " << (double)netDelaySum/(double)netPackets<< endl;  
//  cout << "Average Latency Bins: " << endl;
//  for(int i=0; i<runAvgLatency.size(); i++)
//    cout << i << "\t" << runAvgLatency[i] << endl;
  
  return 0;
}
