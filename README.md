# Personize
	(c)2012 Patrick Morgan
	Freely licensed under the GPL v3.0

A name splitter and classifier.

Takes a stream containing single column of individual or company
names and outputs a pipe separated text stream containing the
following fields:

* Is Person 
* Prefix
* First Name
* Middle Name
* Last Name
* Suffix
* Full Name
* Source Name

*Usage:*

	cat data | ruby personize.rb 


*Requires Ruby 1.8.7+*
