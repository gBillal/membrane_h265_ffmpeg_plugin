defmodule DecoderTest do
  use ExUnit.Case
  use Membrane.Pipeline

  import Membrane.Testing.Assertions

  alias Membrane.H265
  alias Membrane.Testing.Pipeline

  defp prepare_paths(filename, tmp_dir) do
    in_path = "../fixtures/input-#{filename}.h265" |> Path.expand(__DIR__)
    reference_path = "../fixtures/reference-#{filename}.raw" |> Path.expand(__DIR__)
    out_path = Path.join(tmp_dir, "output-decoding-#{filename}.raw")
    {in_path, reference_path, out_path}
  end

  defp make_pipeline(in_path, out_path) do
    Pipeline.start_link_supervised!(
      structure:
        child(:file_src, %Membrane.File.Source{chunk_size: 40_960, location: in_path})
        |> child(:parser, H265.Parser)
        |> child(:decoder, H265.FFmpeg.Decoder)
        |> child(:sink, %Membrane.File.Sink{location: out_path})
    )
  end

  defp assert_files_equal(file_a, file_b) do
    assert {:ok, a} = File.read(file_a)
    assert {:ok, b} = File.read(file_b)
    assert a == b
  end

  defp perform_decoding_test(filename, tmp_dir, timeout) do
    {in_path, ref_path, out_path} = prepare_paths(filename, tmp_dir)

    pid = make_pipeline(in_path, out_path)
    assert_pipeline_play(pid)
    assert_end_of_stream(pid, :sink, :input, timeout)
    assert_files_equal(out_path, ref_path)
  end

  describe "DecodingPipeline should" do
    @describetag :tmp_dir
    test "decode 60 480p frames", ctx do
      perform_decoding_test("60-480p", ctx.tmp_dir, 500)
    end

    test "decode 10 320p frames with main still picture profile", ctx do
      perform_decoding_test("10-320p-mainstillpicture", ctx.tmp_dir, 1000)
    end

    test "decode 15 720p frames with high temporal sub-layer id", ctx do
      perform_decoding_test("15-720p-temporal-id-1", ctx.tmp_dir, 1000)
    end

    test "decode 30 720p frames with rext profile", ctx do
      perform_decoding_test("30-720p-rext", ctx.tmp_dir, 2000)
    end

    test "decode 30 480p frames with no b-frames", ctx do
      perform_decoding_test("30-480p-no-bframes", ctx.tmp_dir, 1000)
    end
  end
end
