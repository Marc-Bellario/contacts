package App::db::model; 
use strict; 
use warnings 'all'; 
use base 'Class::DBI::Lite::SQLite'; 
     my $dbfile = "contactmanagement.db";
__PACKAGE__->connection( 
'DBI:SQLite:dbname=contactmanagement.db', '', '' 
); 
1;# return true: 
