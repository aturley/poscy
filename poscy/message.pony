use "buffered"

type OSCType is (String | I32 | F32 | U32 | Array[U8] val | Bool | None |
  Impulse | U64)

class val OSCMessage
  let address: String
  let arguments: Array[OSCType] val

  new val create(address': String, arguments': Array[OSCType] val) =>
    address = address'
    arguments = arguments'

  fun encode(writer: Writer ref = Writer,
    encoder: Encoder = BasicEncoder): Array[U8] val ?
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
    FlattenToBytes(writer.done())

  fun string(): String iso ^ =>
    let s = recover iso String end

    s.append("{ ")

    s.append(address)
    s.append(" ")

    for a in arguments.values() do
      match a
      | let stringable: Stringable =>
        s.append(stringable.string())
      | let bytes: Array[U8] val =>
        s.append("[ ")
        for b in bytes.values() do
          s.append(b.string())
          s.append(" ")
        end
        s.append("]")
      end
      s.append(" ")
    end

    s.append("}")

    s

primitive OSCMessageDecoder
  fun apply(reader: Reader): OSCMessage ? =>
    let address = _Decoder.read_string(reader)?
    let types = _Decoder.read_string(reader)?
    let args = recover trn Array[OSCType] end

    if types(0)? != ',' then
      error
    end

    for t in types.substring(1).values() do
      match t
      | 's' =>
        args.push(_Decoder.read_string(reader)?)
      | 'i' =>
        args.push(_Decoder.read_i32(reader)?)
      | 'f' =>
        args.push(_Decoder.read_f32(reader)?)
      | 'b' =>
        args.push(_Decoder.read_blob(reader)?)
      | 'u' =>
        args.push(_Decoder.read_u32(reader)?)
      | 'T' =>
        args.push(true)
      | 'F' =>
        args.push(false)
      | 'N' =>
        args.push(None)
      | 'I' =>
        args.push(Impulse)
      | 't' =>
        args.push(_Decoder.read_u64(reader)?)
      else
        error
      end
    end

    OSCMessage(address, consume args)

primitive _Decoder
  fun read_string(reader: Reader): String ? =>
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

  fun read_i32(reader: Reader): I32 ? =>
    reader.i32_be()?

  fun read_u64(reader: Reader): U64 ? =>
    reader.u64_be()?

  fun read_f32(reader: Reader): F32 ? =>
    reader.f32_be()?

  fun read_blob(reader: Reader): Array[U8] val ? =>
    let sz = reader.i32_be()?.usize()
    reader.block(sz)?

  fun read_u32(reader: Reader): U32 ? =>
    reader.u32_be()?
