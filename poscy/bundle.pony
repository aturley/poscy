use "buffered"

primitive Timetag
  fun immediate(): U64 => 1
  fun apply(seconds: U32, frac: U32): U64 =>
    (seconds.u64() << 32) + frac.u64()

class val OSCBundle
  let timetag: U64
  let elements: Array[(OSCBundle | OSCMessage)] val

  new val create(elements': Array[(OSCBundle | OSCMessage)] val,
    timetag': U64 = Timetag.immediate())
  =>
    timetag = timetag'
    elements = elements'

  fun encode(writer: Writer ref = Writer,
    encoder: _BasicEncoder = _BasicEncoder): Array[U8] val ?
  =>
    for e in elements.values() do
      let enc = e.encode()?
      encoder(enc, writer)?
    end

    let encoded_elements: Array[ByteSeq] val = writer.done()

    encoder("#bundle", writer)?
    encoder(timetag, writer)?
    writer.writev(encoded_elements)

    _FlattenToBytes(writer.done())

primitive OSCBundleDecoder
  fun apply(reader: Reader, bundle_size: USize): OSCBundle ? =>
    var bundle_elements_size = bundle_size - 16

    let bundle_id = _Decoder.read_string(reader)?

    if bundle_id != "#bundle" then
      error
    end

    let timetag = _Decoder.read_u64(reader)?

    let bundle_element_contents = Array[Array[U8] val]

    while bundle_elements_size > 0 do
      let contents = _Decoder.read_blob(reader)?
      bundle_element_contents.push(contents)
      bundle_elements_size = bundle_elements_size - (contents.size() + 4)
    end

    let bundle_elements = recover trn Array[(OSCBundle | OSCMessage)] end

    for bundle_element in bundle_element_contents.values() do
      reader.clear()
      reader.append(bundle_element)
      bundle_elements.push(OSCPacketDecoder(reader, bundle_element.size())?)
    end

    OSCBundle(consume bundle_elements, timetag)
