High level wrapper around [libopus](https://opus-codec.org/) (tested against 1.3.1)

Requires `opus` to be installed (usually done with your systems package manager, you can also follow the guide [here](https://github.com/shardlab/discordrb/wiki/Installing-libopus))


[![Tests](https://github.com/ire4ever1190/opussum/actions/workflows/test.yml/badge.svg)](https://github.com/ire4ever1190/opussum/actions/workflows/test.yml)

[Docs here](https://tempdocs.netlify.app/opussum/stable)

A lot of the documentation for the procs is copied from their original documentation [here](https://www.opus-codec.org/docs/opus_api-1.3.1/index.html) and
so it another good place for research if you are using the library

**Status**
- [x] [encoder](https://www.opus-codec.org/docs/opus_api-1.3.1/group__opus__encoder.html) (high level `encodeFloat` not finished)
- [x] [decoder](https://www.opus-codec.org/docs/opus_api-1.3.1/group__opus__decoder.html) (high level `encodeFloat` not finished)
- [x] [Library information](https://www.opus-codec.org/docs/opus_api-1.3.1/group__opus__libinfo.html)
- [ ] [Repacketizer](https://www.opus-codec.org/docs/opus_api-1.3.1/group__opus__repacketizer.html)
- [ ] [multistream](https://www.opus-codec.org/docs/opus_api-1.3.1/group__opus__multistream.html)


Big thanks to [nim-opusenc](https://git.sr.ht/~ehmry/nim_opusenc) by Emery and [nim-opus](https://github.com/capocasa/nim-opus) by Capocasa who's repos I looked at for
help in wrapping this


