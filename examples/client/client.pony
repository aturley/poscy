use "../../poscy"
use "promises"

actor Main
  new create(env: Env) =>
    try
      let host = try env.args(1)? else "localhost" end
      let service = try env.args(2)? else "7878" end

      let this': Main = this
      OSCClient.ip4(host, service,
        Promise[OSCClient].>next[None](
          recover {(client)(this') => this'.client_connected(client)} end),
        env.root as AmbientAuth)
    end

  be client_connected(client: OSCClient) =>
    let m = recover val OSCMessage("/hello",
      recover ["one"
        F32(2.0)
        I32(3)
        U32(4)
        recover [as U8: 5; 6] end
        true
        false
        None
        Impulse
        U64(100)] end)
    end
    client.send(m)
    let b = recover val OSCBundle(recover [m] end) end
    client.send(b)
    client.dispose()
