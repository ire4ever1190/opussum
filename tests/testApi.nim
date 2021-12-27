import unittest
import opussum
import std/streams
import std/os
#
# Test data comes from joystock
# Music by Joystock - https://www.joystock.org
#

var rawData = newFileStream("tests/test.raw", fmRead)
var canEncode: bool

suite "Encoder":
  var encoder: OpusEncoder
  test "Create encoder":
    encoder = createEncoder(48000, 2, 960, Voip)

  test "Encode data":
    # We want to encode 1 frame.
    # Since we have two channels, we need 1920 bytes, and since we need an int16 array we need twice as many bytes
    # Since we have bytes and PCM is int16, we need to get twice as many bytes
    discard encoder.encode(rawData.readStr(960 * encoder.channels * 2).toPCMBytes(encoder))
    canEncode = true
    
suite "Decoder":
  var decoder: OpusDecoder
  test "Create decoder":
    decoder = createDecoder(48000, 2, 960)

  test "Decode data":
    check canEncode
    let encoder = createEncoder(48000, 2, 960, Audio)
    encoder.performCTL(setBitrate, 14000)
    rawData.setPosition 0
    let
      pcmBytes = rawData.readStr(960 * encoder.channels * 2).toPCMBytes(encoder)
      encodedData = encoder.encode(pcmBytes)
      decodedData = decoder.decode(encodedData)

suite "CTL codes":
  let encoder = createEncoder(48000, 2, 960, Audio)
  test "Get a value":
    check encoder.performCTL(getBitrate) == 120000

  test "Set a value":
    encoder.performCTL(setBitrate, 36000)
    check encoder.performCTL(getBitrate) == 36000

rawData.close()
