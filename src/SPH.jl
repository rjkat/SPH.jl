
module SPH
    export sphread, sphwrite

    # isip.piconepress.com/projects/speech/software/tutorials/production/fundamentals/v1.0/section_02/text/nist_sphere.text
    function read_header(io::IO)
        sph = Array{UInt8}(16)
        read!(io, sph)
        version = sph[1:8]
        header_len = parse(Int, String(sph[9:16]))
        h = Array{UInt8}(header_len - 16)
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

    function sphread(io::IO)
        header, header_len = read_header(io)
        data = take!(io)[(header_len + 1):end]
        return header, data
    end

    function sphread(filename::AbstractString)
        open(filename, "r") do io
            sphread(io)
        end
    end

    function sphwrite(header, data, io::IO)
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
            if T <: Real
                s = "$val"
                t = "-r"
            elseif T <: Bool
                s = uppercase("$val")
                t = "-s$(length(s))"
            elseif T <: Integer
                s = String(val)
                t = "-i"
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
        write(io, data)
    end

    function sphwrite(header, data, filename::AbstractString)
        open(filename, "w") do io
            sphwrite(header, data, io)
        end
    end
end