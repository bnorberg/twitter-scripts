require 'rubygems'
require 'csv'
require 'whatlanguage'
require 'date'
#require 'stopwords'
#require 'bing_translator'

class Sfm2Tags
#put all csv into an array
	def merge_tweets
	   # @wl = WhatLanguage.new(:all) ##instantiate language checker
	   #@wl = BingTranslator.new('3ef76f91435b45d1a63088168299a800')
	   #@wl = BingTranslator.new('bkt53d528dit', 'iePS6BUfVQv7UHjaaqFR0MH3c6c5/0MOPnBFqL8C1Z0=')
  ##instantiate language checker
	   files = Dir.glob("#{ARGV.first}/*.csv")
	   if files.empty?
	   	files = Dir.glob(ARGV.first)
	   end	
	   puts files
	   puts '********************'
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
			    	csv << ["id_str", "from_user", "from_user_screen_name", "text", "created_at", "time", "geocoordinates", "user_lang", "in_reply_to_id_str", "in_reply_to_screen_name", "from_user_id_str", "source", "user_followers_count", "user_friends_count", "user_location", "status_url", "hashtags", "mentions", "urls"]
			  	end
				files.each do |file|
					CSV.foreach(file, headers:true) do |tweet|
						begin
							#langauge = tweet['tweet'].gsub(/http(:|s:)(\/\/|\/)[A-Za-z\S]+/, "").gsub(/http(s:|:)\u2026/, "").gsub(/(@|#)[a-zA-Z]*/, "").gsub(/^RT/, "").gsub(/[^0-9a-zA-Z ]/, "").strip
							#if !langauge.empty?						
								#if @wl.detect(langauge) == :en
							#	if @wl.process_text(langauge)[:english] >= 2
							#		puts @wl.process_text(langauge)[:english] >= 2
									puts tweet['tweet']
									puts '-----------------------'
									csv << [tweet['id'], tweet['username'], tweet['screen_name'], tweet['tweet'], tweet['created_at'], change_dateformat(tweet['created_at']), tweet['tweet_coordinates'], tweet['user_lang'], tweet['in_reply_to_id'], tweet['in_reply_to_screen_name'], tweet['user_id'], tweet['source'], tweet['user_followers_count'], tweet['user_friends_count'],tweet['user_location'], "http://twitter.com/#{tweet['screen_name']}/statuses/#{tweet['id']}", tweet['hashtags'], tweet['mentions'], tweet['urls']]
								#end
							#end		
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

	def change_dateformat(date)
		d = DateTime.parse(date)
		#new_date = d.strftime("%d/%m/%Y %T") ###for Tableau Desktop
		new_date = d.strftime("%m/%d/%Y %T") ###for Tableau Public
		return new_date
	end	
		
end

csv = Sfm2Tags.new
csv.merge_tweets
