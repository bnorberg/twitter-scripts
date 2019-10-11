require 'rubygems'
require 'jsonl'
require 'csv'
require 'date'
require 'openssl'

class Twarc2Kumu

	def initiate
		@load_files = Dir.glob("#{ARGV.first}/*.jsonl")
		create_elements_csv
		create_connections_csv
	end	

	def create_elements_csv
		element_file = ARGV[1]
		CSV.open(element_file, 'ab') do |csv|
			begin
			  	file = CSV.read(element_file,:encoding => "iso-8859-1",:col_sep => ",")
				  	if file.none?
				    	csv << ["label", "name", "link", "user_location", "description", "image", "account_created_at", "language", "statuses_count", "friends_count", "followers_count", "list_count", "like_count"]
				  	end
				  	@load_files.each do |file|
						json_file = File.read(file)
					  	tfs = JSONL.parse(json_file)
		  				tfs.each do |tf|
							puts tf
							puts "------------"
		  					csv << [ tf['screen_name'], tf['name'], "https://twitter.com/#{tf['screen_name']}", tf['location'], tf['description'], tf['profile_banner_url'], change_dateformat(tf['created_at']), tf['lang'], tf['statuses_count'], tf['friends_count'], tf['followers_count'], tf['listed_count'], tf['favourites_count']]
		  				end	
		  			end	
	  		rescue Exception => e
 				puts "Error #{e}"
 				next
	  		end
		end
	end

	def create_connections_csv
		connection_file = ARGV[2]
		CSV.open(connection_file, 'ab') do |csv|
			begin
			  	file = CSV.read(connection_file,:encoding => "iso-8859-1",:col_sep => ",")
				  	if file.none?
				    	csv << ["from", "to", "type"]
				  	end
				  	@load_files.each do |file|
				  		get_type(file)
						json_file = File.read(file)
					  	tfs = JSONL.parse(json_file)
		  				tfs.each do |tf|
							puts tf
							puts "------------"
							if tf['screen_name'] != ARGV.last
		  						csv << [ ARGV.last, tf['screen_name'], @type]
		  					end	
		  				end	
		  			end	
	  		rescue Exception => e
 				puts "Error #{e}"
 				next
	  		end
		end
	end

	def get_type(filename)
		if filename.include?("friend")
			@type = "friend"
		else
			@type = "follower"	
		end
		return @type	
	end	

	def change_dateformat(date)
		d = DateTime.parse(date)
		#new_date = d.strftime("%d/%m/%Y %T") ###for Tableau Desktop
		new_date = d.strftime("%m/%d/%Y %T") ###for Tableau Public
		return new_date
	end			

end

new_kumu = Twarc2Kumu.new
new_kumu.initiate
