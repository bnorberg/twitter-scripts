require 'rubygems'
require 'jsonl'
require 'rubyXL'
require 'date'
require 'openssl'

class Twarc2Xlsx

	def initiate
		@load_files = Dir.glob("#{ARGV.first}/*.jsonl")
		workbook = RubyXL::Workbook.new
		puts workbook[0]
		create_elements_sheet(workbook)
		create_connections_sheet(workbook)
		workbook.write("/Users/brn5/#{ARGV.last}_network.xlsx")
	end	

	def create_elements_sheet(workbook)
		elements = workbook[0]
		elements.sheet_name = 'Elements'
		elements.add_cell(0, 0, 'label')
		elements.add_cell(0, 1, 'name')
		elements.add_cell(0, 2, 'link')
		elements.add_cell(0, 3, 'user_type')
		elements.add_cell(0, 4, 'description')
		elements.add_cell(0, 5, 'image')
		elements.add_cell(0, 6, 'account_created_at')
		elements.add_cell(0, 7, 'language')
		elements.add_cell(0, 8, 'statuses_count')
		elements.add_cell(0, 9, 'friends_count')
		elements.add_cell(0, 10, 'followers_count')
		elements.add_cell(0, 11, 'list_count')
		elements.add_cell(0, 12, 'like_count')
		elements.add_cell(0, 13, 'user_location')
		elements.add_cell(0, 14, 'is_follower')
		@row = 0
		@element_names = {}
	  	@load_files.each do |file|
	  		get_type(file)
			json_file = File.read(file)
		  	tfs = JSONL.parse(json_file)
			tfs.each do |tf|
				puts @element_names.has_value?(tf['screen_name'])
				puts '============================='
				if @element_names.has_value?(tf['screen_name'])
					key = @element_names.select {|k,v| v == tf['screen_name']}.keys[0].to_i
					k = key + 1
					elements[k][14].change_contents("TRUE")
				else	
					@row+=1
					@element_names[@row] = tf['screen_name']
					puts @element_names
					puts '++++++++++++++++++++++++'
					get_user_type(tf['name'], tf['description'])
					puts @row
					puts tf
					puts "------------"
					elements.add_cell(@row, 0, tf['screen_name'])
					elements.add_cell(@row, 1,  tf['name'])
					elements.add_cell(@row, 2, "https://twitter.com/#{tf['screen_name']}")
					elements.add_cell(@row, 3, @user_type)
					elements.add_cell(@row, 4, tf['description'])
					elements.add_cell(@row, 5, tf['profile_banner_url'])
					elements.add_cell(@row, 6, change_dateformat(tf['created_at']))
					elements.add_cell(@row, 7, tf['lang'])
					elements.add_cell(@row, 8, tf['statuses_count'])
					elements.add_cell(@row, 9, tf['friends_count'])
					elements.add_cell(@row, 10, tf['followers_count'])
					elements.add_cell(@row, 11, tf['listed_count'])
					elements.add_cell(@row, 12, tf['favourites_count'])
					elements.add_cell(@row, 13, tf['location'])
					elements.add_cell(@row, 14, "FALSE")
				end	
			end	
		end
	end

	def create_connections_sheet(workbook)
		connections = workbook.add_worksheet('Connections')
		connections.add_cell(0, 0, 'from')
		connections.add_cell(0, 1, 'to')
		connections.add_cell(0, 2, 'type')
		@c_row = 0
		@connection_names = []
	  	@load_files.each do |file|
	  		get_type(file)
			json_file = File.read(file)
		  	tfs = JSONL.parse(json_file)
			tfs.each do |tf|
				if tf['screen_name'] != ARGV.last
					if !@connection_names.any? { |cname|  tf['screen_name'].include?(cname) }
						@connection_names << tf['screen_name']
						@c_row +=1
						puts @c_row 
						puts tf
						puts "------------"
						connections.add_cell(@c_row, 0, ARGV.last)
						connections.add_cell(@c_row, 1, tf['screen_name'])
						connections.add_cell(@c_row, 2, @type)
					end	
				end	
			end	
		end
	end

	def get_user_type(name, description)
		institute_ids = ["neighbors", "organization", "comunitarias", "committee", "cmte.", "non-profit", "network", "building", "district", "restaurant", "housing", "coalition", "movement", "centre", "center", "community", "communities", "comunidad", "residential", "business", "program", "publication", "collective", "assignment desk", "industrial", "our team", "initiative", "praxis", "alliance", "vodcast", "perspectives", "ground game", "councils", "guild", "project", "union", "campaign", "chapter", "news", "group", "distro", "voices", "working women", "volunteers", "podcast", "residents", "red scare", "campaigning", "democratic socialists", "antifascism", "artists", "defenders", "party", "urbanism", "radio", "visit us", "alliance", "bistro", "agency", "charter school", "abolish", "real estate board", "stance against", "lives", "guards", "platform", "journal", "commune", "festival", "repower", "grill", "defend", "vintage clothing", "independent media", "media industries", "southwark", "co.", "village", "fair", "formerly known", "guide", "company", "brigade", "est.", "established", "not 4 sale", "shop filled", "rebels", "pediatrics", "publishing house", "boyle heights", "tell your stories", "new and used books", "east los angeles", "magazine", "our mission", "mexitreat", "skin culture", "regroupant", "bosses", "a daily history", "partnership", "institute", "immigrant youth", "empire", "la eastside", "follow", "massacre"]
		person_ids = ["he/him", "he/they", "she/her", "she/they", "they/them", "I\\\'m", "I\\\'ll", "pronouns", "director", "member", "creator", "writer", "writr", "researcher", "organizer", "author", "correspondent", "reporter", "thinker", "chronicler", "founder", "teacher", "recovering academic", "editor", "collaborator", "filmmaker", "storyteller", "producer", "scholar", "curator", "coordinator", "maker", "owner", "investigating", "manager", "context", "enthusiast", "chair", "born", "educator", "zapotec/", "pleasure", "candidate", "kayari_art", "obsessed", "build power.", "afroindigenous", "strategist", "alum", "archivist", "historian", "supporter", "native", "student", "documentation", "matter", "techies!!", "professor", "thoughts", "photographer", "queer", "journaliste", "journalist", "college of design", "nomad", "interests", "cleric", "retweeter", "apocryphal", "syndicalism", "phd", "fella", "guided", "fan", "lover", "FreeDallas", "repecter", "homo", "researcher", "worker", "marxist", "major", "dogs", "booking/contact:", "gay", "head", "artist", "entrepreneur", "traveler", "foodie", "leader", "drummer", "vandal"]
		if institute_ids.any? { |word| name.downcase.include?(word)}
			if !name.downcase.match(/phil\s/) || !description.downcase.match(/^other/) || !description.downcase.match(/^teachers/) 
				@user_type = "institution"
			else
				@user_type = "person"
			end	
		elsif description.downcase.match(/^my/)
			if person_ids.any? { |pw| description.downcase.match(/#{pw}(\.|\s|\,|\]|\||\z)/) }
				@user_type = "person"
			else	
				@user_type = "institution"
			end	
		elsif description.downcase.match(/^archivist/) || description.downcase.match(/^history/)
			@user_type = "person"	
		elsif description.downcase.match(/^i\s/) || description.downcase.match(/\si\s/) || description.downcase.match(/\sme\s/) || description.downcase.match(/\smy\s/) || description.downcase.match(/\smine\s/)
			@user_type = "person"
		elsif institute_ids.any? { |iw| description.downcase.include?(iw)}
			if person_ids.any? { |pw| description.downcase.match(/#{pw}(\.|\s|\,|\]|\||\z)/) }
				@user_type = "person"
			else
				@user_type = "institution"
			end
		else
			@user_type = "person"	
		end		
		return @user_type
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

new_xlsx = Twarc2Xlsx.new
new_xlsx.initiate
