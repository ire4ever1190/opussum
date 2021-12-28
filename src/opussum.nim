
import opussum/[
  common,
  encoder,
  decoder,
  pcmdata
]

export common,
  encoder,
  decoder,
  pcmdata

when (NimMajor, NimMinor) > (1, 4): 
  import opussum/ctl
  export ctl



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
