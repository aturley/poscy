use "buffered"

primitive _BasicEncoder
  fun apply(item: Any val, w: Writer): String ? =>
    match item
    | let s: String =>
      w.write(s)
      w.write(_buffer_for_string(s)?)
      "s"
    | let i: I32 =>
      w.i32_be(i)
      "i"
    | let f: F32 =>
      w.f32_be(f)
      "f"
    | let b: Array[U8] val =>
      w.i32_be(b.size().i32())
      w.write(b)
      w.write(_buffer_for_array(b)?)
      "b"
    else
      error
    end

  fun _buffer_for_string(s: String): Array[U8] val ? =>
    recover
      match s.size() % 4
      | 0 =>
        [0; 0; 0; 0]
      | 1 =>
        [0; 0; 0]
      | 2 =>
        [0; 0]
      | 3 =>
        [0]
      else
        error
      end
    end

  fun _buffer_for_array(ba: Array[U8] val): Array[U8] val ? =>
    recover
      match ba.size() % 4
      | 0 =>
        []
      | 1 =>
        [0; 0; 0]
      | 2 =>
        [0; 0]
      | 3 =>
        [0]
      else
        error
      end
    end

class OSCMessage[T: Any val = (String | I32 | F32 | Array[U8] val)]
  let address: String
  let arguments: Array[T]

  new create(address': String) =>
    address = address'
    arguments = arguments.create()

  fun ref add(o: T) =>
    arguments.push(o)

  fun encode(writer: Writer ref = Writer,
    encoder: _BasicEncoder = _BasicEncoder): Array[U8] val ?
  =>
    let types: String trn = recover String end

    types.append(",")

    for a in arguments.values() do
      types.append(encoder(a, writer)?)
    end

    let data: Array[ByteSeq] iso = writer.done()

    try
      encoder(address, writer)?
      encoder(consume types, writer)?
    end
    writer.writev(consume data)
    _flatten_to_bytes(writer.done())

  fun _flatten_to_bytes(bsa: Array[ByteSeq] val): Array[U8] val =>
    let a: Array[U8] trn = recover a.create() end
    for bs in bsa.values() do
      match bs
      | let s: String =>
        a.append(s.array())
      | let ba: Array[U8] val =>
        a.append(ba)
      end
    end
    consume a

primitive OSCDecoder
  fun apply(reader: Reader): OSCMessage ? =>
    let address = _read_string(reader)?
    let m = OSCMessage(address)
    let types = _read_string(reader)?

    if types(0)? != ',' then
      error
    end

    for t in types.substring(1).values() do
      match t
      | 's' =>
        m.add(_read_string(reader)?)
      | 'i' =>
        m.add(_read_i32(reader)?)
      | 'f' =>
        m.add(_read_f32(reader)?)
      | 'b' =>
        m.add(_read_blob(reader)?)
      else
        error
      end
    end

    m

  fun _read_string(reader: Reader): String ? =>
    let s = reader.read_until(0)?
    let skip_bytes: USize = match (s.size() % 4)
    | 0 => 3
    | 1 => 2
    | 2 => 1
    | 3 => 0
    else
      error
    end
    reader.skip(skip_bytes)?
    String.from_array(consume s)

  fun _read_i32(reader: Reader): I32 ? =>
    reader.i32_be()?

  fun _read_f32(reader: Reader): F32 ? =>
    reader.f32_be()?

  fun _read_blob(reader: Reader): Array[U8] val ? =>
    let sz = reader.i32_be()?.usize()
    reader.block(sz)?
