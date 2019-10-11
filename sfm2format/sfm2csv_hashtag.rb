require 'rubygems'
require 'csv'
require 'json'

class SfmQuery

	attr_accessor :search_term

	def initialize(search_term)
    	@search_term = search_term
  	end

	def create_filtered_sfm_csv
		tweets_file = ARGV.last
		CSV.open(tweets_file, 'ab') do |csv|
			file = CSV.read(tweets_file,:encoding => "iso-8859-1",:col_sep => ",")
				if file.none?
					csv << ["id", "created_at", "tweet", "source", "in_reply_to_id", "in_reply_to_screen_name", "user_id", "username", "screen_name", "user_location", "user_url", "user_description", "user_followers_count", "user_friends_count", "user_lists", "user_favorites_count", "user_tweet_count", "user_signup_date", "user_lang", "tweet_coordinates", "tweet_placename", "tweet_place_country", "tweet_place_bounds", "hashtags", "mentions", "urls", "media", "quoted_date", "quoted_text", "quoted_reply_id", "quoted_reply_name","quoted_from_id", "quoted_user_name", "quoted_user_location", "quoted_user_followers", "quoted_user_friends", "quoted_user_created_at", "quoted_user_lang", "quoted_tweet_coordinates", "quoted_tweet_placename", "quoted_tweet_country", "quoted_tweet_bounds", "quoted_tweet_retweet_count", "quoted_tweet_favorite_count", "quoted_tweet_hashtags", "quoted_tweet_mentions", "quoted_tweet_media", "retweeted_date", "retweeted_text", "retweeted_reply_id", "retweeted_reply_name","retweeted_from_id", "retweeted_user_name", "retweeted_user_location", "retweeted_user_followers", "retweeted_user_friends", "retweeted_user_created_at", "retweeted_user_lang", "retweeted_tweet_coordinates", "retweeted_tweet_placename", "retweeted_tweet_country", "retweeted_tweet_bounds", "retweeted_tweet_retweet_count", "retweeted_tweet_favorite_count", "retweeted_tweet_hashtags", "retweeted_tweet_mentions", "retweeted_tweet_media"]
				end
				CSV.foreach(ARGV[1], headers:true) do |tweet|
					@tweet_hit = nil
					hashtag_check(tweet)
					quoted_hashtag_check(tweet)
					retweeted_hashtag_check(tweet)
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
			if tweet['hashtags'].include?(@search_term) || tweet['hashtags'].include?(@search_term.downcase) || tweet['hashtags'].include?(@search_term.upcase) || tweet['hashtags'].include?(@search_term.capitalize) 
				@tweet_hit = tweet
				return @tweet_hit
			end	
		end	
	end	

	def quoted_hashtag_check(tweet)
		if !tweet['quoted_tweet_hashtags'].nil?
			if tweet['quoted_tweet_hashtags'].include?(@search_term) || tweet['quoted_tweet_hashtags'].include?(@search_term.downcase) || tweet['quoted_tweet_hashtags'].include?(@search_term.upcase) || tweet['quoted_tweet_hashtags'].include?(@search_term.capitalize)
				@tweet_hit = tweet
				return @tweet_hit
			end	
		end	
	end	

	def retweeted_hashtag_check(tweet)
		if !tweet['retweeted_tweet_hashtags'].nil?
			if tweet['retweeted_tweet_hashtags'].include?(@search_term) || tweet['retweeted_tweet_hashtags'].include?(@search_term.downcase) || tweet['retweeted_tweet_hashtags'].include?(@search_term.upcase) || tweet['retweeted_tweet_hashtags'].include?(@search_term.capitalize)
				@tweet_hit = tweet
				return @tweet_hit
			end	
		end	
	end	


end	

query = SfmQuery.new(ARGV[0])
query.create_filtered_sfm_csv