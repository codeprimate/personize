class Personize

	COMPANY_FLAGS = [ "LLC", "TRUST", "INC", "BANK", "LP", "LC", "LTD", "ASSOC", "CORP", "CO", "PC", "CITY",
		"INVEST", "COMPANY", "PROPERTIES", "ETAL", "SERVICES", "CHURCH", "PARTNERSHIP", "HOME",
		"ESTATE", "BAPTIST", "OF", "SOLUTIONS", "DEVELOPMENT", "REVOCABLE", "FAMILY", "NATIONAL",
		"SOCIETY", "PARTNERS", "INTERNATIONAL", "MONTESSORI", "CREDIT", "HOLDINGS", "CHRISTIAN",
		"PARTNERS", "MEDICAL", "MGMT", "REMAX", "VENTURE", "HOSPITAL", "OIL", "SPECIALTY", "MANAGEMENT",
		"ACADEMY", "MINISTRIES", "ENTERPRISES", "PERSONAL", "LIMITED", "ENTERTAINMENT", "FUNERAL",
		"MISSIONARY", "FINANCIAL", "PROPERTY", "CENTRAL", "PRTNSHP", "MANAGMENT", "VACUUM",
		"EVANGELISTIC", "SCHOOL", "MORTGAGE", "ISD", "INTERESTS", "BOUTIQUE", "TR", "TRUSTEE", "USA",
		"BUILDING", "TECHNOLOGY", "MATTERS", "BROTHERS", "YACHTS", "SHOPPING", "BROS", "STATION",
		"INCORPORATED", "LIVING", "CONSTRUCTION", "CUSTODIANS", "[0-9]", "HOUSING", "APARTMENT",
		"OFFICES", "OFFICE", "GENERAL", "HOSP", "HOSPITALITY", "RETIREMENT", "VILLAGE", "LANDCO",
		"CONSTRUCTON", "CORPORATION", "INVESTMENTS", "LOFTS", "DANCE", "CENTER", "REVEREND",
		"FURNITURE", "MAINTENACE", "CHALLENGES", "COMMUNITY", "SERVICE", "ATTN", "ESTA", "CARDIOLOGY",
		"ET", "COMMERCIAL", "AUTOS", "ALLIANCE", "ASSN", "CUSTOM", "HOMES", "FIRST", "TOOL", "DISCIPLES",
		"EST", "IND", "CLUB", "INSTITUTE", "FOUNDATION", "ENVIRONMENTAL", "AUTHORITY", "STATES",
		"MORTUARY", "RESIDENT", "CONDOMINIUM", "THE", "OF", "PARTS", "GROUP", "TEMPLE", "SALVAGE",
		"METAL", "CITIBANK", "RESIDENTIAL", "L/P", "PARTNRSHP", "PROFESSIONAL", "TEXAS", "LEASING",
		"C/O" 
	]

	ABS_COMPANY_FLAGS = %w{INVESTMENTS CORPORATION ASSOCIATES ASSOCIATION AUTOMOTIVE LLP CARWASH RESUAURANT }

	GUESSERS = {
		:person => {
			:first_middle_last => [																					# Tested IN ORDER
				 [ /([a-z\.]+) ([a-z])\.? ([a-z\-\']{3,}),? (JR|SR|III|IV)/i,  :first_mi_last_suffix ],     #First MI Last Suffix
				 [ /([a-z\.]+) ([a-z]{2,}) ([a-z\-\']{3,}),? (JR|SR|III|IV)/i, :first_middle_last_suffix ], #First Middle Last Suffix
				 [ /([a-z\.]+) ([a-z]).? ([a-z\-\']{3,})/i,                    :first_mi_last],             #First MI Last
				 [ /([a-z])\.([a-z])\. ([a-z\-\']{3,})/i,                      :first_mi_last],             #FI.MI. Last
				 [ /([a-z\.]+) ([a-z]{2,}) ([a-z\-\']{3,})/i,                  :first_middle_last ],        #First Middle Last
				 [ /([a-z\.]+) ([a-z\-\']{3,}),? (JR|SR|III|IV)/i,             :first_last_suffix ],        #First Last Suffix
				 [ /([a-z\.]+) ([a-z\-\']{2,})/i,                              :first_last]                 #First Last

			] },
				:company => {
				:test => COMPANY_FLAGS.map{|r|
					Regexp.new("([^a-z]+| |^)#{r}([^a-z]+| |$)",true)	
				} + ABS_COMPANY_FLAGS.map{|r| Regexp.new(r, false)}
			}
	}

	def initialize
		@read_strategy = ARGF					# Must quack like IO
	end

	def go
		@read_strategy.each_line do |record|
			line = filter(record.chomp)
			out = []
			if is_company?(line)[0]
				# @out << [person    , prefix , first_name , middle , last_name , suffix, full_name , src]
				out  =  ['Company' , nil    , nil        , nil    , line      ,nil, line      , record]
			else
				if (matchdata = is_person?(line))[0]
					match = matchdata[0]
					#out = [person   , prefix   , first_name , middle   , last_name , suffix, full_name , src]
					case matchdata[1] 
						when :first_last
							out = ['Person' ,nil ,match[1] ,nil      ,match[2] ,nil      ,full_name(match) ,record]
						when :first_mi_last
							out = ['Person' ,nil ,match[1] ,match[2] ,match[3] ,nil      ,full_name(match) ,record]
						when :first_middle_last_suffix
							out = ['Person' ,nil ,nil      ,match[1] ,match[2] ,match[3] ,full_name(match) ,record]
						when :first_mi_last_suffix
							out = ['Person' ,nil ,match[1] ,match[2] ,match[3] ,match[4] ,full_name(match) ,record]
						when :first_last_suffix
							out = ['Person' ,nil ,match[1] ,nil      ,match[2] ,nil      ,full_name(match) ,record]
						when :first_middle_last
							out = ['Person' ,nil ,match[1] ,match[2] ,match[3] ,nil      ,full_name(match) ,record]
						else
							out = ['NoMatch'               ,'Person' ,nil ,nil      ,nil      ,line     ,line     ,record   				,record]
					end
				else
					#out = [person    , prefix , first_name , middle , last_name , full_name , src]
					out = ['Unknown' , nil    , nil        , nil    , line      , line      , record]
				end
			end
			puts out.join("|") unless out.empty?
		end
	end

	private

	def full_name(match)
		return match[1..(match.size - 1)].join(' ')
	end

	def filter(data)
		return (data||'').
			gsub(/\([a-z]+\)/,'').
			gsub(/[+()_]/i,'').
			gsub(/\*/,'').
			gsub('%','c/o ').
			gsub(/ +/,' ').
			gsub(/^&/,'').
			gsub(/&$/,'').
			gsub(/ INC\.?/i, ', INC').
			gsub(/ LTD/i, ', LTD').
			gsub(/ LLP/i, ', LLP').
			gsub(/L L C/i, 'LLC').
			gsub(/ LLC/i, ', LLC').
			gsub(/ LP/i, ', LP').
			gsub(/ ETAL/i,', ET AL').
			gsub(',,',','). 
			gsub(/  /,' ')
	end


	def is_person?(data)
		data && GUESSERS[:person][:first_middle_last].each_with_index do |x,index|
			match = nil
			(match = (data||'').match(x[0])) ? (return [ match, x[1] ] ) : false
		end
		return [false,nil]
	end

	def is_company?(data)
		data && GUESSERS[:company][:test].each_with_index do |x,index|
			match = nil
			(match = (data||'').match(x)) ? ( return [ match, index ] ) : false
		end
		return [false, nil]
	end

end

Personize.new.go
