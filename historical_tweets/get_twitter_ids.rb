require 'rubygems'
#require 'json'
require 'yajl'
require 'csv'
#require 'sanitize'

class TwitterScraperIds

### Loads files. After calling the scipt full path to directory where sfm filter files are stores, followed
### by full path, name, and extention to your desired output file (ie, /place/on/filesystem/tweets.csv)

	def get_ids
		tweets_file = ARGV.first
		file = File.read(tweets_file)
		parser = Yajl::Parser.new
		tweets = parser.parse(file)
		tweets.each do |tweet|
			puts tweet
			open(ARGV.last, 'a') { |f|
				f.puts "#{tweet['id']}\n"
			}	
		end
	end			



end

twitter_ids = TwitterScraperIds.new
twitter_ids.get_ids