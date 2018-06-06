import SPH
header = Dict{String, Any}(
    "channel_count"      => 1,
    "sample_coding"      => "pcm",
    "sample_byte_format" => "01",
    "sample_rate"        => 8000,
    "sample_n_bytes"     => 4,
    "sample_count"       => 8000
)
samples = sin.(2 * pi * [0:7999;] * 440.0 / 8000) * 0.01

