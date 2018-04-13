use "buffered"
use "ponytest"

actor Main is TestList
  new create(env: Env) => PonyTest(env, this)

  fun tag tests(test: PonyTest) =>
    test(_TestEncodeString)
    test(_TestEncodeI32)
    test(_TestEncodeF32)
    test(_TestEncodeBlob)
    test(_TestDecodeString)
    test(_TestDecodeI32)
    test(_TestDecodeF32)
    test(_TestDecodeBlob)

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

class iso _TestEncodeString is UnitTest
  fun name(): String => "poscy/string"

  fun apply(h: TestHelper) ? =>
    let m = OSCMessage("/a/b/c")
    m.add("hi")
    let bytes = m.encode()?
    h.assert_array_eq[U8](bytes, Array[U8].>append(
      "/a/b/c".array()).>push(0).>push(0).>
      push('s').>push(0).>push(0).>push(0).>
      append("hi").>push(0).>push(0))

class iso _TestEncodeI32 is UnitTest
  fun name(): String => "poscy/i32"

  fun apply(h: TestHelper) ? =>
    let m = OSCMessage("/a/b/c")
    m.add(I32(0x3EADBEEF))
    let bytes = m.encode()?
    h.assert_array_eq[U8](bytes, Array[U8].>append(
      "/a/b/c".array()).>push(0).>push(0).>
      push('i').>push(0).>push(0).>push(0).>
      push(0x3E).>push(0xAD).>push(0xBE).>push(0xEF))

class iso _TestEncodeF32 is UnitTest
  fun name(): String => "poscy/f32"

  fun apply(h: TestHelper) ? =>
    let m = OSCMessage("/a/b/c")
    m.add(F32(101.32))
    let bytes = m.encode()?
    h.assert_array_eq[U8](bytes, Array[U8].>append(
      "/a/b/c".array()).>push(0).>push(0).>
      push('f').>push(0).>push(0).>push(0).>
      push(66).>push(202).>push(163).>push(215))

class iso _TestEncodeBlob is UnitTest
  fun name(): String => "poscy/blob"

  fun apply(h: TestHelper) ? =>
    let m = OSCMessage("/a/b/c")
    m.add(recover [as U8: 0xDE; 0xAD; 0xBE; 0xEF] end)
    let bytes = m.encode()?
    h.assert_array_eq[U8](bytes, Array[U8].>append(
      "/a/b/c".array()).>push(0).>push(0).>
      push('b').>push(0).>push(0).>push(0).>
      push(0).>push(0).>push(0).>push(4).>
      push(0xDE).>push(0xAD).>push(0xBE).>push(0xEF))

class iso _TestDecodeString is UnitTest
  fun name(): String => "poscy/string_decode"

  fun apply(h: TestHelper) ? =>
    let b = _FlattenToBytes(recover [
      "/a/b/c"; recover [as U8: 0; 0] end
      ",s"; recover [as U8: 0; 0] end
      "hi"; recover [as U8: 0; 0] end
      ] end)
    let r: Reader ref = Reader
    r.append(b)
    let m = OSCDecoder(r)?
    h.assert_eq[String]("/a/b/c", m.address)

    let arg0 = m.arguments(0)? as String

    h.assert_eq[String]("hi", arg0)

class iso _TestDecodeI32 is UnitTest
  fun name(): String => "poscy/i32_decode"

  fun apply(h: TestHelper) ? =>
    let b = _FlattenToBytes(recover [
      "/a/b/c"; recover [as U8: 0; 0] end
      ",i"; recover [as U8: 0; 0] end
      recover [as U8: 0x3E; 0xAD; 0xBE; 0xEF] end
      ] end)
    let r: Reader ref = Reader
    r.append(b)
    let m = OSCDecoder(r)?
    h.assert_eq[String]("/a/b/c", m.address)

    let arg0 = m.arguments(0)? as I32

    h.assert_eq[I32](I32(0x3EADBEEF), arg0)

class iso _TestDecodeF32 is UnitTest
  fun name(): String => "poscy/f32_decode"

  fun apply(h: TestHelper) ? =>
    let b = _FlattenToBytes(recover [
      "/a/b/c"; recover [as U8: 0; 0] end
      ",f"; recover [as U8: 0; 0] end
      recover [as U8: 66; 202; 163; 215] end
      ] end)
    let r: Reader ref = Reader
    r.append(b)
    let m = OSCDecoder(r)?
    h.assert_eq[String]("/a/b/c", m.address)

    let arg0 = m.arguments(0)? as F32

    h.assert_eq[F32](101.32, arg0)

class iso _TestDecodeBlob is UnitTest
  fun name(): String => "poscy/blob_decode"

  fun apply(h: TestHelper) ? =>
    let b = _FlattenToBytes(recover [
      "/a/b/c"; recover [as U8: 0; 0] end
      ",b"; recover [as U8: 0; 0] end
      recover [as U8: 0; 0; 0; 4] end
      recover [as U8: 0xDE; 0xAD; 0xBE; 0xEF] end
      ] end)
    let r: Reader ref = Reader
    r.append(b)
    let m = OSCDecoder(r)?
    h.assert_eq[String]("/a/b/c", m.address)

    let arg0 = m.arguments(0)? as Array[U8] val

    h.assert_array_eq[U8]([as U8: 0xDE; 0xAD; 0xBE; 0xEF], arg0)
