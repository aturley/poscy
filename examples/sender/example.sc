thisProcess.openUDPPort(8989); // attempt to open 8989
thisProcess.openPorts; // list all open ports

o = OSCFunc({ arg msg, time, addr, recvPort; [msg, time, addr, recvPort].postln; }, '/hello'); // create the OSCFunc
