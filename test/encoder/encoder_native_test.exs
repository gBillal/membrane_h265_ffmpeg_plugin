defmodule Encoder.NativeTest do
  @moduledoc false

  use ExUnit.Case, async: true

  import Membrane.Time

  alias Membrane.H265.FFmpeg.Common
  alias Membrane.H265.FFmpeg.Encoder.Native, as: Enc

  test "Encode 1 480p frame" do
    in_path = "../fixtures/reference-60-480p.raw" |> Path.expand(__DIR__)

    assert {:ok, file} = File.read(in_path)
    assert {:ok, ref} = Enc.create(640, 480, :I420, :fast, nil, :high, -1, -1, 1, 1, 28)
    assert <<frame::bytes-size(460_800), _tail::binary>> = file

    Enum.each(
      0..5,
      fn timestamp ->
        assert {:ok, [], [], []} ==
                 Enc.encode(
                   frame,
                   Common.to_h265_time_base_truncated(seconds(timestamp)),
                   false,
                   ref
                 )
      end
    )

    assert {:ok, dts_list, pts_list, frames} = Enc.flush(false, ref)
    assert Enum.all?([dts_list, pts_list, frames], &(length(&1) == 6))

    expected_timestamps = Enum.map(0..5, &Common.to_h265_time_base_truncated(seconds(&1)))

    assert Enum.sort(pts_list) == expected_timestamps
  end
end
