defmodule TranscodingTest do
  @moduledoc false

  use ExUnit.Case
  use Membrane.Pipeline

  import Membrane.Testing.Assertions
  alias Membrane.H265
  alias Membrane.Testing.Pipeline

  defp make_pipeline(in_path, out_path) do
    Pipeline.start_link_supervised!(
      structure: [
        child(:file_src, %Membrane.File.Source{chunk_size: 40_960, location: in_path})
        |> child(:parser, %H265.Parser{framerate: {1, 30}})
        |> child(:decoder, H265.FFmpeg.Decoder)
        |> child(:encoder, %H265.FFmpeg.Encoder{preset: :fast, crf: 30})
        |> child(:sink, %Membrane.File.Sink{location: out_path})
      ]
    )
  end

  defp perform_test(filename, tmp_dir, timeout) do
    in_path = "../fixtures/input-#{filename}.h265" |> Path.expand(__DIR__)
    out_path = Path.join(tmp_dir, "output-transcode-#{filename}.h265")

    pid = make_pipeline(in_path, out_path)
    assert_pipeline_play(pid)
    assert_end_of_stream(pid, :sink, :input, timeout)
  end

  describe "TranscodingPipeline should" do
    @describetag :tmp_dir

    test "transcode 15 720p frames", ctx do
      perform_test("15-720p-temporal-id-1", ctx.tmp_dir, 2000)
    end

    test "transcode 60 480p frames", ctx do
      perform_test("60-480p", ctx.tmp_dir, 2000)
    end
  end
end
