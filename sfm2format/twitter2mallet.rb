require 'rubygems'
require 'csv'
require 'whatlanguage'
#require 'stopwords'

class TwitterTopicModel
#put all csv into an array
	def collect_tweets
	   @wl = WhatLanguage.new(:all) ##instantiate language checker
	   @directory = "#{ARGV.first}/tweet_texts"
	   check_directory_exits(@directory)
	   puts @directory
	   files = Dir.glob("#{ARGV.first}/*.csv")
	   #puts files
	   #puts '=================='
	   get_tweet_text(files)
	end

	def check_directory_exits(directory)
		if !Dir.exists?(directory)
			Dir.mkdir(directory, 0755)
			puts "Made dir: #{directory}"
		end
	end

#get message for each tweet
	def get_tweet_text(files)
		files.each do |file|
			CSV.foreach(file, headers:true) do |tweet|
				#puts tweet
	   			#puts '+++++++++++++++'
				datetime = DateTime.parse(tweet['created_at'])
				date = datetime.strftime("%m-%d-%Y")
				time = datetime.strftime("%H-%M")
				title = "#{date}_#{time}_#{tweet['id']}"
				filename = "#{@directory}/#{title}.txt"
				puts filename
				if !File.file?(filename)
					if tweet['user_lang'] == 'en' || tweet['user_lang'] == 'en-gb' || tweet['user_lang'] == 'en-GB'
						if @wl.language(tweet['tweet'].gsub(/http(:|s:)(\/\/|\/)[A-Za-z\S]+/, "").gsub(/http(s:|:)\u2026/, "").delete("@#")) == :english
							create_txt_file(filename, tweet)
						end	
					end	
				end	
			end	
		end
	end
		
#check for uniqueness of tweet
	#create text file for each tweet and throw in directory
	def create_txt_file(filename, tweet)
		@txt_file = File.new(filename,"w")
		clean_tweet(tweet['tweet'], tweet['quoted_text'])
	end	


#remove urls, RT, and filter for words only
#vectorize tweet (remove punctuation, lowercase words)
	def clean_tweet(tweet, quote)
		filtered_tweet = tweet.gsub(/http(:|s:)(\/\/|\/)[A-Za-z\S]+/, "").gsub(/http(s:|:)\u2026/, "").gsub("/(&amp;|\u0026amp;)/", "and").gsub("&gt;", "").gsub("&lt;", "").gsub(/\b\u2026/, "ENDOFLINE").gsub(/\b[\d\w]*\.\.\./, "").gsub(/(#[\d\w]*|[\d\w]*)ENDOFLINE/, "").gsub(/^RT /,"").gsub(" b/c", " because").gsub("'m", " am").gsub("n't", " not").gsub("wo not", "will").gsub("'s", "").gsub("'ll", " will").gsub("'re", " are").gsub("'d", " would").gsub("'ve", " have").gsub(/[^A-Za-z_\d#@']/, " ").gsub("amp ", "and ").gsub(/\ss\s/, "").downcase.strip
		puts filtered_tweet
		puts '-----------------------------------'
		if !quote.nil?
			filter_quote = quote.gsub(/http(:|s:)(\/\/|\/)[A-Za-z\S]+/, "").gsub(/http(s:|:)\u2026/, "").gsub("/(&amp;|\u0026amp;)/", "and").gsub("&gt;", "").gsub("&lt;", "").gsub(/\b\u2026/, "ENDOFLINE").gsub(/\b[\d\w]*\.\.\./, "").gsub(/(#[\d\w]*|[\d\w]*)ENDOFLINE/, "").gsub(/^RT /,"").gsub(" b/c", " because").gsub("'m", " am").gsub("n't", " not").gsub("wo not", "will").gsub("'s", "").gsub("'ll", " will").gsub("'re", " are").gsub("'d", " would").gsub("'ve", " have").gsub(/[^A-Za-z_\d#@']/, " ").gsub("amp ", "and ").gsub(/\ss\s/, "").downcase.strip
			@txt_file.puts(filtered_tweet + ' ' + filter_quote)
		else
			@txt_file.puts(filtered_tweet)
		end	
	end

end

topics = TwitterTopicModel.new
topics.collect_tweets	
