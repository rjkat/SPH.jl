
# SPH.jl
Build status:
- julia v0.7 [![Build Status](https://travis-ci.org/rkat/SPH.jl.svg?branch=0.7)](https://travis-ci.org/rkat/SPH.jl)
- julia v1.0 [![Build Status](https://travis-ci.org/rkat/SPH.jl.svg?branch=master)](https://travis-ci.org/rkat/SPH.jl)

Julia sphere file reader/writer. Shamelessly stolen from the excellent
[WAV.jl package](https://github.com/dancasimiro/WAV.jl) by [Dan Casimiro](https://github.com/dancasimiro).

Installation
------------

    julia> Pkg.add("SPH")

Getting Started
---------------

SPH provides `sphread`, `sphwrite`, and `sph2wav` commands to read,
write, and convert SPH files. Here is an example to get you started.
It generates some data, writes it to a file and then reads the data back.
`sph2wav` is then used to convert the SPH file to a WAV file.
`sphreadheader` is also provided for reading an SPH header.

```jlcon
julia> using SPH
julia> header = Dict{String, Any}(
  "channel_count" => 1,
  "sample_coding" => "pcm",
  "sample_rate" => 8000,
  "sample_count" => 8000,
  "sample_byte_format" => "0123",
  "sample_n_bytes" => 4
)
julia> samples = sin.(2 * pi * [0:7999;] * 440.0 / 8000) * 0.01
julia> sphwrite(header, samples, "example.sph")
julia> header, x = sphread("example.sph")
julia> sph2wav("example.sph", "example.wav")
julia> h = sphreadheader("example.sph")
```

Note
---------------

`sphread` and `sphwrite` currently do not obey the `sample_byte_format` in the SPH header.
If this is an issue for you, let me know and I can add this functionality.

sphreadheader
-------
```julia
function sphreadheader(io::IO)
function sphread(filename::AbstractString)
```

Return a ```Dict{String, Any}``` corresponding to the [Sphere header](http://isip.piconepress.com/projects/speech/software/tutorials/production/fundamentals/v1.0/section_02/text/nist_sphere.text) with Julian typing. e.g.

```julia
Dict{String, Any}(
    "channel_count"      => 1,
    "sample_coding"      => "pcm",
    "sample_byte_format" => "01",
    "sample_rate"        => 8000,
    "sample_n_bytes"     => 4,
    "sample_count"       => 8000
)
```

sphread
-------

This function reads the samples from a [NIST Sphere file](http://isip.piconepress.com/projects/speech/software/tutorials/production/fundamentals/v1.0/section_02/text/nist_sphere.text). The samples are converted to floating
point values in the range from `-1.0` to `1.0` by default.

```julia
function sphread(io::IO; subrange=Any, format="double")
function sphread(filename::AbstractString; subrange=Any, format="double")
```

The available options, and the default values, are:

* ``format`` (default = ``double``): changes the format of the returned samples. The string
  ``double`` returns double precision floating point values in the range -1.0 to 1.0. The string
  ``native`` returns the values as encoded in the file. The string ``size`` returns the number
  of samples in the file, rather than the actual samples.
* ``subrange`` (default = ``Any``): controls which samples are returned. The default, ``Any``
  returns all of the samples. Passing a number (``Real``), ``N``, will return the first ``N``
  samples of each channel. Passing a range (``Range1{Real}``), ``R``, will return the samples
  in that range of each channel.

The returned values are:

* ``header``: The SPH header; same as returned by `sphreadheader`
* ``samples``: The acoustic samples; A matrix is returned for files that contain multiple channels.


sphwrite
--------

Writes samples to an SPH file.
Each column of the data represents a different
channel. Stereo files should contain two columns.

```julia
function sphwrite(header, samples, io::IO)
function sphwrite(header, samples, filename::AbstractString)
```
