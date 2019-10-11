require 'rubygems'
require 'csv'
require 'geocoder'
require 'openssl'

class Twitter2MapLocal

	def create_arrays_files
		@embodied_actions = [ "celebration", "mobilizing", "protest", "direct action", "boycott", "property damage", "occupation", "street action", "obstruction", "art intervention", "negotiation"]
		@communication_practices = ["humor", "surveilling", "fundraising", "art intervetion", "sharing news", "everyday life", "political expression", "solidarity"]
		@legislative_actions = ["legislation", "legal", "rent strike"]
		@art = ["art", "artwashing"]
		@housing = ["housing", "development", "obama presidential center"]
		@government_forces = ["policing\/ICE", "policing", "white supremacy", "transportation", "patriarchy", "imperialism", "government"]
		@business = ["business", "tech", "brand"]
		@entertainment = ["film & tv", "tourism"]
		@embodied_file = "/Users/brn5/embodied_actions_la.csv"
		@communication_file = "/Users/brn5/communication_practices_la.csv"
		@legislative_file = "/Users/brn5/legislative_actions_la.csv"
		@art_file = "/Users/brn5/art_la.csv"
		@housing_file = "/Users/brn5/housing_la.csv"
		@government_file = "/Users/brn5/government_la.csv"
		@business_file = "/Users/brn5/business_la.csv"
		@entertainment_file = "/Users/brn5/entertainment_la.csv"
		@community_file = "/Users/brn5/community_la.csv"
		@other_file = "/Users/brn5/other_la.csv"
		parse_csv
	end

	def parse_csv
		CSV.foreach(ARGV.first, headers:true) do |line|
			puts line['action']
			begin
				if @embodied_actions.any? { |ea| line['action'].downcase.include?(ea)}
					category = "embodied action"
					create_embodied(line, category)
				end	
				if @communication_practices.any? { |cp| line['action'].downcase.include?(cp)}
					category = "communication pratice"
					create_communication(line, category)
				end	
				if @legislative_actions.any? { |la| line['action'].downcase.include?(la)}
					category = "legislative action"
					create_legislative(line, category)	
				end	
				if @art.any? { |art| line['theme'].downcase.include?(art)}
					category = "art"
					create_art(line, category)
				end	
				if @housing.any? { |house| line['theme'].downcase.include?(house)}
					category = "housing"
					create_housing(line, category)
				end	
				if @government_forces.any? { |gf| line['theme'].downcase.include?(gf)}
					category = "goverment_forces"
					create_government(line, category)
				end	
				if @business.any? { |bu| line['theme'].downcase.include?(bu)}
					category = "business"
					create_business(line, category)
				end	
				if @entertainment.any? { |en| line['theme'].downcase.include?(en)}	
					category = "entertainment"
					create_entertainment(line, category)
				end	
				if line['theme'] == "community building"	
					category = "community building"
					create_community(line, category)
				end	
				if line['theme'] == "other"
					category = "other"
					create_other(line, category)
				end
			rescue Exception => e
				puts "Error #{e} #{line['id']}"
				next	
			end	
		end	
	end


	def create_embodied(line, category)
		if line['steet_level_info'] == "TRUE" && line['location'].downcase.include?("los angeles") || line['location'].downcase.include?("boyle heights") || line['location'].downcase.include?("east la")
			CSV.open(@embodied_file, 'ab') do |csv|
				begin
					new_file = CSV.read(@embodied_file,:encoding => "iso-8859-1",:col_sep => ",")
				  	if new_file.none?
				    	csv << ["created_at", "action", "action_category", "theme", "theme_category", "location", "location_latitute", "location_longitude", "tweet_type", "image"]
				  	end
					csv << [line['created_at'], line['action'], category, line['theme'], get_theme_category(line['theme']), line['location'], line['location_latitute'], line['location_longitude'], line['tweet_type'], get_image(line['location_latitute'], line['location_longitude'], line['id'], line['location'])]
				rescue Exception => e
		  			puts "Error #{e}"
		  			next
		  		end	
			end
		end	
	end	

	def create_communication(line, category)
		if line['steet_level_info'] == "TRUE" && line['location'].downcase.include?("los angeles") || line['location'].downcase.include?("boyle heights") || line['location'].downcase.include?("east la")
			CSV.open(@communication_file, 'ab') do |csv|
				begin
					new_file = CSV.read(@communication_file, :encoding => "iso-8859-1",:col_sep => ",")
				  	if new_file.none?
				    	csv << ["created_at", "action", "action_category", "theme", "theme_category", "location", "location_latitute", "location_longitude", "tweet_type", "image"]
				  	end
					csv << [line['created_at'], line['action'], category, line['theme'], get_theme_category(line['theme']), line['location'], line['location_latitute'], line['location_longitude'], line['tweet_type'], get_image(line['location_latitute'], line['location_longitude'], line['id'], line['location'])]
				rescue Exception => e
		  			puts "Error #{e}"
		  			next
		  		end	
			end
		end	
	end	

	def create_legislative(line, category)
		if line['steet_level_info'] == "TRUE" && line['location'].downcase.include?("los angeles") || line['location'].downcase.include?("boyle heights") || line['location'].downcase.include?("east la")
			CSV.open(@legislative_file, 'ab') do |csv|
				begin
					new_file = CSV.read(@legislative_file,:encoding => "iso-8859-1",:col_sep => ",")
				  	if new_file.none?
				    	csv << ["created_at", "action", "action_category", "theme", "theme_category", "location", "location_latitute", "location_longitude", "tweet_type", "image"]
				  	end
					csv << [line['created_at'], line['action'], category, line['theme'], get_theme_category(line['theme']), line['location'], line['location_latitute'], line['location_longitude'], line['tweet_type'], get_image(line['location_latitute'], line['location_longitude'], line['id'], line['location'])]
				rescue Exception => e
		  			puts "Error #{e}"
		  			next
		  		end	
			end
		end	
	end	

	def create_art(line, category)
		if line['steet_level_info'] == "TRUE" && line['location'].downcase.include?("los angeles") || line['location'].downcase.include?("boyle heights") || line['location'].downcase.include?("east la")
			CSV.open(@art_file, 'ab') do |csv|
				begin
					new_file = CSV.read(@art_file,:encoding => "iso-8859-1",:col_sep => ",")
				  	if new_file.none?
				    	csv << ["created_at", "action", "action_category", "theme", "theme_category", "location", "location_latitute", "location_longitude", "tweet_type", "image"]
				  	end
					csv << [line['created_at'], line['action'], get_action_category(line['action']), line['theme'], category, line['location'], line['location_latitute'], line['location_longitude'], line['tweet_type'], get_image(line['location_latitute'], line['location_longitude'], line['id'], line['location'])]
				rescue Exception => e
		  			puts "Error #{e}"
		  			next
		  		end	
			end
		end	
	end

	def create_housing(line, category)
		if line['steet_level_info'] == "TRUE" && line['location'].downcase.include?("los angeles") || line['location'].downcase.include?("boyle heights") || line['location'].downcase.include?("east la")
			CSV.open(@housing_file, 'ab') do |csv|
				begin
					new_file = CSV.read(@housing_file,:encoding => "iso-8859-1",:col_sep => ",")
				  	if new_file.none?
				    	csv << ["created_at", "action", "action_category", "theme", "theme_category", "location", "location_latitute", "location_longitude", "tweet_type", "image"]
				  	end
					csv << [line['created_at'], line['action'], get_action_category(line['action']), line['theme'], category, line['location'], line['location_latitute'], line['location_longitude'], line['tweet_type'], get_image(line['location_latitute'], line['location_longitude'], line['id'], line['location'])]
				rescue Exception => e
		  			puts "Error #{e}"
		  			next
		  		end	
			end
		end	
	end

	def create_government(line, category)
		if line['steet_level_info'] == "TRUE" && line['location'].downcase.include?("los angeles") || line['location'].downcase.include?("boyle heights") || line['location'].downcase.include?("east la")
			CSV.open(@government_file, 'ab') do |csv|
				begin
					new_file = CSV.read(@government_file,:encoding => "iso-8859-1",:col_sep => ",")
				  	if new_file.none?
				    	csv << ["created_at", "action", "action_category", "theme", "theme_category", "location", "location_latitute", "location_longitude", "tweet_type", "image"]
				  	end
					csv << [line['created_at'], line['action'], get_action_category(line['action']), line['theme'], category, line['location'], line['location_latitute'], line['location_longitude'], line['tweet_type'], get_image(line['location_latitute'], line['location_longitude'], line['id'], line['location'])]
				rescue Exception => e
		  			puts "Error #{e}"
		  			next
		  		end	
			end
		end	
	end

	def create_business(line, category)
		if line['steet_level_info'] == "TRUE" && line['location'].downcase.include?("los angeles") || line['location'].downcase.include?("boyle heights") || line['location'].downcase.include?("east la")
			CSV.open(@business_file, 'ab') do |csv|
				begin
					new_file = CSV.read(@business_file,:encoding => "iso-8859-1",:col_sep => ",")
				  	if new_file.none?
				    	csv << ["created_at", "action", "action_category", "theme", "theme_category", "location", "location_latitute", "location_longitude", "tweet_type", "image"]
				  	end
					csv << [line['created_at'], line['action'], get_action_category(line['action']), line['theme'], category, line['location'], line['location_latitute'], line['location_longitude'], line['tweet_type'], get_image(line['location_latitute'], line['location_longitude'], line['id'], line['location'])]
				rescue Exception => e
		  			puts "Error #{e}"
		  			next
		  		end	
			end
		end	
	end

	def create_entertainment(line, category)
		if line['steet_level_info'] == "TRUE" && line['location'].downcase.include?("los angeles") || line['location'].downcase.include?("boyle heights") || line['location'].downcase.include?("east la")
			CSV.open(@entertainment_file, 'ab') do |csv|
				begin
					new_file = CSV.read(@entertainment_file,:encoding => "iso-8859-1",:col_sep => ",")
				  	if new_file.none?
				    	csv << ["created_at", "action", "action_category", "theme", "theme_category", "location", "location_latitute", "location_longitude", "tweet_type", "image"]
				  	end
					csv << [line['created_at'], line['action'], get_action_category(line['action']), line['theme'], category, line['location'], line['location_latitute'], line['location_longitude'], line['tweet_type'], get_image(line['location_latitute'], line['location_longitude'], line['id'], line['location'])]
				rescue Exception => e
		  			puts "Error #{e}"
		  			next
		  		end	
			end
		end	
	end

	def create_community(line, category)
		if line['steet_level_info'] == "TRUE" && line['location'].downcase.include?("los angeles") || line['location'].downcase.include?("boyle heights") || line['location'].downcase.include?("east la")
			CSV.open(@community_file, 'ab') do |csv|
				begin
					new_file = CSV.read(@community_file,:encoding => "iso-8859-1",:col_sep => ",")
				  	if new_file.none?
				    	csv << ["created_at", "action", "action_category", "theme", "theme_category", "location", "location_latitute", "location_longitude", "tweet_type", "image"]
				  	end
					csv << [line['created_at'], line['action'], get_action_category(line['action']), line['theme'], category, line['location'], line['location_latitute'], line['location_longitude'], line['tweet_type'], get_image(line['location_latitute'], line['location_longitude'], line['id'], line['location'])]
				rescue Exception => e
		  			puts "Error #{e}"
		  			next
		  		end	
			end
		end	
	end

	def create_other(line, category)
		if line['steet_level_info'] == "TRUE" && line['location'].downcase.include?("los angeles") || line['location'].downcase.include?("boyle heights") || line['location'].downcase.include?("east la")
			CSV.open(@other_file, 'ab') do |csv|
				begin
					new_file = CSV.read(@other_file,:encoding => "iso-8859-1",:col_sep => ",")
				  	if new_file.none?
				    	csv << ["created_at", "action", "action_category", "theme", "theme_category", "location", "location_latitute", "location_longitude", "tweet_type", "image"]
				  	end
					csv << [line['created_at'], line['action'], get_action_category(line['action']), line['theme'], category, line['location'], line['location_latitute'], line['location_longitude'], line['tweet_type'], get_image(line['location_latitute'], line['location_longitude'], line['id'], line['location'])]
				rescue Exception => e
		  			puts "Error #{e}"
		  			next
		  		end	
			end
		end	
	end

	def get_action_category(action)
		@action_categories = []
		if @embodied_actions.any? { |ea| action.downcase.include?(ea)}
			@action_categories << "embodied action"
		end	
		if @communication_practices.any? { |cp| action.downcase.include?(cp)}
			@action_categories << "communication pratice"
		end	
		if @legislative_actions.any? { |la| action.downcase.include?(la)}
			@action_categories <<"legislative action"
		end
		action_categories = @action_categories.join(', ')
		return action_categories
	end

	def get_theme_category(theme)
		@theme_categories = []
		if @art.any? { |art| theme.downcase.include?(art)}
			@theme_categories << "art"
		end	
		if @housing.any? { |house| theme.downcase.include?(house)}
			@theme_categories << "housing"
		end	
		if @government_forces.any? { |gf| theme.downcase.include?(gf)}
			@theme_categories << "goverment_forces"
		end	
		if @business.any? { |bu| theme.downcase.include?(bu)}
			@theme_categories << "business"
		end	
		if @entertainment.any? { |en| theme.downcase.include?(en)}
			@theme_categories << "entertainment"
		end	
		if theme == "community building"	
			@theme_categories << "community building"
		end	
		if theme == "other"
			@theme_categories << "other"
		end
		theme_categories = @theme_categories.join(', ')
		return theme_categories
	end

	def get_image(lat, long, id, location)
		#key = 'AIzaSyDxpCjLlAZjTFfV_4SK8gBSHYj-JzRj7GU'
		#image_url = "https://maps.googleapis.com/maps/api/streetview?location=#{lat},#{long}&size=256x256&key=#{key}"
		#puts image_url
		#puts '++++++++++++++++++++++++++++'
		filebase = "#{id}_#{location.gsub(' ', '_')}.jpg"
		filename = "/Users/brn5/tweet_images/#{filebase}"
		#File.open(filename,'wb') do |fo|
		#	fo.write open(image_url, {ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE}).read
		#end	
		send_to_flickr(filebase, filename, location)
		#send_to_dropbox(filebase, filename)
	end	

	def send_to_flickr(filebase, filename, location)
		FlickRaw.api_key="add key"
		FlickRaw.shared_secret="add secret"
		flickr.access_token = "add token"
		flickr.access_secret = "add secret"
		if @uploads.has_key?(filebase)
			value = @uploads.select {|k,v| k == filebase}.values[0]
			info = flickr.photos.getInfo(:photo_id => value)
			share_url = FlickRaw.url_n(info)
		else
			upload = flickr.upload_photo filename, :title => filebase, :description => "Google street api image of #{location}"
			@uploads[filebase] = upload
			info = flickr.photos.getInfo(:photo_id => upload)
			share_url = FlickRaw.url_n(info)	
		end
		return share_url	
	end	

	#def send_to_dropbox(filebase, filename)
	#	client = DropboxApi::Client.new("add key")
	#	upload = client.upload("/google_street_images/#{filebase}",filename)
	#	share = client.create_shared_link_with_settings(upload.path_display, {:requested_visibility => "public"})
	#	return share.url
	#end	

end	  	

sorted_tweets = Twitter2MapLocal.new
sorted_tweets.create_arrays_files