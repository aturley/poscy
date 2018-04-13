use "../.."
use "debug"
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
    let m = recover val OSCMessage("/sndbuf/buf/rate").>add(F32(1.0)) end
    client.send(m)
    client.dispose()
