#!/usr/bin/perl -w -- 
# generated by wxGlade 0.6.5 (standalone edition) on Fri Jan 11 14:59:42 2013
# To get wxPerl visit http://wxPerl.sourceforge.net/

use FindBin;
use lib "$FindBin::Bin";

#use lib "C:\\Documents and Settings\\will\\Desktop\\projects\\contact_app";
use Wx 0.15 qw[:allclasses];
use strict;
use Wx::Grid;

package MyFrame;

use Wx qw[:everything];
use Wx::Event qw(EVT_GRID_LABEL_LEFT_CLICK EVT_GRID_LABEL_LEFT_DCLICK EVT_MENU);
use base qw(Wx::Frame);
use strict;
use warnings;
use DBI          qw();
use App::db::contacts; 

use WxContact qw(StartApp   $frame $xr show_add show_dialog %test_list 
$xrc $frmID $sbar %menu  $CloseWin $icon %txtctrl $dialog $frameGrid ) ;

use WxDelete qw($frame $xr show_delete  $currentData $xrc );
use WxSearch qw($frame $xr show_search $Exit);
my $currentDBData;
my $dbfile = "contactmanagement.db";
my @currentDataRow;
# global search
my $search_state;
my $g_sqlcount;
my $g_sqlselect;
my @g_grid_id_array;
my $g_prod_swt = 0;
my $g_current_id;
my $g_srch_cnt;
#global --- other
my $g_self; 

		my @dbColums = qw(ContactID
		          Contact_FirstName
	                  Contact_LastName
	                   Contact_Phone 
	                   Contact_State
	                   Contact_City 
	                   Contact_ContactDate);
	                   
	          my $tmpe = join(",",@dbColums);       

sub new {
	my( $self, $parent, $id, $title, $pos, $size, $style, $name ) = @_;
	$parent = undef              unless defined $parent;
	$id     = -1                 unless defined $id;
	$title  = ""         unless defined $title;
	$pos    = wxDefaultPosition  unless defined $pos;
	$size   = wxDefaultSize      unless defined $size;
	$name   = ""                 unless defined $name;

        

#                begin wxGlade: MyFrame::new

	$style = wxDEFAULT_FRAME_STYLE 
		unless defined $style;

	$self = $self->SUPER::new( $parent, $id, $title, $pos, $size, $style, $name );
	$self->{grid_1} = Wx::Grid->new($self, -1);
         $g_self = $self;
         
#                create dialog

         our $frame = $self;
         our $currentIndex = 0;
         our $Refresh = \&Refresh;
         
#    debug         print "script frame = $frame \n";

         WxContact->new();
         WxDelete->new();
         WxSearch->new();	
          
#                  Menu Bar

	$self->{frame_1_menubar} = Wx::MenuBar->new();
	my $wxglade_tmp_menu;
	my $menu = Wx::Menu->new();
	my $menu2 = Wx::Menu->new();
	
	$menu->Append(102, "Refresh" );
	$menu->Append( wxID_CLOSE, "Exit" );
	$menu2->Append( 101, "Add" );

	$menu2->Append( 103, "Delete" );
        $menu2->Append( 104, "Search" );
	
	
	$self->{frame_1_menubar}->Append($menu, "file");
	$self->{frame_1_menubar}->Append($menu2, "dialog");

	
	$self->SetMenuBar($self->{frame_1_menubar});

	EVT_MENU( $self, wxID_CLOSE, sub { $_[0]->Close; $frame->Destroy() } );


#	EVT_MENU( $self, wxID_CLOSE, sub { $_[0]->Close; $self->Destroy() } );


	EVT_MENU( $self, 101, \&add_dialog );
	EVT_MENU( $self, 102, \&Refresh );
	EVT_MENU( $self, 103, \&Delete );
	EVT_MENU( $self, 104, \&Search );


	
	

	
#                     Menu Bar end


	$self->__set_properties();
	$self->__do_layout();

#                          end wxGlade

	return $self;

}


sub __set_properties {
	my $self = shift;

# begin wxGlade: MyFrame::__set_properties
    my @grid_id_array;
     @g_grid_id_array = @grid_id_array;
#  SetHeading();
  Init();
                     
  EVT_GRID_LABEL_LEFT_CLICK( $self, sub {  print G2S( $_[1] ); print "click\n"; $_[1]->Skip;  });
  EVT_GRID_LABEL_LEFT_DCLICK( $self, \&show_dialog_local);

                    
 sub G2S {
  my $event = shift;
  my( $x, $y ) = ( $event->GetCol, $event->GetRow );
#   @currentDataRow = getCurrent($y);
   $g_current_id = $g_grid_id_array[$y];

  return "( $x, $y )";
}
 
sub show_dialog_local
{
   show_dialog(0, $g_current_id);
   Refresh();	
}       

#    sql set routines

sub initsql
{
          $g_sqlcount =    "SELECT COUNT(*)  FROM ContactData where ContactID > 0";
          $g_sqlselect ="SELECT " . $tmpe . " FROM ContactData where ContactID > 0";
}

sub name_search_sql
{
	    	my  $search_crit = shift;

           $g_sqlcount =  " SELECT COUNT(*)  FROM ContactData where Contact_LastName = '$search_crit'";
           $g_sqlselect =   "SELECT " . $tmpe . " FROM ContactData where Contact_LastName = '$search_crit'";
 }

 sub type_search_sql
{
	
	my  $search_crit = shift;
        $g_sqlcount =  " SELECT COUNT(*)  FROM ContactData where Contact_Type = '$search_crit'";
        $g_sqlselect =   "SELECT " . $tmpe . " FROM ContactData where Contact_Type = '$search_crit'";
}
      
 sub state_search_sql
{
	my  $search_crit = shift;
	print " state search ---> $search_crit\n" unless $g_prod_swt;;
        $g_sqlcount =  " SELECT COUNT(*)  FROM ContactData where Contact_State = '$search_crit'";
        $g_sqlselect =   "SELECT " . $tmpe . " FROM ContactData where Contact_State = '$search_crit'";
 }
      
      
sub Delete
{
	print "Del: $currentDataRow[0] \n" unless $g_prod_swt;
       show_delete(@currentDataRow);                     
}

 sub Search
{
	my $local = $currentData;
	print "Search: $local \n" unless $g_prod_swt;
       my($type,$crit) = show_search();
       print "crit: $crit \n" unless $g_prod_swt;
       print "type: $type\n" unless $g_prod_swt;
       my @results = setsql($type,$crit);   
       Search_Refresh(@results);                     
}     

sub setsql
{
       my ($type,$search_crit) = @_;

         print "setsql- type: $type - crit: $search_crit\n" unless $g_prod_swt;

          my @contactresults;


                               if ($type == 1)
                               {  
                               	        state_search_sql($search_crit);
                               	       @contactresults = App::db::contacts->search_where(Contact_State => $search_crit);
                               	        $g_srch_cnt = App::db::contacts->count_search_where(Contact_State => $search_crit);

                               }     
                               elsif ($type == 2)
                               {
                                         name_search_sql($search_crit);
                                         @contactresults = App::db::contacts->search_where(Contact_LastName => $search_crit);
                                         $g_srch_cnt = App::db::contacts->count_search_where(Contact_LastName => $search_crit);

                               }        	 
                               elsif ($type == 3)
                               {
                                       	type_search_sql($search_crit);
                                         @contactresults = App::db::contacts->search_where(Contact_Type => $search_crit);
                                        $g_srch_cnt = App::db::contacts->count_search_where(Contact_Type => $search_crit);
                               }
                               
                               return @contactresults;
}
 
sub Search_Refresh
{
	
	my @results = @_;
	
	print "g_select: $g_sqlselect\n" unless $g_prod_swt;
	
	my $sqlselect = $g_sqlselect;
	


    my ($count) = $g_srch_cnt;
 
 
    print  "cnt: $count\n" unless $g_prod_swt;

	$g_self->SetTitle("CONTACTS-");
	$g_self->{grid_1}->Destroy();
	
	print "after destroy\n" unless $g_prod_swt;
	
        $g_self->{grid_1} = Wx::Grid->new($g_self, -1);
	$g_self->{grid_1}->CreateGrid($count, 6);
	$g_self->{grid_1}->SetSelectionMode(wxGridSelectRows);
		SetHeading();
       $g_self->__set_properties();
	$g_self->__do_layout();


    my $cnt_row = 0;
    my $cnt_col = 0;
    
    set_cells(@results);
    
    
    print "\n" unless $g_prod_swt;
	
}     
  
sub Init
{

#    initsql();


    my $allcontacts =    App::db::contacts->retrieve_all;

    my ($count) = $allcontacts->count;


	$g_self->SetTitle("CONTACTS");

	$g_self->{grid_1}->CreateGrid($count, 6);
	$g_self->{grid_1}->SetSelectionMode(wxGridSelectRows);
		SetHeading();

    my @allcontacts =    App::db::contacts->retrieve_all;

if( $@ ) { 
# There was an error: 
die $@; 
} 


    my $cnt_row = 0;
    my $cnt_col = 0;
 
     set_cells(@allcontacts);
	
}       

sub add_dialog
{
	    my @darray;
	    my $id = -99;
	    my $i = 0;
     while ( $i < 5 )
     {	
	$darray[$i] = "." ;
	$i++; 
     }	
	my $tmp = join (".",@darray);
	$currentData = $id . " " . $tmp;
       show_dialog(1);
}       
       
sub getCurrent
{
	my ($index) = @_;
	my $id = $g_grid_id_array[$index];
	
	print "id: $id\n" unless $g_prod_swt;
	return $id;
}	

sub SetHeading
{
#           $self->{grid_1}->SetColLabelValue(0, "ID" );	
           $g_self->{grid_1}->SetColLabelValue(0, "First Name" );	
           $g_self->{grid_1}->SetColLabelValue(1, "Last Name" );	
           $g_self->{grid_1}->SetColLabelValue(2, "Phone" );	
           $g_self->{grid_1}->SetColLabelValue(3, "State" );
            $g_self->{grid_1}->SetColLabelValue(4, "City" );
            $g_self->{grid_1}->SetColLabelValue(5, "Date" );	
}	
       
sub Refresh
{
	
#	    initsql();

    my $allcontacts =    App::db::contacts->retrieve_all;

    my ($count) = $allcontacts->count;

  

	$g_self->SetTitle("CONTACTS");
        $g_self->{grid_1}->Destroy();
		
	$g_self->{grid_1} = Wx::Grid->new($g_self, -1);
	$g_self->{grid_1}->CreateGrid($count, 6);
	$g_self->{grid_1}->SetSelectionMode(wxGridSelectRows);
		SetHeading();
	$g_self->__set_properties();
	$g_self->__do_layout();	
		
    my @allcontacts =    App::db::contacts->retrieve_all;


    my $cnt_row = 0;
    my $cnt_col = 0;
    
    set_cells(@allcontacts);
    
}       

# end wxGlade
}

sub set_cells
{
	my (@allcontacts) = @_;
	
	my $cnt_row = 0;
	
	    foreach my $acontact (@allcontacts) {
    
            $g_self->{grid_1}->SetCellValue($cnt_row, 0, $acontact->Contact_FirstName ) if (defined  $acontact->Contact_FirstName);
            $g_self->{grid_1}->SetCellValue($cnt_row, 1, $acontact->Contact_LastName ) if (defined $acontact->Contact_LastName);
            $g_self->{grid_1}->SetCellValue($cnt_row, 2, $acontact->Contact_Phone ) if (defined $acontact->Contact_Phone);
            $g_self->{grid_1}->SetCellValue($cnt_row, 3, $acontact->Contact_State ) if (defined $acontact->Contact_State);
            $g_self->{grid_1}->SetCellValue($cnt_row, 4, $acontact->Contact_City ) if (defined $acontact->Contact_City);
            $g_self->{grid_1}->SetCellValue($cnt_row, 5, $acontact->Contact_ContactDate ) if (defined $acontact->Contact_ContactDate);
            push ( @g_grid_id_array, $acontact->ContactID );
            $cnt_row++;
     }       

}



sub __do_layout {
	my $self = shift;

# begin wxGlade: MyFrame::__do_layout

	$self->{sizer_1} = Wx::BoxSizer->new(wxHORIZONTAL);
	$self->{sizer_1}->Add($self->{grid_1}, 1, wxALL | wxEXPAND, 10);
	$self->SetSizer($self->{sizer_1});
	$self->{sizer_1}->Fit($self);
	$self->Layout();

# end wxGlade
}

# end of class MyFrame

1;

1;

package main;

# unless(caller){
	local *Wx::App::OnInit = sub{1};
	my $app = Wx::App->new();
	Wx::InitAllImageHandlers();

	my $frame_1 = MyFrame->new();
	
#  debug	print " frame_1 = $frame_1 \n ";

	$app->SetTopWindow($frame_1);
	$frame_1->Show(1);
	$app->MainLoop();
# }
