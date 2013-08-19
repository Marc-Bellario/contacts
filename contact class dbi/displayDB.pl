#!/usr/bin/perl -w 
use strict; 
use warnings 'all'; 
use v5.10;
use App::db::contacts; 
 
 # get command line args
=begin args
   0. no args required or require 4 -- max 5
   1. field name 
use only
 "state, name, type, date"
   2. operator :   equal ( = ) or sort ($!) or like (!!)  before (b:)  after (a:) or between (::)  
        ---- if two criteria - then imply or --- (before an after use only one)  
    3.   crit - 1  ( -- only with before and after )
    4.   crit - 2 ( --- use both only with :  between new - old)
    
    note:  before, after and between only work on date fields 
    
=end args
=cut 

 my $selectfield = shift;
 my $selectoper = shift;
 my $crit1 = shift;
 my $crit2 = shift; 
 
 say "sel : $selectfield";
 
=begin mess
  if (exists $selectfield) print "op: $selectfield\n";
  if (exists $selectoper) print "op: $selectoper\n";
 
 if (exists $crit1) print "crt1: $crit1\n";
 if (exists $crit2) print "crt2: $crit2\n";
=end mess
=cut

 my $fname;
 my $lname;
 my $phone;
 my $city;
 my $state;
 my $date;
 my $type;
 
format STDOUT_TOP =
                         Contact File
First Name   Last Name    Phone        City       State     Date   Type
------------------------------------------------------------------
.
format STDOUT =
@<<<<<<<<<<< @<<<<<<<<<<<< @<<<<<<<<<<< @>>>>>>>>> @>>>>>>>>>> @<<<<<<<< @<<<<<<<<
$fname,              $lname,                      $phone,    $city,               $state,            $date,    $type
.


my $cntr = App::db::contacts->retrieve_all;
say "cnt all: ",$cntr->count;


my @contacts = doSelect();

foreach my $acontact (@contacts)
{
              clear();
	     $fname = $acontact->Contact_FirstName if defined $acontact->Contact_FirstName;                 
             $lname = $acontact->Contact_LastName if defined $acontact->Contact_LastName;                
             $phone = $acontact->Contact_Phone if defined $acontact->Contact_Phone;
             $city = $acontact->Contact_City if defined $acontact->Contact_City;             
             $state = $acontact->Contact_State if defined $acontact->Contact_State;  
             $date = $acontact->Contact_ContactDate if defined $acontact->Contact_ContactDate;
              $type = $acontact->Contact_Type if defined $acontact->Contact_Type;

                     write;
}

sub clear
{
     $fname = $lname = $phone = $city = $state = $date = $type = "_";
}


sub doSelect
{
 
    my @contacts;

    if (defined $selectfield)
    {
        if ($selectfield eq 'state')
        {
              @contacts = stateselect();
        }
        elsif($selectfield eq 'name')
        {
              @contacts = nameselect();
        }
        elsif($selectfield eq 'date')
        {
               @contacts = dateselect();
         }    
        elsif($selectfield eq 'type')
        {
              @contacts = typeselect();
        }

    }
    else
    {
        @contacts = App::db::contacts->retrieve_all;
    } 
    
    return @contacts;
}

sub typeselect
{
           my @contacts;
  
            if ($selectoper eq '$!')
            {
                say "type sort";
                  @contacts =   App::db::contacts->search_where
                                 ( { Contact_Type => { LIKE => "%"}},
                                 {order_by => 'Contact_Type ASC'} );
            }
            elsif  ($selectoper eq '!!')
            {
                        #           $crit1 = 'O';  
                                  @contacts =   App::db::contacts->search_where
                                 ( { Contact_Type => { LIKE => "%$crit1%"}});
            }
            elsif ($selectoper eq '=')
            {
                                  @contacts =   App::db::contacts->search_where
                                 ( { Contact_Type => $crit1});
             }

             return @contacts;
}

sub dateselect
{
             my @contacts;
 
             if ($selectoper eq '$!')
            {
                say "date sort";
                  @contacts =   App::db::contacts->search_where
                                 ( { Contact_ContactDate => { LIKE => "%%"}},
                                 {order_by => 'Contact_ContactDate ASC'} );
            }
            elsif  ($selectoper eq '!!')
            {
                        #           $crit1 = 'O';  
                                  @contacts =   App::db::contacts->search_where
                                 ( { Contact_ContactDate => { LIKE => "$crit1%"}},
                                 {order_by => 'Contact_ContactDate ASC'} );
            }
            elsif ($selectoper eq '=')
            {
                                  @contacts =   App::db::contacts->search_where
                                 ( { Contact_ContactDate => $crit1},
                                 {order_by => 'Contact_ContactDate ASC'} );
             }
             elsif ($selectoper eq 'a:')
            {
                 my $sth = App::db::contacts->db_Main->prepare("SELECT * FROM ContactData WHERE Contact_ContactDate > ?");
                 $sth->execute( $crit1 ); 
                                  @contacts =   App::db::contacts->sth_to_objects( $sth ); 
             }
             elsif ($selectoper eq 'b:')
            {
                 my $sth = App::db::contacts->db_Main->prepare("SELECT * FROM ContactData WHERE Contact_ContactDate < ?");
                 $sth->execute( $crit1 ); 
                                  @contacts =   App::db::contacts->sth_to_objects( $sth ); 
             }
             elsif ($selectoper eq '::')
            {
                 my $sth = App::db::contacts->db_Main->prepare("SELECT * FROM ContactData WHERE Contact_ContactDate < ? and Contact_ContactDate > ?");
                 $sth->execute( $crit1, $crit2 ); 
                                  @contacts =   App::db::contacts->sth_to_objects( $sth ); 
             }

                return @contacts;
}

sub nameselect
{
             my @contacts;
             if ($selectoper eq '$!')
            {
                say "name sort";
                      @contacts =   App::db::contacts->search_where
                                 ( { Contact_LastName => { LIKE => "%%"}},
                                 {order_by => 'Contact_LastName ASC'} );
            }
            elsif  ($selectoper eq '!!')
            {
                        #           $crit1 = 'O';  
                       @contacts =   App::db::contacts->search_where
                                 ( { Contact_LastName => { LIKE => "$crit1%"}},
                                 {order_by => 'Contact_LastName ASC'} );
            }
            elsif ($selectoper eq '=')
            {
                       @contacts =   App::db::contacts->search_where
                                 ( { Contact_LastName => $crit1},
                                 {order_by => 'Contact_LastName ASC'} );
             }
       
             return @contacts;
}

sub stateselect
{
             my @contacts;
              
             if ($selectoper eq '$!')
            {
                say "state sort";
                  @contacts =   App::db::contacts->search_where
                                 ( { Contact_State => { LIKE => "%%"}},{order_by => 'Contact_State ASC'} );
            }
            elsif  ($selectoper eq '!!')
            {
                                   #$crit1 = 'M';  
                    @contacts =   App::db::contacts->search_where
                                 ( { Contact_State => { LIKE => "$crit1%"}},
                                 {order_by => 'Contact_State DESC'} );
            }
             elsif ($selectoper eq '=')
            {
                    @contacts =   App::db::contacts->search_where
                                 ( { Contact_State => $crit1},
                                 {order_by => 'Contact_State ASC'} );
             }

             return @contacts;
}