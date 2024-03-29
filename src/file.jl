using Dates
using TimeZones
using CBinding

packagedir = joinpath(dirname(pathof(DWDataReader)), "..")
includedir = joinpath(packagedir, "src", "include")

# Fix shared library file permissions, see also:
# https://github.com/fleimgruber/DWDataReader.jl/issues/3
lib_dll = joinpath(dirname(pathof(DWDataReader)), "..", "DWDataReaderLib64.dll")
chmod(lib_dll, filemode(lib_dll) | 0o755)
lib_so = joinpath(dirname(pathof(DWDataReader)), "..", "DWDataReaderLib64.so")
chmod(lib_so, filemode(lib_so) | 0o755)

# CBinding.jl: Set up compiler context
c`-std=c99 -Wall -I$(includedir) -lDWDataReaderLib64 -L$(packagedir)`

c"""
#ifdef __MINGW64__
  #include <basetsd.h>
#endif
"""s

const c"__int64" = Int64
const c"int64_t" = Int64

# CBinding.jl: Create Julia types and bindings for DLL functions from header
c"""
  #include <DWDataReaderLib.h>
"""j;

struct FileInfo
    sample_rate::Float64
    start_store_time::ZonedDateTime
    duration::Float64
end

function Base.show(io::IO, fi::FileInfo)
    println(io, "$(fi.start_store_time) $(fi.sample_rate) Hz $(fi.duration) s")
end

"""
    DWDataReader.File(source; kwargs...) => DWDataReader.File

Read DEWESoft input data files (.d7d extension) and return a `DWDataReader.File` object.

"""
struct File
    name::String
    info::FileInfo
    nchannels::Int64
    channels::Cptr{DWChannel}
    closed::Bool
    delete::Bool
    readerid::Int8
    lookup::Dict{Symbol,DWChannel}
end

getname(f::File) = getfield(f, :name)
getnchannels(f::File) = getfield(f, :nchannels)

function Base.show(io::IO, f::File)
    println(io, "DWDataReader.File(\"$(getname(f))\"): $(getnchannels(f)) channels")
end

# Enables f[:channel] via internal lookup Dict
function Base.getproperty(f::File, ch::Symbol)
    lookup = getfield(f, :lookup)
    return haskey(lookup, ch) ? lookup[ch] : getfield(f, ch)
end

function Base.getindex(f::File, ch::Symbol)
    lookup = getfield(f, :lookup)
    return haskey(lookup, ch) ? lookup[ch] : getfield(f, ch)
end

# New File objects register via the global readers counter as per DLL requirements
global readers = 0
setreaders(r) = (global readers += r)

"""Deprecated in favor of direct DWChannel.name via `getproperty` mechanism"""
function getname(c::DWChannel)
    replace(String(c.name), r"\0+$" => s"")
end

# Property access for wrapped DWChannel with null-terminated string truncation
function Base.getproperty(c::DWChannel, v::Symbol)
    if v == :long_name
        max_len = Ref{Cint}(sizeof(Cint))
        ret_buff = Libc.malloc(Cint, 1)
        DWGetChannelProps(c.index, DW_CH_LONGNAME_LEN, ret_buff, max_len)
        max_len[] = ret_buff[]
        Libc.free(ret_buff)

        ret_buff = Libc.malloc(Cchar, max_len[])
        DWGetChannelProps(c.index, DW_CH_LONGNAME, ret_buff, max_len)
        raw_string = unsafe_string(ret_buff, max_len[])
        Libc.free(ret_buff)
    else
        raw_string = invoke(getproperty, Tuple{supertype(DWChannel),Symbol}, c, v)
    end
    return v in [:name :long_name] ? replace(String(raw_string), r"\0+$" => s"") :
           raw_string
end

function File(
    source;
    # options
    debug::Bool = false,
    kw...,
)
    isempty(source) && throw(ArgumentError("unable to read DW data from empty source"))
    name = source
    closed = true
    delete = false

    DWInit()

    # file Reader management
    readerid = DWDataReader.readers # DWInit creates the first readerid 0
    if readerid > 0 # Add reader only if this is not the first
        status = DWAddReader()
        status != 0 && throw(status)
    end

    DWDataReader.setreaders(1)

    # Check for matching number of readers
    num_readers = Ref{Cint}(0)
    status = DWGetNumReaders(num_readers)
    status != 0 && throw(status)
    num_readers[] != readers && throw("DWGetNumReaders=$(num_readers[]) != $(readers)")

    # Opening the file
    dwfileinfo = Ref(DWFileInfo())
    status = DWOpenDataFile(source, dwfileinfo)
    status != 0 && throw(status)
    closed = false
    fileinfo = FileInfo(
        dwfileinfo[].sample_rate,
        startstoretime(dwfileinfo[].start_store_time),
        dwfileinfo[].duration,
    )

    # How to make this the File AbstractVector{DWChannel} type?
    nchannels = DWGetChannelListCount()
    channels = Libc.malloc(DWChannel(), nchannels)
    DWGetChannelList(channels)

    lookup = Dict(Symbol(getname(channels[i])) => channels[i] for i = 1:nchannels)

    File(name, fileinfo, nchannels, channels, closed, delete, readerid, lookup)
end

"""Set this DWFile instance as the active reader"""
function activate(f::File, verifyopen::Bool = true)
    verifyopen && f.closed && error("I/O operation on closed file")
    status = DWSetActiveReader(f.readerid)
    status != 0 && throw(status)
end

function numberofsamples(ch::DWChannel)
    count = DWGetScaledSamplesCount(ch.index)
    count < 0 &&
        throw("DWGetScaledSamplesCount($(ch.index))=$(count) should be non-negative")
    count
end

"""Load and return full speed data as vector"""
function scaled(ch::DWChannel, arrayindex = 0)
    !(0 <= arrayindex < ch.array_size) && throw("arrayIndex is out of range")
    count = numberofsamples(ch)
    data = zeros(count * ch.array_size)
    time = zeros(count)
    status = DWGetScaledSamples(ch.index, Cint(0), count, data, time)
    status != 0 && throw(status)
    return [time data]
end

function startstoretime(time::Float64)
    epoch = DateTime(1899, 12, 30)
    epochutc = ZonedDateTime(epoch, tz"UTC")
    microseconds = time * 24 * 60 * 60 * 1000 * 1000
    epochutc + Dates.Microsecond(round(microseconds))
end
