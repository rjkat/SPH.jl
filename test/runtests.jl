import SPH
import WAV
header = Dict{String, Any}(
    "channel_count"      => 1,
    "sample_coding"      => "pcm",
    "sample_byte_format" => "01",
    "sample_rate"        => 8000,
    "sample_n_bytes"     => 4,
    "sample_count"       => 8000
)
samples = sin.(2 * pi * [0:7999;] * 440.0 / 8000) * 0.01
sph_filename = "example.sph"
wav_filename = "example.wav"
SPH.sphwrite(header, samples, sph_filename)
SPH.sph2wav(sph_filename, wav_filename)
wav_samples, fs = WAV.wavread(wav_filename)
@test samples ≈ wav_samples