require 'rubygems'
require 'zlib'
require 'jsonl'
#require 'yajl'
require 'csv'
require 'open-uri'
require 'sanitize'

class Twarc2Tableau

### Loads files. After calling the scipt full path to directory where sfm filter files are stores, followed
### by full path, name, and extention to your desired output file (ie, /place/on/filesystem/tweets.csv)
	def create_csv
		tweets_file = ARGV.last
		json_file = File.read(ARGV.first)
		CSV.open(tweets_file, 'ab') do |csv|
			begin
			  	file = CSV.read(tweets_file,:encoding => "iso-8859-1",:col_sep => ",")
				  	if file.none?
				    	csv << ["id_str", "from_user", "from_user_screen_name", "text", "retweeted_text", "retweets", "likes", "created_at", "time", "geocoordinates", "user_lang", "in_reply_to_id_str", "in_reply_to_screen_name", "from_user_id_str", "source", "status_url", "hashtags", "mentions", "urls", "media"]
				  	end
				  	#parser = Yajl::Parser.new
				  	#tweets = parser.parse(json_file)
				  	tweets = JSONL.parse(json_file)
	  				tweets.each do |tweet|
						puts tweet
						puts "------------"
	  					csv << [tweet['id'], tweet['user']['name'], tweet['user']['screen_name'], tweet['full_text'], get_retweet_text(tweet['retweeted_status']), tweet['retweet_count'], tweet['favorite_count'], tweet['created_at'], change_dateformat(tweet['created_at']), get_coordinates(tweet['coordinates']), tweet['user']['lang'], tweet['in_reply_to_user_id'], tweet['in_reply_to_screen_name'], tweet['id_str'], Sanitize.fragment(tweet['source']), "http://twitter.com#{tweet['screen_name']}/statuses/#{tweet['id']}", get_hashtags(tweet['entities']['hashtags']), get_mentions(tweet['entities']['user_mentions']), get_urls(tweet['entities']['urls']), get_media(tweet)]
	  				end	
	  		rescue Exception => e
 				puts "Error #{e}"
 				next
	  		end
		end
	end

	def change_dateformat(date)
		d = DateTime.parse(date)
		#new_date = d.strftime("%d/%m/%Y %T") ###for Tableau Desktop
		new_date = d.strftime("%m/%d/%Y %T") ###for Tableau Public
		return new_date
	end	

	def get_retweet_text(retweeted_status)
		if !retweeted_status.nil?
			puts retweeted_status
			puts '==================='
			retweeted_text = retweeted_status['full_text']
		else
			retweeted_text = nil	
		end
			return retweeted_text
	end			

	def get_coordinates(coordinates)
		if !coordinates.nil?
			tweet_coordinates = coordinates['coordinates'].to_s.gsub("[","").gsub("]","")
		else
			tweet_coordinates = nil
		end
		return tweet_coordinates
	end

	def get_hashtags(hashtags)
		if !hashtags.nil?
			hashtags_array = []
			hashtags.each do |ht|
				hashtags_array << ht['text']
			end
			@hashtags = hashtags_array.join(',')
		else
			@hashtags = nil
		end
		return @hashtags
	end

	def get_mentions(mentions)
		if !mentions.nil?
			mentions_array = []
			mentions.each do |mention|
				mentions_array << mention['name']
			end
			@mentions = mentions_array.join(',')
		else
			@mentions = nil
		end
		return @mentions
	end

	def get_urls(urls)
		if !urls.nil?
			url_array = []
			urls.each do |url|
				url_array << url['expanded_url']
			end
			@urls = url_array.join(',')
		else
			@urls = nil
		end
		return @urls
	end

	def get_media(tweet)
		if !tweet['entities']['media'].nil?
			@file_directory = "/Users/brn5/stein_project/#{tweet['id']}"
			check_directory_exits(@file_directory)
			@media_array = []
			tweet['entities']['media'].each do |m|
				@file_url = m['media_url_https']
				@filename = "#{@file_directory}/#{m['media_url_https'].split("/").last.split(":")[0]}"
				@media_array << @file_url
				download_image(@filename, @file_url)
			end
			if !tweet['extended_entities'].nil?
				tweet['extended_entities']['media'].each_with_index do |rm, index|
					if rm['media_url_https'].include?("video")
						if !rm['video_info'].nil?
							if rm['video_info']['variants'][0]['url'].include?(".mp4")
								@file_url = rm['video_info']['variants'][0]['url']
							else
								@file_url = rm['video_info']['variants'][1]['url']
							end		
							@media_array << @file_url
						end
						@filename = "#{@file_directory}/#{@file_url.split("/").last.split(":")[0]}"
						download_image(@filename, @file_url)
					else
						if index > 0
							@file_url = rm['media_url_https']
							@filename = "#{@file_directory}/#{@file_url.split("/").last.split(":")[0]}"
							@media_array << @file_url
							download_image(@filename, @file_url)
						end	
					end
				end	
			end		
			@media = @media_array.join(',')
		else
			@media = nil
		end
		return @media
	end

	def download_image(name, image)
		begin
			File.open(name,'wb') do |fo|
				fo.write open(image, {ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE}).read
			end	
		rescue Exception => e
 				puts "Error #{e}"
	  	end
	end

	def check_directory_exits(directory)
		if !Dir.exists?(directory)
			Dir.mkdir(directory, 0755)
			puts "Made dir: #{directory}"
		end
	end

end

new_tableau = Twarc2Tableau.new
new_tableau.create_csv
