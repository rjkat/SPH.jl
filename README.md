# SPH.jl
Julia sphere file reader/writer. Shamelessly stolen from the excellent
[WAV.jl package](https://github.com/dancasimiro/WAV.jl) by [Dan Casimiro](https://github.com/dancasimiro).

sphreadheader
-------
```julia
function sphreadheader(io::IO)
function sphread(filename::AbstractString)
```

Return a ```Dict{String, Any}``` corresponding to the [Sphere header](isip.piconepress.com/projects/speech/software/tutorials/production/fundamentals/v1.0/section_02/text/nist_sphere.text) with Julian typing,

sphread
-------

This function reads the samples from a [NIST Sphere file](isip.piconepress.com/projects/speech/software/tutorials/production/fundamentals/v1.0/section_02/text/nist_sphere.text). The samples are converted to floating
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

* ``header``: The SPH header; A ```Dict{String, Any}``` corresponding to the [Sphere header](isip.piconepress.com/projects/speech/software/tutorials/production/fundamentals/v1.0/section_02/text/nist_sphere.text), with Julian typing
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