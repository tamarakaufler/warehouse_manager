# warehouse_manager
GUI and API web applications for warehouse management

Two GUI implementations are provided:

	Catalyst based:                     wardrobe_manager_catalyst
	CGI (MVC, DBIx::Class, Template):   wardrobe_manager_cgi
    
RESTful web services:

	Catalyst based:                     wardrobe_manager_catalyst

REQUIREMENTS FOR GUI IMPLEMENTATION

	Search for clothes by name
	Display a list of clothes, their categories & which outfits they're in
	Upload a CSV file containing clothes and clothing categories in a specified format
	Tag clothes as part of an outfit

INSTRUCTIONS FOR SETTING UP THE CGI Wardrobe Manager APPLICATION

Tested on:

      Ubuntu 14.04
      Apache/2.4.7
      MySQL 5.5.38
      perl 5.18

1. MySQL

      mysql -u root -p < wardrobemanager.sql

2. Apache    
   
      Drop the wardrobe_manager directory into the cgi directory.
      Insert the following (change /var/www/wardrobe_manager/ as
      required) into the /etc/apache2/site-enabled/000-default:

      ScriptAlias /wardrobe_manager/ /var/www/wardrobe_manager/
      <Directory "/var/www/wardrobe_manager">
             AllowOverride None
             Options +ExecCGI -MultiViews +SymLinksIfOwnerMatch
             Order allow,deny
             Allow from all
     </Directory>

3. manager.cgi needs to be executable by all (or www-data user)

      chmod a+x manager.cgi

4. Required modules

    CGI       
    DBIx::Class       
    Template 
    Class:Accessor	    
    Text::CSV:Encoded

    Required modules for the Catalyst application:

    Catalyst 5.08


---------------------------------------------------------------------------

REQUIREMENTS FOR web services implementation

Provide a RESTful web service with equivalent functionality as the Wardrobe Management web application with GUI.

Web Services IMPLEMENTATION

The implemented Wardrobe Management API web service is a Catalyst application built in the following environment:

Ubuntu 14.04, x86_64
Perl v5.18.2
Catalyst 5.09
MySQ: 5.5

The application requires a couple of less usual Perl modules like:

    Catalyst::Controller::REST
    Lingua::EN::Inflect
    Text::CSV::Auto

Required modules are listed in Makefile.PL and will be installed by running 
    perl Makefile.PL

INSTALLATION

Codebase:

    From tarball:
        unpack the tarball: tar zxvf wardrobe_manager_api.tar.gz

    From github (if available):
        git clone git://github.com/tamarakaufler/wardrobe_manager_api.git

MySQL

    cd sql (on the same level as the README file)
    mysql -u root -p wardrobemanagerapi_user.sql
    mysql -u root -p wardrobemanagerapi.sql

    To import the provided test data, if desired:
        mysql -u root -p import_data.sql

DOCUMENTATION

    curl -X GET  http://localhost:3010/readme

    curl -X GET  http://localhost:3010/docs/clothing
    curl -X GET  http://localhost:3010/docs/category
    curl -X GET  http://localhost:3010/docs/outfit
    curl -X GET  http://localhost:3010/docs/clothing_outfit

PROVIDED FUNCTIONALITY

The application does not, currently, provide all the required functionality, and there is scope for improvement in what is provided.

1) CRud for clothing/category/outfit ... search (by id and name) and outfit (tagging) so far
2) Retrieval of a list of clothes, their categories and associated outfits
3) Tagging of clothes(clothing_outfit)
4) clothing and categories can be created by uploading a CSV or JSON file. Format of the JSON file can be a hash or an array of hashes.

DESIGN

I took advantage of the boilerplate code offered by Catalyst and its base RESTful controller. There are two RESTful controllers: Api and Tag,
and one library module with helper functions.

CRud implementation is done through DBIC introspection, so the same code can be used for all entity types (clothing/category etc).
Retrieval of the clothings list uses a convenience Result Clothing instance method. 

The application supports upload of CSV and JSON files (curl -F option) and json content type for curl -d/--data/-T options.  

API calls:

sample upload files are in sample_files dir on the same lever as the README file

1) CRud for clothing/category/outfit ... search (by id and name) and creation so far

GET:
	    curl -X GET  http://localhost:3010/api/clothing/id/3
	    curl -X GET  http://localhost:3010/api/clothing/outfit/3
	    curl -X GET  http://localhost:3010/api/clothing/name/iRun%20White%20Trainers
	    curl -X GET  http://localhost:3010/api/clothing/name/%Trainers    (fuzzy search)
	    curl -X GET  http://localhost:3010/api/clothing/name/Nice™%       (fuzzy search)
	    curl -X GET  http://localhost:3010/api/category/name/Shoes
	    curl -X GET  http://localhost:3010/api/outfit/id/3
	    curl -X GET  http://localhost:3010/api/outfit

POST:
	    curl -X POST -H "Accept: application/json" -H "Content-type: application/json" -d '{"name":"Trousers"}'  http://localhost:3010/api/category
	    curl -X POST -T tagging2.json  http://localhost:3010/tag/clothing
	
	    Retrieval of a list of clothes, their categories and associated outfits
	    curl -X GET  http://localhost:3010/api
	
	    Tagging of clothes(clothing_outfit)
	    curl -X POST -T tagging2.json  http://localhost:3010/tag/clothing 
	    curl -H "Accept: application/json" -H "Content-type: application/json" -X POST -d '{"clothing":"3", "outfit":"4"}'  http://localhost:3010/tag/clothing

    Clothing and categories can be created by uploading a CSV or JSON file. Format of the JSON file can be a hash
    or an array of hashes. The file extension should correspond to its content:        

        curl -X POST -F 'file=@clothing.csv'  http://localhost:3010/api/clothing
                                        or
        curl -X POST -F 'file=@clothing.csv'  http://localhost:3010/api/category
                                        or
        curl -X POST -F 'file=@clothing.json'  http://localhost:3010/api/clothing
                                        or
        curl -X POST -F 'file=@clothing.json'  http://localhost:3010/api/category

        curl -X POST -T 'clothing.csv'  http://localhost:3010/api/clothing
        curl -X POST -T 'clothing.json'  http://localhost:3010/api/category

        curl -X POST -F 'file=@incorrect_format.js'  http://localhost:3010/api/clothing
        curl -X POST -F 'file=@empty.csv'  http://localhost:3010/api/clothing

LIMITATIONS

1) No unit tests
2) Limited documentation

IMPROVEMENTS 

1) Add crUD functionality (update/delete)
2) When creating new entities, use find and create separately rather than find_or_create and output only created entities
3) Write unit tests
4) Add authentication/authorization
5) Add caching to improve performace
6) Add more POD
7) Add versioning
8) Could have used Try::Tiny

