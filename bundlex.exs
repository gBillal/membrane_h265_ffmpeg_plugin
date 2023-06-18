defmodule Membrane.H265.FFmpeg.BundlexProject do
  use Bundlex.Project

  def project() do
    [
      natives: natives()
    ]
  end

  defp natives() do
    [
      decoder: [
        interface: :nif,
        sources: ["decoder.c"],
        pkg_configs: ["libavcodec", "libavutil"],
        preprocessor: Unifex
      ]
    ]
  end
end
