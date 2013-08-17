#!/usr/bin/perl -w 
use strict; 
use warnings 'all'; 
use App::db::contacts; 
 
 my $fname;
 my $lname;
 my $phone;
 my $city;
 my $state;
 my $date;
 
format STDOUT_TOP =
                         Contact File
First Name   Last Name    Phone        City       State     Date
------------------------------------------------------------------
.
format STDOUT =
@<<<<<<<<<<< @<<<<<<<<<<<<@<<<<<<<<<<@>>>>>>>>> @>>>>>>>>>> @<<<<<<<<
$fname,              $lname,                      $phone,    $city,               $state,            $date
.


my $cntr = App::db::contacts->retrieve_all;
print "cnt all: ",$cntr->count,"\n";
my @contacts = App::db::contacts->retrieve_all;

foreach my $acontact (@contacts)
{
	     $fname = $acontact->Contact_FirstName;                 
             $lname = $acontact->Contact_LastName;                
             $phone = $acontact->Contact_Phone;
             $city = $acontact->Contact_City;             
             $state = $acontact->Contact_State;  
             $date = $acontact->Contact_ContactDate;
                     write;
}