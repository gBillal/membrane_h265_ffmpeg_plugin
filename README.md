# Membrane H265 FFmpeg plugin

[![Hex.pm](https://img.shields.io/hexpm/v/membrane_h265_ffmpeg_plugin.svg)](https://hex.pm/packages/membrane_h265_ffmpeg_plugin)
[![API Docs](https://img.shields.io/badge/api-docs-yellow.svg?style=flat)](https://hexdocs.pm/membrane_h265_ffmpeg_plugin/)

This package provides H265 video decoder and encoder, based on [ffmpeg](https://www.ffmpeg.org).

Documentation is available at [HexDocs](https://hexdocs.pm/membrane_h265_ffmpeg_plugin/)

## Installation

Add the following line to your `deps` in `mix.exs`. Run `mix deps.get`.

```elixir
{:membrane_h265_ffmpeg_plugin, "~> 0.4.1"}
```

This package depends on the [ffmpeg](https://www.ffmpeg.org) libraries. The precompiled builds will be pulled and linked automatically. However, should there be any problems, consider installing it manually.

### Manual instalation of dependencies
#### Ubuntu

```bash
sudo apt-get install libavcodec-dev libavformat-dev libavutil-dev
```

#### Arch/Manjaro

```bash
pacman -S ffmpeg
```

#### MacOS

```bash
brew install ffmpeg
```

## Usage Example

### Decoder

The following pipeline takes 30fps H265 file and decodes it to the raw video.

```elixir
defmodule Decoding.Pipeline do
  use Membrane.Pipeline

  alias Membrane.H265

  @impl true
  def handle_init(_ctx, _opts) do
    structure =
      child(:source, %Membrane.File.Source{chunk_size: 40_960, location: "input.h265"})
      |> child(:parser, H265.Parser)
      |> child(:decoder, H265.FFmpeg.Decoder)
      |> child(:sink,  %Membrane.File.Sink{location: "output.raw"})

    {[spec: structure], %{}}
  end
end
```

### Encoder

The following pipeline takes 720p raw video file as input and encodes it as H265.

```elixir
defmodule Encoding.Pipeline do
  use Membrane.Pipeline

  @impl true
  def handle_init(_) do
    structure =
      child(:source, %Membrane.File.Source{chunk_size: 40_960, location: "input.raw"})
      |> child(:parser, %Membrane.RawVideo.Parser{width: 1280, height: 720, pixel_format: :I420})
      |> child(:encoder, %Membrane.H265.FFmpeg.Encoder{preset: :fast, crf: 30})
      |> child(:sink, %Membrane.File.Sink{location: "output.h265"})

    {[spec: structure], %{}}
  end
end
```