require 'rubygems'
require 'csv'
require 'whatlanguage'
require 'date'
#require 'stopwords'
#require 'bing_translator'

class TwitterMerger
#put all csv into an array
	def merge_tweets
	    @wl = WhatLanguage.new(:all) ##instantiate language checker
	   #@wl = BingTranslator.new('3ef76f91435b45d1a63088168299a800')
	   #@wl = BingTranslator.new('bkt53d528dit', 'iePS6BUfVQv7UHjaaqFR0MH3c6c5/0MOPnBFqL8C1Z0=')
  ##instantiate language checker
	   files = Dir.glob("#{ARGV.first}/*.csv")
	   #file = "#{ARGV.first}"
	   get_tweet_text(files)
	end

#get message for each tweet
	def get_tweet_text(files)
		#tweets_file = "#{ARGV.last}_merged.csv"
		tweets_file = ARGV.last
		CSV.open(tweets_file, 'ab') do |csv|
			begin
				new_file = CSV.read(tweets_file,:encoding => "iso-8859-1",:col_sep => ",")
			  	if new_file.none?
			    	csv << ["id", "created_at", "tweet", "source", "in_reply_to_id", "in_reply_to_screen_name", "user_id", "username", "screen_name", "user_location", "user_url", "user_description", "user_followers_count", "user_friends_count", "user_lists", "user_favorites_count", "user_tweet_count", "user_signup_date", "user_lang", "tweet_coordinates", "tweet_placename", "tweet_place_country", "tweet_place_bounds", "hashtags", "mentions", "urls", "media", "quoted_date", "quoted_text", "quoted_reply_id", "quoted_reply_name","quoted_from_id", "quoted_user_name", "quoted_user_location", "quoted_user_followers", "quoted_user_friends", "quoted_user_created_at", "quoted_user_lang", "quoted_tweet_coordinates", "quoted_tweet_placename", "quoted_tweet_country", "quoted_tweet_bounds", "quoted_tweet_retweet_count", "quoted_tweet_favorite_count", "quoted_tweet_hashtags", "quoted_tweet_mentions", "quoted_tweet_media", "retweeted_date", "retweeted_text", "retweeted_reply_id", "retweeted_reply_name","retweeted_from_id", "retweeted_user_name", "retweeted_user_location", "retweeted_user_followers", "retweeted_user_friends", "retweeted_user_created_at", "retweeted_user_lang", "retweeted_tweet_coordinates", "retweeted_tweet_placename", "retweeted_tweet_country", "retweeted_tweet_bounds", "retweeted_tweet_retweet_count", "retweeted_tweet_favorite_count", "retweeted_tweet_hashtags", "retweeted_tweet_mentions", "retweeted_tweet_media"]
			  	end
				files.each do |file|
					CSV.foreach(file, headers:true) do |tweet|
						begin
							langauge = tweet['tweet'].gsub(/http(:|s:)(\/\/|\/)[A-Za-z\S]+/, "").gsub(/http(s:|:)\u2026/, "").gsub(/(@|#)[a-zA-Z]*/, "").gsub(/^RT/, "").gsub(/[^0-9a-zA-Z ]/, "").strip
							if !langauge.empty?						
								#if @wl.detect(langauge) == :en
								if @wl.process_text(langauge)[:english] >= 2
									puts @wl.process_text(langauge)[:english] >= 2
									puts '-----------------------'
									csv << tweet
								end
							end		
						rescue Exception => e
	  						puts "Error #{e}"
	  						next	
						end	
					end	
				end
			rescue Exception => e
	  			puts "Error #{e}"
	  			next
	  		end	
  		end
	end
		
end

csv = TwitterMerger.new
csv.merge_tweets
