require 'rubygems'
require 'fileutils'

class SfmFilterRenamer

	def readfiles
		@path = ARGV.first
		base = @path.split("/").last
		rest = @path.split("/")[0..2].join("/")
		Dir.glob(@path + '*.gz') do |file|
			rename(file)
		end
		new_dir = "#{rest}/#{base}-#{@addbase}"
		FileUtils.mv @path, new_dir
	end

	def rename(file)
		filter_number = file.split("-", 3)[1].to_i
		name_mapper(filter_number, file)
		File.rename(file, @new_name)
	end

	def name_mapper(filter_number, file)
		puts filter_number
		if filter_number == 1
			@addbase = 'wwc2015'
		elsif filter_number == 2
			@addbase = 'cna'
		elsif filter_number == 3
			@addbase =  'charleston'
		elsif filter_number == 4
			@addbase =  'vra'
		elsif filter_number == 5
			@addbase =  'novemberattacks'
		elsif filter_number == 6
			@addbase = 'subnaturefood'
		elsif filter_number == 7
			@addbase = 'raleigh'
		elsif filter_number == 8
			@addbase = 'gentrification'
		elsif filter_number == 9
			@addbase = 'raleighshooting'
		elsif filter_number == 10
			@addbase = 'blacklivesmatter'
		elsif filter_number == 14
          @addbase = 'duke'
    elsif filter_number == 18
          @addbase = 'oldage'
		end
		 @new_name = @path + @addbase + '-' + file.split("-", 3)[2]
	end


end

files = SfmFilterRenamer.new
files.readfiles
