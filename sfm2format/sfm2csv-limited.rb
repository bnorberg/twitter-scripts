require 'rubygems'
require 'zlib'
#require 'json'
require 'yajl'
require 'csv'
require 'sanitize'

class TweetFilterReaderLimited

### Loads files. After calling the scipt full path to directory where sfm filter files are stores, followed
### by full path, name, and extention to your desired output file (ie, /place/on/filesystem/tweets.csv)
	def readfiles
		@tweets = []
		@files = Dir.glob("#{ARGV.first}/*.gz")
		@files.each do |file|
			puts file
			open_gz(file)
		end
	end

	def open_gz(file)
		tweets_file = ARGV.last
		newfile =  File.new(file)
		if !File.zero?(newfile)
			#puts newfile.inspect
  			gz = Zlib::GzipReader.new(newfile)
  			puts '++++++++++++++++++++++++++++'
  			#puts gz.inspect
  			begin
	  			gz.each_line do |line|
	  				CSV.open(tweets_file, 'ab') do |csv|
		  				begin
						  	file = CSV.read(tweets_file,:encoding => "iso-8859-1",:col_sep => ",")
							  	if file.none?
							    	csv << ["id_str", "from_user", "from_user_screen_name", "text", "created_at", "time", "geocoordinates", "user_lang", "in_reply_to_id_str", "in_reply_to_screen_name", "from_user_id_str", "source", "user_followers_count", "user_friends_count", "user_location", "status_url", "hashtags", "mentions", "urls"]
							  	end
							  	parser = Yajl::Parser.new
							  	tweet = parser.parse(line)
				  				#tweet = JSON.parse(line)
				  				#get_location(tweet['user']['location'])
				  				#@user_location_lat, @user_location_long
				  				#"user_location_long", "user_location_lat"
				  				get_tweet_status(tweet['entities'])
				  				#get_quoted_status(tweet['quoted_status'])
				  				#get_retweet_status(tweet['retweeted_status'])
				  				get_coordinates(tweet['coordinates'])
				  				#get_place(tweet['place'])
				  				#puts tweet['user']['name']
				  				#puts "***********"
				  				csv << [tweet['id'], tweet['user']['name'], tweet['user']['screen_name'], tweet['text'], tweet['created_at'], change_dateformat(tweet['created_at']), @tweet_coordinates, tweet['user']['lang'], tweet['in_reply_to_user_id'], tweet['in_reply_to_screen_name'], tweet['user']['id'], Sanitize.fragment(tweet['source']), tweet['user']['followers_count'], tweet['user']['friends_count'], tweet['user']['location'], "http://twitter.com/#{tweet['screen_name']}/statuses/#{tweet['id']}", @tweet_hashtags, @tweet_mentions, @tweet_urls]
				  		rescue Exception => e
		     				puts "Error #{e}"
		     				next
				  		end
			  		end
	  			end
  			rescue Exception => e
  				puts "Error #{e}"
  			end
		else
			puts "file empty"
		end
		puts "------------"
	end

	def change_dateformat(date)
		d = DateTime.parse(date)
		#new_date = d.strftime("%d/%m/%Y %T") ###for Tableau Desktop
		new_date = d.strftime("%m/%d/%Y %T") ###for Tableau Public
		return new_date
	end	

	def get_coordinates(tweet)
		if !tweet.nil?
			@tweet_coordinates = tweet['coordinates'].to_s.gsub("[","").gsub("]","")
		else
			@tweet_coordinates = nil
		end
	end

	def get_place(tweet)
		if !tweet.nil?
			@tweet_placename = tweet['full_name']
			@tweet_place_country = tweet['country']
			@tweet_place_bounds = tweet['bounding_box']['coordinates'].to_s.gsub("[","").gsub("]","")
		else
			@tweet_placename = nil
			@tweet_place_country = nil
			@tweet_place_bounds = nil
		end
	end


	def get_tweet_status(tweet)
		@tweet_hashtags = get_hashtags(tweet['hashtags'])
		@tweet_mentions = get_mentions(tweet['user_mentions'])
		@tweet_media = get_media(tweet['media'])
		@tweet_urls = get_urls(tweet['urls'])
	end

	def get_quoted_status(tweet)
		if !tweet.nil?
			@quoted_date = tweet['created_at']
			@quoted_text = tweet['text']
			@quoted_from_id = tweet['user']['id']
			@quoted_from_name = tweet['user']['name']
			@quoted_from_location = tweet['user']['location']
			@quoted_followers = tweet['user']['followers_count']
			@quoted_friends = tweet['user']['friends_count']
			@quoted_retweet_count = tweet['retweet_count']
			@quoted_favorite_count = tweet['favorite_count']
		else
			@quoted_date = nil
			@quoted_text = nil
			@quoted_from_id = nil
			@quoted_from_name = nil
			@quoted_from_location = nil
			@quoted_followers = nil
			@quoted_friends = nil
			@quoted_retweet_count = nil
			@quoted_favorite_count = nil
		end
	end

	def get_retweet_status(tweet)
		if !tweet.nil?
			@retweeted_date = tweet['created_at']
			@retweeted_text = tweet['text']
			@retweeted_from_id = tweet['user']['id']
			@retweeted_from_name = tweet['user']['name']
			@retweeted_from_location = tweet['user']['location']
			@retweeted_followers = tweet['user']['followers_count']
			@retweeted_friends = tweet['user']['friends_count']
			@retweeted_retweet_count = tweet['retweet_count']
			@retweeted_favorite_count = tweet['favorite_count']
		else
			@retweeted_date = nil
			@retweeted_text = nil
			@retweeted_from_id = nil
			@retweeted_from_name = nil
			@retweeted_from_location = nil
			@retweeted_followers =nil
			@retweeted_friends = nil
			@retweeted_retweet_count = nil
			@retweeted_favorite_count = nil
		end
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
	end

	def get_media(media)
		if !media.nil?
			media_array = []
			media.each do |medium|
				media_array << medium['media_url']
			end
			@media = media_array.join(',')
		else
			@media = nil
		end
		return @media
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



end

sfm_files = TweetFilterReaderLimited.new
sfm_files.readfiles
