#!/bin/bash

require 'rubygems'
require 'fastercsv'

class Personize

	COMPANY_FLAGS = %w(LLC TRUST INC BANK LP LC LTD ASSOC CORP CO INVEST COMPANY
										 PROPERTIES ETAL SERVICES CHURCH PARTNERSHIP HOME ESTATE
										 BAPTIST OF SOLUTIONS DEVELOPMENT REVOCABLE FAMILY NATIONAL
										 SOCIETY PARTNERS INTERNATIONAL MONTESSORI CREDIT HOLDINGS 
										 CHRISTIAN PARTNERS MEDICAL MGMT REMAX VENTURE HOSPITAL OIL SPECIALTY
										 MANAGEMENT ACADEMY MINISTRIES ENTERPRISES PERSONAL LIMITED
										 ENTERTAINMENT FUNERAL MISSIONARY FINANCIAL PROPERTY CENTRAL
										 PRTNSHP MANAGMENT VACUUM EVANGELISTIC SCHOOL MORTGAGE ISD
										 INTERESTS BOUTIQUE TR TRUSTEE USA BUILDING TECHNOLOGY MATTERS 
										 BROTHERS YACHTS SHOPPING BROS STATION INCORPORATED LIVING 
										 CONSTRUCTION CUSTODIANS [0-9] HOUSING APARTMENT OFFICES 
										 OFFICE GENERAL HOSP HOSPITALITY RETIREMENT VILLAGE LANDCO 
										 CONSTRUCTON CORPORATION INVESTMENTS LOFTS DANCE CENTER REVEREND
										 FURNITURE MAINTENACE CHALLENGES COMMUNITY SERVICE ATTN ESTA 
										 CARDIOLOGY ET COMMERCIAL AUTOS ALLIANCE ASSN CUSTOM HOMES 
										 FIRST TOOL DISCIPLES EST IND CLUB INSTITUTE FOUNDATION ENVIRONMENTAL
										 AUTHORITY STATES MORTUARY RESIDENT CONDOMINIUM THE OF PARTS GROUP TEMPLE
										 SALVAGE METAL CITIBANK RESIDENTIAL L/P PARTNRSHP PROFESSIONAL TEXAS LEASING C/O ) 

	ABS_COMPANY_FLAGS = %w{INVESTMENTS CORPORATION ASSOCIATES ASSOCIATION 
												 AUTOMOTIVE LLP CARWASH RESUAURANT }

	GUESSERS = {
		:person => {
			:first_middle_last => [																					# Tested IN ORDER
				/ ([a-z\.])  ([a-z]{3,})$/i, 																				 # First Last
				/ ([a-z\.]+) ([a-z])\.?      ([a-z]{3,})$/i,    										 # First MI Last
				/ ([a-z\.]+) ([a-z]{2,})     ([a-z]{3,})$/i,    										 # First Middle Last
				/ ([a-z\.]+) ([a-z]{3,}),?   (JR|SR|III|IV)$/i, 										 # First Last Suffix
				/ ([a-z\.]+) ([a-z])\.?      ([a-z]{3,}),?      (JR|SR|III|IV)$/i, 	 # First MI Last Suffix
				/ ([a-z\.]+) ([a-z]{2,})     ([a-z]{3,}),?      (JR|SR|III|IV)$/i    # First Middle Last Suffix

			] },
		:company => {
					:test => COMPANY_FLAGS.map{|r|
						Regexp.new("([^a-z]+| |^)#{r}([^a-z]+| |$)",true)	
					} + ABS_COMPANY_FLAGS.map{|r| Regexp.new(r, false)}
		}
	}

	def initialize
		@filename = ARGV[0]
		@data = []
		@out = []
		@read_strategy = ARGF  				# Must quack like IO 
	end

	def go
		@read_strategy.each_line do |record|
			line = filter(record)
			if is_company?(line)
				# @out << [prefix , first_name , middle , last_name , full_name , src]
				@out   << [nil    , nil        , nil    , line      , line      , record]
			else
				if (match = is_person?(line))
				else
					@out << [nil,nil,nil,line,line,record]
				end
			end
		end
	end

	def data_load
		print " * Loading #{@filename}..."
		@data = File.readlines(@filename)
		puts "Done."
	end

	def filter(data)
		return (data||'').
			gsub(/\([a-z]+\)/,'').
			gsub(/[+()._]/i,'').
			gsub(/\*/,'').
			gsub('%','c/o ').
			gsub(/ +/,' ').
			gsub(/^&/,'').
			gsub(/&$/,'')
			gsub(/ INC$/i, ', INC').
			gsub(/ LTD$/i, ', LTD').
			gsub(/ LLP$/i, ', LLP').
			gsub(/L L C$/i, 'LLC').
			gsub(/ LLC$/i, ', LLC').
			gsub(/ LP$/i, ', LP').
			gsub(/ ETAL$/i,', ET AL').
			gsub(',,',',')}
	end


	def is_person?(data)
		data && (not is_company?(data)) && GUESSERS[:person][:first_middle_last].any?{|x| (match = (data||'').match(x)) ? (return match) : false}
	end

	def is_company?(data)
		data && GUESSERS[:company][:test].any?{|x| (match = (data'').match(x)) ? (return match) : false}
	end

end
