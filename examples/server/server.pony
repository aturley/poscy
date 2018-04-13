use "../.."

class ServerNotify is OSCNotify
  let _out: OutStream

  new create(out: OutStream) =>
    _out = out

  fun ref received(message: OSCMessage iso) =>
    let m = consume message
    _out.print("received: " + m.address)

  fun ref bad_data(data: Array[U8] val) =>
    _out.print("bad data")
    let s = recover iso String end
    for d in data.values() do
      if (d >= 20) and (d < 128) then
        s.push(d)
      else
        s.append(d.string())
      end
      s.append(", ")
    end
    _out.print(consume s)

actor Main
  new create(env: Env) =>
    try
      let host = try env.args(1)? else "" end
      let service = try env.args(2)? else "7878" end

      let this': Main = this
      OSCServer.ip4(recover ServerNotify(env.out) end, host, service,
        env.root as AmbientAuth)
    else
      env.err.print("nope")
    end
