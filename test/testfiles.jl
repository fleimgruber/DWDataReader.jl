using Statistics
using TimeZones

testfile = joinpath(dir, "Example_Drive01.d7d")

f = DWDataReader.File(testfile)
@test f.info.sample_rate == 100.0
@test DWDataReader.getname(f.channels[1]) == "GPSvel"
@test f.channels[1].name == "GPSvel"
@test f.nchannels == 20

g = DWDataReader.File(testfile)
@test f.readerid != g.readerid

@test size(DWDataReader.scaled(f.channels[1]))[1] == 9580
@test size(DWDataReader.scaled(f.channels[1]))[1] == 9580

@test size(DWDataReader.scaled(f[:ENG_RPM]))[1] == 4791

c = DWDataReader.scaled(f[:ENG_RPM])
@test abs(mean(c[5.0 .<= c[:, 1] .<= 5.5, :][:, 2]) - 3098.5) < 1

@test f.info.start_store_time == ZonedDateTime(DateTime("2003-10-09T21:27:46.812"), tz"UTC")
