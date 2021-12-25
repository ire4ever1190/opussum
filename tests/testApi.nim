import unittest
import opussum
import std/streams

#
# Test data comes from joystock
# Music by Joystock - https://www.joystock.org
#

let rawData = newFileStream("tests/test.raw", fmRead)

var canEncode: bool

suite "Encoder":
  var encoder: OpusEncoder
  test "Create encoder":
    encoder = createEncoder(48000, 2, 960, Voip)

  test "Encode data":
    const size = 1920
    discard encoder.encode(rawData.readStr(size * 2).toPCMBytes(encoder), size)
    canEncode = true
    
suite "Decoder":
  var decoder: OpusDecoder
  test "Create decoder":
    decoder = createDecoder(48000, 2, 960)

  test "Decode data":
    check canEncode
    let encoder = createEncoder(48000, 2, 960, Voip)
    let pcmBytes = rawData.readStr(1920 * 2)
    let encodedData = encoder.encode(pcmBytes.toPCMBytes(encoder), 1920)

GC_fullcollect()
