require 'rubygems'
require 'csv'
require 'json'

class HashtagSplitter

	attr_accessor :search_term

	def initialize(search_term)
    	@search_term = search_term
  	end

	def create_hashtag_csv
		tweets_file = ARGV.last
		CSV.open(tweets_file, 'ab') do |csv|
			file = CSV.read(tweets_file,:encoding => "iso-8859-1",:col_sep => ",")
				if file.none?
					csv << ["id_str", "from_user", "from_user_screen_name", "text", "retweet_text", "retweets", "created_at", "time", "geocoordinates", "user_lang", "in_reply_to_id_str", "in_reply_to_screen_name", "from_user_id_str", "source", "user_followers_count", "user_friends_count", "likes", "user_location", "status_url", "hashtags", "mentions", "urls"]
				end
				CSV.foreach(ARGV[1], headers:true) do |tweet|
					@tweet_hit = nil
					hashtag_check(tweet)
					#puts @tweet_hit
					if !@tweet_hit.nil?
						csv << @tweet_hit
					end	
				end			
		end
	end

	def hashtag_check(tweet)
		if !tweet['hashtags'].nil?
			puts tweet['hashtags']
			if tweet['hashtags'].include?(@search_term) 
				@tweet_hit = tweet
				return @tweet_hit
			end	
		end	
	end	


end	

query = HashtagSplitter.new(ARGV[0])
query.create_hashtag_csv