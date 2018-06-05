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
    return header
end

function read_sph_file(io::IO)
    return read_header(io)
end

function read_sph_file(filename::AbstractString)
    open(filename, "r") do io
        read_sph_file(io)
    end
end
