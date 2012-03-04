#!/usr/bin/env ruby

require "optparse"
require "csv"

#
# execute convert
#
def exec_convert(options, infname)

	if not File.exist?(infname) then
		print "file not exists\n"
		exit
	end

	if options.key?(:outfile) then
		outfname = options[:outfile]
	else
		outfname = File.basename(infname,".*") + ".plist"
	end

	if options[:delimiter] then
		inf = CSV.open(infname,"r","\t")
	else
		inf = CSV.open(infname,"r")
	end

	outf = open(outfname,"w")

	# header
	s = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<!DOCTYPE plist PUBLIC \"-//Apple//DTD PLIST 1.0//EN\" \"http://www.apple.com/DTDs/PropertyList-1.0.dtd\">\n<plist version=\"1.0\">\n<array>\n"
	outf.write(s)

	keynm = inf.shift

	if options[:datatype] then
		dataty = inf.shift
	end

	inf.each do |row|
		outf.write("\t<dict>\n")
		i=0
		while i < keynm.size
			outf.write("\t\t<key>" + keynm[i] + "</key>\n")
			if options[:datatype] then
				ty = dataty[i]
			else
				ty = "string"
			end
			outf.write("\t\t<" + ty + ">" + row[i] + "</" + ty + ">\n")

			i += 1
		end
		outf.write("\t</dict>\n")
	end

	# footer
	s = "</array>\n</plist>\n"
	outf.write(s)

	inf.close
	outf.close

	puts outfname
end


#
# main
#
usage = "Usage: make_plist.rb [options] csvfile"

options = {}
OptionParser.new do |opts|
	opts.banner = usage

	opts.on("-t", "there is a data type") do |t|
		options[:datatype] = t
	end

	opts.on("-d", "tab separated") do |dt|
		options[:delimiter] = dt
	end

	opts.on("-o [FILE]", "output to file") do |ofname|
		options[:outfile] = ofname
	end
end.parse!

if ARGV.size != 1 then
	puts usage
	exit
end

exec_convert(options, ARGV[0])

