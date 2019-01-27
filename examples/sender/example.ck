// create our OSC receiver
OscIn oin;
// create our OSC message
OscMsg msg;
// use port 8989
8989 => oin.port;
// create an address in the receiver
oin.addAddress("/hello, sif");

// infinite event loop
while ( true )
{
    // wait for event to arrive
    oin => now;

    // grab the next message from the queue.
    while ( oin.recv(msg) != 0 )
    {
        // print
        <<< "got (via OSC):", msg.getString(0), msg.getInt(1), msg.getFloat(2) >>>;
    }
}
