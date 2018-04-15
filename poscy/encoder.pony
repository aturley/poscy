use "buffered"

interface Encoder
  fun apply(item: Any val, w: Writer): String ?

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
    | let u: U32 =>
      w.u32_be(u)
      "u"
    | let b: Bool =>
      match b
      | true =>
        "T"
      else
        "F"
      end
    | let n: None =>
      "N"
    | Impulse =>
      "I"
    | let u: U64 =>
      // OSC timetag
      w.u64_be(u)
      "t"
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

primitive _FlattenToBytes
  fun apply(bsa: Array[ByteSeq] val): Array[U8] val =>
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
