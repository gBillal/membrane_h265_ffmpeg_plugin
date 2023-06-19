defmodule Decoder.NativeTest do
  use ExUnit.Case, async: true
  alias Membrane.H265.FFmpeg.Decoder.Native
  alias Membrane.Payload

  test "Decode 1 480p frame" do
    in_path = "../fixtures/input-60-480p.h265" |> Path.expand(__DIR__)
    ref_path = "../fixtures/reference-60-480p.raw" |> Path.expand(__DIR__)

    assert {:ok, file} = File.read(in_path)
    assert {:ok, decoder_ref} = Native.create()
    assert <<frame::bytes-size(49_947), _rest::binary>> = file
    assert {:ok, _pts_list, _frames} = Native.decode(frame, 0, 0, false, decoder_ref)
    assert {:ok, _pts_list, [frame]} = Native.flush(false, decoder_ref)
    assert Payload.size(frame) == 460_800
    assert {:ok, ref_file} = File.read(ref_path)
    assert <<ref_frame::bytes-size(460_800), _rest::binary>> = ref_file
    assert Payload.to_binary(frame) == ref_frame
  end
end
