
import opussum/[
  common,
  encoder,
  decoder,
  pcmbytes
]

export common,
  encoder,
  decoder,
  pcmbytes




# Generic destructors don't work for some reason so I must manually define
# makeDestructor(OpusDecoder)
# makeDestructor(OpusEncoder)






# https://github.com/bydingnan/opus-demo/blob/master/trivial_example.c
#[
     {
      int i;
      unsigned char pcm_bytes[MAX_FRAME_SIZE*CHANNELS*2];
      int frame_size;

      /* Read a 16 bits/sample audio frame. */
      fread(pcm_bytes, sizeof(short)*CHANNELS, FRAME_SIZE, fin);
      if (feof(fin))
         break;
      /* Convert from little-endian ordering. */
      for (i=0;i<CHANNELS*FRAME_SIZE;i++)
         in[i]=pcm_bytes[2*i+1]<<8|pcm_bytes[2*i];
]#




    


  
# proc destroy*[T](obj: OpaqueOpusObject[T]) {.inline.} =
#   ## Calls the `destroy` proc that is relevant for the internal pointer.
#   ## Use this if you want to manually manage an OpaqueOpusObject_
#   destroy obj.internal
#   obj.internal = nil



