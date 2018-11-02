use "net"
use "poscy"
use "promises"

class _OSCClientUDPNotify is UDPNotify
  let _osc_client: OSCClient

  new create(osc_client: OSCClient) =>
    _osc_client = osc_client

  fun ref listening(sock: UDPSocket ref) =>
    _osc_client.connected(sock.local_address())

  fun ref received(
    sock: UDPSocket ref,
    data: Array[U8] iso,
    from: NetAddress)
  =>
    None

  fun ref not_listening(sock: UDPSocket ref) =>
    None

actor OSCClient
  let _host: String
  let _service: String
  let _connect_promise: Promise[OSCClient]
  let _auth: AmbientAuth
  var _sock: UDPSocket
  var _destination: (None | NetAddress)

  new ip4(host: String, service: String,
    connect_promise: Promise[OSCClient], auth: AmbientAuth)
  =>
    _host = host
    _service = service
    _connect_promise = connect_promise
    _auth = auth
    _sock = UDPSocket.ip4(_auth, recover _OSCClientUDPNotify(this) end)
    _destination = None

  new ip6(host: String, service: String,
    connect_promise: Promise[OSCClient], auth: AmbientAuth)
  =>
    _host = host
    _service = service
    _connect_promise = connect_promise
    _auth = auth
    _sock = UDPSocket.ip6(_auth, recover _OSCClientUDPNotify(this) end)
    _destination = None

  be connected(address: NetAddress) =>
    try
      _destination = if address.ip4() then
        DNS.ip4(_auth, _host, _service)(0)?
      else
        DNS.ip6(_auth, _host, _service)(0)?
      end
    end
    _connect_promise(this)

  be send(packet: (OSCMessage val | OSCBundle val)) =>
    match _destination
    | let dest: NetAddress =>
      try
        _sock.write(packet.encode()?, dest)
      end
    end

  be dispose() =>
    _sock.dispose()
