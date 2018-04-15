use "buffered"

primitive OSCPacketDecoder
  fun apply(reader: Reader ref, size: USize): (OSCMessage | OSCBundle) ? =>
    match reader.peek_u8()?
    | '#' =>
      OSCBundleDecoder(reader, size)?
    | '/' =>
      OSCMessageDecoder(reader)?
    else
      error
    end
