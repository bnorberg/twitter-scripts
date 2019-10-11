require 'rubygems'
require 'jsonl'
require 'csv'
require 'geocoder'
require 'openssl'

class Twitter2Network

	def initiate
		Geocoder.configure(lookup: :google, api_key: 'add key', use_https: true, ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE)
		create_csv
	end	

	def create_csv
		output_file = ARGV[1]
		@load_files = Dir.glob("#{ARGV.first}/*.jsonl")
		CSV.open(output_file, 'ab') do |csv|
			begin
			  	file = CSV.read(output_file,:encoding => "iso-8859-1",:col_sep => ",")
				  	if file.none?
				    	csv << ["source", "user_id", "username", "screen_name", "user_url", "user_location", "location_coordinates", "account_created_at", "language", "statuses_count", "friends_count", "followers_count", "list_count", "like_count", "kind"]
				  	end
				  	@load_files.each do |file|
				  		get_type(file)
						json_file = File.read(file)
					  	tfs = JSONL.parse(json_file)
		  				tfs.each do |tf|
							puts tf
							puts "------------"
		  					csv << [ARGV.last, tf['id'], tf['name'], tf['screen_name'], "https://twitter.com/#{tf['screen_name']}", tf['location'], get_location(tf['location']), change_dateformat(tf['created_at']), tf['lang'], tf['statuses_count'], tf['friends_count'], tf['followers_count'], tf['listed_count'], tf['favourites_count'], @type]
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

	def get_location(place)
		if !place.nil?
			sleep(1.5)
			location = Geocoder.search(place)
			#puts location.inspect
			if !location.empty?
				location = location.first.geometry['location']
				@coordinates = "#{location['lat']}, #{location['lng']}"
			else
				@coordinates = nil	
			end
		else	
			@coordinates = nil
		end
		return @coordinates	
	end	

end

new_list = Twitter2Network.new
new_list.initiate
