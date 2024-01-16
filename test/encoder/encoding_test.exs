defmodule EncoderTest do
  @moduledoc false

  use ExUnit.Case, async: true
  use Membrane.Pipeline

  import Membrane.Testing.Assertions

  alias Membrane.H265
  alias Membrane.RawVideo
  alias Membrane.Testing.Pipeline

  defp prepare_paths(filename, tmp_dir) do
    in_path = "../fixtures/reference-#{filename}.raw" |> Path.expand(__DIR__)
    out_path = Path.join(tmp_dir, "output-encode-#{filename}.h265")
    {in_path, out_path}
  end

  defp make_pipeline(in_path, out_path, width, height, format) do
    Pipeline.start_link_supervised!(
      spec:
        child(:file_src, %Membrane.File.Source{chunk_size: 40_960, location: in_path})
        |> child(:praser, %RawVideo.Parser{width: width, height: height, pixel_format: format})
        |> child(:encoder, %H265.FFmpeg.Encoder{preset: :fast, crf: 30})
        |> child(:sink, %Membrane.File.Sink{location: out_path})
    )
  end

  defp perform_test(filename, tmp_dir, width, height, format \\ :I420) do
    {in_path, out_path} = prepare_paths(filename, tmp_dir)

    pid = make_pipeline(in_path, out_path, width, height, format)
    assert_end_of_stream(pid, :sink, :input, 4000)

    Pipeline.terminate(pid)
  end

  describe "EncodingPipeline should" do
    @describetag :tmp_dir

    test "encode 15 720p frames", ctx do
      perform_test("15-720p-temporal-id-1", ctx.tmp_dir, 1280, 720)
    end

    test "encode 60 480p frames", ctx do
      perform_test("60-480p", ctx.tmp_dir, 640, 480)
    end
  end
end
