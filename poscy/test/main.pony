use "buffered"
use "ponytest"
use ".."

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

class iso _TestEncodeString is UnitTest
  fun name(): String => "poscy/string"

  fun apply(h: TestHelper) ? =>
    let m = OSCMessage("/a/b/c", recover ["hi"] end)
    let bytes = m.encode()?
    h.assert_array_eq[U8](bytes, Array[U8].>append(
      "/a/b/c".array()).>push(0).>push(0).>
      push(',').>push('s').>push(0).>push(0).>
      append("hi").>push(0).>push(0))

class iso _TestEncodeI32 is UnitTest
  fun name(): String => "poscy/i32"

  fun apply(h: TestHelper) ? =>
    let m = OSCMessage("/a/b/c", recover [I32(0x3EADBEEF)] end)
    let bytes = m.encode()?
    h.assert_array_eq[U8](bytes, Array[U8].>append(
      "/a/b/c".array()).>push(0).>push(0).>
      push(',').>push('i').>push(0).>push(0).>
      push(0x3E).>push(0xAD).>push(0xBE).>push(0xEF))

class iso _TestEncodeF32 is UnitTest
  fun name(): String => "poscy/f32"

  fun apply(h: TestHelper) ? =>
    let m = OSCMessage("/a/b/c", recover [F32(101.32)] end)
    let bytes = m.encode()?
    h.assert_array_eq[U8](bytes, Array[U8].>append(
      "/a/b/c".array()).>push(0).>push(0).>
      push(',').>push('f').>push(0).>push(0).>
      push(66).>push(202).>push(163).>push(215))

class iso _TestEncodeBlob is UnitTest
  fun name(): String => "poscy/blob"

  fun apply(h: TestHelper) ? =>
    let m = OSCMessage("/a/b/c", recover [recover [as U8: 0xDE; 0xAD; 0xBE; 0xEF] end] end)
    let bytes = m.encode()?
    h.assert_array_eq[U8](bytes, Array[U8].>append(
      "/a/b/c".array()).>push(0).>push(0).>
      push(',').>push('b').>push(0).>push(0).>
      push(0).>push(0).>push(0).>push(4).>
      push(0xDE).>push(0xAD).>push(0xBE).>push(0xEF))

class iso _TestDecodeString is UnitTest
  fun name(): String => "poscy/string_decode"

  fun apply(h: TestHelper) ? =>
    let b = FlattenToBytes(recover [
      "/a/b/c"; recover [as U8: 0; 0] end
      ",s"; recover [as U8: 0; 0] end
      "hi"; recover [as U8: 0; 0] end
      ] end)
    let r: Reader ref = Reader
    r.append(b)
    let m = OSCMessageDecoder(r)?
    h.assert_eq[String]("/a/b/c", m.address)

    let arg0 = m.arguments(0)? as String

    h.assert_eq[String]("hi", arg0)

class iso _TestDecodeI32 is UnitTest
  fun name(): String => "poscy/i32_decode"

  fun apply(h: TestHelper) ? =>
    let b = FlattenToBytes(recover [
      "/a/b/c"; recover [as U8: 0; 0] end
      ",i"; recover [as U8: 0; 0] end
      recover [as U8: 0x3E; 0xAD; 0xBE; 0xEF] end
      ] end)
    let r: Reader ref = Reader
    r.append(b)
    let m = OSCMessageDecoder(r)?
    h.assert_eq[String]("/a/b/c", m.address)

    let arg0 = m.arguments(0)? as I32

    h.assert_eq[I32](I32(0x3EADBEEF), arg0)

class iso _TestDecodeF32 is UnitTest
  fun name(): String => "poscy/f32_decode"

  fun apply(h: TestHelper) ? =>
    let b = FlattenToBytes(recover [
      "/a/b/c"; recover [as U8: 0; 0] end
      ",f"; recover [as U8: 0; 0] end
      recover [as U8: 66; 202; 163; 215] end
      ] end)
    let r: Reader ref = Reader
    r.append(b)
    let m = OSCMessageDecoder(r)?
    h.assert_eq[String]("/a/b/c", m.address)

    let arg0 = m.arguments(0)? as F32

    h.assert_eq[F32](101.32, arg0)

class iso _TestDecodeBlob is UnitTest
  fun name(): String => "poscy/blob_decode"

  fun apply(h: TestHelper) ? =>
    let b = FlattenToBytes(recover [
      "/a/b/c"; recover [as U8: 0; 0] end
      ",b"; recover [as U8: 0; 0] end
      recover [as U8: 0; 0; 0; 4] end
      recover [as U8: 0xDE; 0xAD; 0xBE; 0xEF] end
      ] end)
    let r: Reader ref = Reader
    r.append(b)
    let m = OSCMessageDecoder(r)?
    h.assert_eq[String]("/a/b/c", m.address)

    let arg0 = m.arguments(0)? as Array[U8] val

    h.assert_array_eq[U8]([as U8: 0xDE; 0xAD; 0xBE; 0xEF], arg0)
