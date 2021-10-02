using Statistics
using TimeZones

testfile = joinpath(dir, "Example_Drive01.d7d")

f = DWDataReader.File(testfile)
@test string(f) == "DWDataReader.File(\"$(testfile)\"): 20 channels\n"
@test DWDataReader.getname(f.channels[1]) == "GPSvel"
@test f.channels[1].name == "GPSvel"
@test f.nchannels == 20

g = DWDataReader.File(testfile)
@test f.readerid != g.readerid

@test size(DWDataReader.scaled(f.channels[1]))[1] == 9580
@test size(DWDataReader.scaled(f.channels[1]))[2] == 2

@test size(DWDataReader.scaled(g.channels[1]))[1] == 9580
@test size(DWDataReader.scaled(g.channels[1]))[2] == 2

@test size(DWDataReader.scaled(f[:ENG_RPM]))[1] == 4791

c = DWDataReader.scaled(f[:ENG_RPM])
@test abs(mean(c[5.0 .<= c[:, 1] .<= 5.5, :][:, 2]) - 3098.5) < 1

@test f.info.start_store_time == ZonedDateTime(DateTime("2003-10-09T21:27:46.812"), tz"UTC")
@test f.info.sample_rate == 100.0
@test f.info.duration == 95.8
@test string(f.info) == "2003-10-09T21:27:46.812+00:00 100.0 Hz 95.8 s\n"
