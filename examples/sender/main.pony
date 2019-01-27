use "debug"
use "net"
use "poscy"

class SenderNotify is UDPNotify
  let _address: NetAddress

  new iso create(address: NetAddress) =>
    _address = address

  fun ref listening(sock: UDPSocket ref) =>
    let msg = OSCMessage("/hello", recover ["world"; I32(1); F32(2.0)] end)
    try
      sock.write(msg.encode()?, _address)
      sock.dispose()
    else
      Debug("could not encode message")
    end

  fun ref received(
    sock: UDPSocket ref,
    data: Array[U8] iso,
    from: NetAddress)
  =>
    None

  fun ref not_listening(sock: UDPSocket ref) =>
    None

actor Main
  new create(env: Env) =>
    try
      let address = DNS.ip4(env.root as AmbientAuth, "", "8989")(0)?

      UDPSocket(env.root as AmbientAuth, SenderNotify(address))
    else
      env.err.print("could not connect to host")
    end
