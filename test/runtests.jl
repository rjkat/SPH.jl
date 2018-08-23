using Test
import SPH
import WAV

function make_sph_header(;coding="pcm")
    header = Dict{String, Any}(
        "channel_count"      => 1,
        "sample_rate"        => 8000,
        "sample_count"       => 8000
    )
    if coding != nothing
        header["sample_coding"] = coding
    end
    if coding in ["pcm", nothing]
        header["sample_byte_format"] = "0123"
        header["sample_n_bytes"] = 4
    else
        @assert coding in ["ulaw", "alaw"]
        header["sample_n_bytes"] = 1
    end
    return header
end

function test_sph2wav()
    samples = sin.(2 * pi * [0:7999;] * 440.0 / 8000) * 0.01
    sph_filename = tempname()
    wav_filename = tempname()
    header = make_sph_header()
    SPH.sphwrite(header, samples, sph_filename)
    SPH.sph2wav(sph_filename, wav_filename)
    wav_samples, fs = WAV.wavread(wav_filename)
    rm(sph_filename)
    rm(wav_filename)
    @test all(isapprox.(wav_samples, samples; atol=1e-9))
end

function test_sph_roundtrip(;coding="pcm")
    header = make_sph_header(coding=coding)
    samples = sin.(2 * pi * [0:7999;] * 440.0 / 8000) * 0.01
    sph_filename = tempname()
    SPH.sphwrite(header, samples, sph_filename)
    sph_header, sph_samples = SPH.sphread(sph_filename)
    rm(sph_filename)
    @test Set(keys(header)) == Set(keys(sph_header))
    @test all([header[k] == sph_header[k] for k in keys(header)])
    tolerance = coding in ["pcm", nothing] ? 1e-9 : 1e-3
    @test all(isapprox.(sph_samples, samples; atol=tolerance))
end

test_sph2wav()
# nothing == sample_coding not specified in header, should assume pcm in this case
for coding in ["pcm", "ulaw", "alaw", nothing]
    test_sph_roundtrip(coding=coding)
end
