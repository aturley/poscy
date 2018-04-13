use "buffered"
use "net"

interface OSCNotify
  fun ref received(message: OSCMessage iso) =>
    None

  fun ref bad_data(data: Array[U8] val) =>
    None

class _OSCServerUDPNotify is UDPNotify
  let _notify: OSCNotify

  new create(notify: OSCNotify iso) =>
    _notify = consume notify

  fun ref received(
    sock: UDPSocket ref,
    data: Array[U8] iso,
    from: NetAddress)
  =>
    let data': Array[U8] val = consume data
    let message: (OSCMessage iso | None) = recover
      let r: Reader ref = Reader
      r.append(data')
      try
        OSCDecoder(r)?
      else
        None
      end
    end

    match (consume message)
    | let m: OSCMessage iso =>
      _notify.received(consume m)
    else
      _notify.bad_data(data')
    end

  fun ref not_listening(sock: UDPSocket ref) =>
    None

actor OSCServer
  new ip4(notify: OSCNotify iso, host: String, service: String,
    auth: AmbientAuth)
  =>
    recover
      UDPSocket.ip4(auth,
        recover _OSCServerUDPNotify(consume notify) end, host, service)
    end

  new ip6(notify: OSCNotify iso, host: String, service: String,
    auth: AmbientAuth)
  =>
    recover
      UDPSocket.ip6(auth,
        recover _OSCServerUDPNotify(consume notify) end, host, service)
    end
