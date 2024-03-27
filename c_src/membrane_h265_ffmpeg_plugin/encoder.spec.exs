module Membrane.H265.FFmpeg.Encoder.Native

state_type "State"

spec create(
       width :: int,
       height :: int,
       pix_fmt :: atom,
       preset :: atom,
       tune :: atom,
       profile :: atom,
       max_b_frames :: int,
       gop_size :: int,
       framerate_num :: int,
       framerate_denom :: int,
       crf :: int,
       x265_params :: string
     ) :: {:ok :: label, state} | {:error :: label, reason :: atom}

spec encode(payload, pts :: int64, use_shm :: bool, state) ::
      {:ok :: label, dts_list :: [int64], pts_list :: [int64], [payload]}
  |      {:error :: label, reason :: atom}

spec flush(use_shm :: bool, state) ::
       {:ok :: label, dts_list :: [int64], pts_list :: [int64], frames :: [payload]}
       | {:error :: label, reason :: atom}

dirty :cpu, flush: 2, encode: 4
