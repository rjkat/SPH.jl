module SPH
    import WAV

    export sphread, sphreadheader, sphwrite, sph2wav

    # isip.piconepress.com/projects/speech/software/tutorials/production/fundamentals/v1.0/section_02/text/nist_sphere.text
    function sphreadheader(io::IO)
        sph = Array{UInt8}(undef, 16)
        read!(io, sph)
        version = sph[1:8]
        header_len = parse(Int, String(sph[9:16]))
        h = Array{UInt8}(undef, header_len - 16)
        read!(io, h)
        header_lines = strip.(split(String(h), "\n"))
        header = Dict{String, Any}()

        for l in header_lines
            l = rstrip(l, '\0')
            if isempty(l)
                continue
            end
            toks = split(l)
            i = 1
            if startswith(toks[i], ';')
                i += 1
            end
            if length(toks[i:end]) < 3
                continue
            end
            (obj, t, val) = toks[i:i+2]
            if t == "-i"
                header[obj] = parse(Int, val)
            elseif t == "-r"
                header[obj] = parse(Float32, val)
            elseif val == "TRUE"
                header[obj] = true
            elseif val == "FALSE"
                header[obj] = false
            else
                header[obj] = val
            end
        end
        return header, header_len
    end

    function sphreadheader(filename::AbstractString)
        open(filename, "r") do io
            sphreadheader(io)
        end
    end

    function get_wav_format(header)
        fmt = get(header, "sample_coding", "pcm")
        cc = get(
            Dict(
                "ulaw" => WAV.WAVE_FORMAT_MULAW,
                "alaw" => WAV.WAVE_FORMAT_ALAW
            ),
            fmt,
            WAV.WAVE_FORMAT_PCM
        )
        fs = header["sample_rate"]
        nchan = header["channel_count"]
        nb = header["sample_n_bytes"] * 8
        ba = header["sample_n_bytes"] * nchan
        bps = fs * ba
        ext = WAV.WAVFormatExtension()
        return WAV.WAVFormat(cc, nchan, fs, bps, ba, nb, ext)
    end

    function sphread(io::IO; subrange=(:), format="double")
        header, header_len = sphreadheader(io)
        seekstart(io)
        data = read(io)[(header_len + 1):end]
        buf = IOBuffer(data)
        fmt = get_wav_format(header)
        # use the internal WAV functions for doing ulaw and alaw
        samples = WAV.read_data(buf, length(data), fmt, format, subrange)
        return header, samples
    end

    function sphread(filename::AbstractString; subrange=(:), format="double")
        open(filename, "r") do io
            sphread(io; subrange=subrange, format=format)
        end
    end

    function sphwrite(header, samples, io::IO)
        header_len = 1024
        bytes_written = 0
        line = "NIST_1A\n"
        write(io, line)
        bytes_written += length(line)
        line = "   $header_len\n"
        write(io, line)
        bytes_written += length(line)
        for obj in keys(header)
            val = header[obj]
            s = ""
            T = typeof(val)
            if T <: Integer
                s = "$val"
                t = "-i"
            elseif T <: Real
                s = "$val"
                t = "-r"
            elseif T <: Bool
                s = uppercase("$val")
                t = "-s$(length(s))"
            else
                @assert T <: AbstractString
                s = val
                t = "-s$(length(s))"
            end
            line = string(join([obj, t, s], " "), "\n")
            write(io, line)
            bytes_written += length(line)
        end
        line = "end_head\n"
        write(io, line)
        bytes_written += length(line)
        write(io, repeat(" ", header_len - bytes_written))
        fmt = get_wav_format(header)
        WAV.write_data(io, fmt, samples)
    end

    function sphwrite(header, samples, filename::AbstractString)
        open(filename, "w") do io
            sphwrite(header, samples, io)
        end
    end

    function sph2wav(sph::IO, wav::IO)
        header, samples = sphread(sph)
        fmt = get_wav_format(header)
        WAV.wavwrite(samples, wav; Fs=fmt.sample_rate, nbits=fmt.nbits, compression=fmt.compression_code)
    end

    function sph2wav(sph_filename::AbstractString, wav_filename::AbstractString)
        open(sph_filename, "r") do sph
            open(wav_filename, "w") do wav
                sph2wav(sph, wav)
            end
        end
    end
end
