package WxContact; use base qw(Wx::App Exporter); 
# use Class::Date qw(:errors date localdate gmdate now -DateParse -EnvC);
use strict; 
use v5.10;
use Exporter; 
use YAML qw(LoadFile);
use App::db::contacts; 
our $VERSION = 0.10;
our @EXPORT_OK = qw(StartApp FindWindowByXid MsgBox $frame $xr show_add show_dialog %test_list 
$xrc $frmID $sbar %menu $OpenFile $SaveFile $CloseWin $icon %txtctrl $dialog $frameGrid ) ; 
use Wx qw(wxDefaultPosition wxDefaultSize wxDP_ALLOWNONE); 
# use Wx::Grid;
use Carp; 
our $dialog; 
our $xr; 
#our $xrc = 'res/res.xrc'; # location of resource file 
our $xrc = './res/xrc_contact_dialog.xrc'; # location of resource file 

our $dialogID = 'MyDialog1'; # XML ID of the main frame 


our $OpenFile = \&OpenFile; # A routine to read data from a file 
our $SaveFile = \&SaveFile; # A routine to write data to a file 
our $CloseWin = \&CloseWin; # this is not a menu option 
# it is the routine called before the end 
# it needs to Destroy() all top level dialogs 
our $icon = Wx::GetWxPerlIcon(); 
my $file; # the name of the file used in Open/Save
my %cntlHash = ();

   my @lclDBData;

    my $bname;
    my $lastname;
    my $firstname;
    my $address;
    my $state;
    my $city;
    my $zip;
    my $phone;
    my $date;
    my $type;
    my $note;

# our $currentData;

     my $g_prodswt = 0;
     my $g_type;
     my $g_id;


sub OnInit 
{ my $app = shift; 
# 
# Load XML Resources 
# 
use Wx::XRC; 
$xr = Wx::XmlResource->new(); 
$xr->InitAllHandlers(); 
croak "No Resource file $xrc" unless -e $xrc; 
$xr->Load( $xrc ); 
# 
# Load the main frame from resources 
# 
# $dialog = 'Wx::Dialog'->new(our $frame); 
croak "No dialog named $dialogID in $xrc" unless 
$dialog = $xr->LoadDialog(our $frame, $dialogID);

# debug - print " pm - dialog = $dialog \n";
 
    $bname = FindWindowByXid('m_textCtrl2');
    $lastname = FindWindowByXid('m_textCtrl4');
    $firstname = FindWindowByXid('m_textCtrl3');
    $address = FindWindowByXid('m_textCtrl5');
    $state = FindWindowByXid('cbState');
    $city = FindWindowByXid('m_textCtrl6');
    $zip =   FindWindowByXid('m_textCtrl8');
    $phone = FindWindowByXid('m_textCtrl7');
    $date = FindWindowByXid('m_datePicker2');
    $type = FindWindowByXid('m_comboBox2');
    $note = FindWindowByXid('m_textCtrl10');

  %cntlHash = qw( 
   bname     $bname
   lastname  $lastname
   firstname $firstname
   address   $address
   state     $state
   city      $city
   phone     $phone
   date      $date
   type      $type
   note      $note
   zip        $zip
 );


# debug - print " pm - frame = $frame \n";

my ( $idAdd) = FindWindowByXid('btnAdd');
Wx::Event::EVT_BUTTON($dialog, $idAdd, \&OnUpdate );

my ($idCancel) = FindWindowByXid('btnCancel');
Wx::Event::EVT_BUTTON($dialog, $idCancel, sub { $_[0]->Close } );

append_combo();

my $ck_dialog = 0;
if ( $ck_dialog)
{
 our $dialogGrid = $xr->LoadDialog( $frame,  'MyDialog1' );
}

#our $frameGrid = $xr->LoadObject(undef, 'm_grid3', 'Wx::Grid');

 
if (my $sbar) 
{  $frame->CreateStatusBar( $sbar ); 
   $frame->SetStatusWidths(-1,200); 
} 
# our $frame->SetIcon( $icon ); 
# 
# Set event handlers 
# 
use Wx::Event qw(EVT_MENU EVT_CLOSE); 
# 
# Show the window 
# 
1; 
} 
sub FindWindowByXid 
{ my $id = Wx::XmlResource::GetXRCID($_[0], -2);
return undef if $id == -2; 
my $win = Wx::Window::FindWindowById($id, our $frame); 
return wantarray ? ($win, $id) : $win; 
} 
sub MsgBox 
{ use Wx qw (wxOK wxICON_EXCLAMATION); 
my @args = @_; 
$args[1] = 'Message' unless defined $args[1]; 
$args[2] = wxOK | wxICON_EXCLAMATION unless defined $args[2]; 
my $md = Wx::MessageDialog->new(our $frame, @args); 
$md->ShowModal(); 
} 

sub append_combo
{
   my  (@settings) = LoadFile('.\res\states.yaml');
   my  (@settings0) = LoadFile('.\res\type.yaml');
 
      foreach my $s (@settings)
      {
             $state->Append($s);
      }
      
      foreach my $t (@settings0)
      {
             $type->Append($t);
      }

}

sub show_add {
    my( $self, $event, $parent ) = @_;

#    my $dialog = $self->xrc->LoadDialog( $parent || $self, 'dlg1' );
     

    $dialog->ShowModal();
#    $dialog->Destroy;
}       


sub show_dialog {
#    my( $self, $event, $parent ) = @_;
   my ($intype, $thisCurrentData ) = @_;
   
#   append_combo();
   
#   @lclDBData = @thisCurrentData;
   
             my $idClear = FindWindowByXid('btnClear');

             my $idA1 = FindWindowByXid('btnAdd');


    $g_type = $intype;
    $g_id = $thisCurrentData;
   if ($intype) { say " ADD - $intype .. " unless $g_prodswt; 
    #      $idA1->SetLabel( "ADD");   
          $lclDBData[0] = "-99";
          $idA1->SetLabel( "Add" );
          $idClear->SetLabel( "Clear");
    } 
    else 
    { say "CHG -- $intype .. " unless $g_prodswt; 
    
          $idA1->SetLabel( "Change" );
          $idClear->SetLabel( "Delete" );

        
   
   say " sub $dialog .. " unless $g_prodswt;
   my $id;

#  get the current contact record
  
   my $allcontacts =    App::db::contacts->retrieve($thisCurrentData);

if( $@ ) { 
# There was an error: 
die $@; 
} 

   
   if ( defined $allcontacts->Contact_BusinessName) {  $bname->ChangeValue($allcontacts->Contact_BusinessName) } else { $bname->ChangeValue("")} ;
   if ( defined $allcontacts->Contact_FirstName) {  $firstname->ChangeValue($allcontacts->Contact_FirstName) } else { $firstname->ChangeValue("")} ;
   if ( defined $allcontacts->Contact_LastName) { $lastname->ChangeValue($allcontacts->Contact_LastName) } else {$lastname->ChangeValue("")} ;
   if ( defined $allcontacts->Contact_Phone) { $phone->ChangeValue($allcontacts->Contact_Phone) } else {$phone->ChangeValue("")}; 
   if ( defined $allcontacts->Contact_City) { $city->ChangeValue($allcontacts->Contact_City) } else {$city->ChangeValue("")}; 
   if ( defined $allcontacts->Contact_Street) {  $address->ChangeValue($allcontacts->Contact_Street) } else { $address->ChangeValue("")} ;
   if ( defined $allcontacts->Contact_State) { $state->SetValue($allcontacts->Contact_State) };
    if ( defined $allcontacts->Contact_Notes) { $note->SetValue($allcontacts->Contact_Notes) };
    if ( defined $allcontacts->Contact_Type) { $type->SetValue($allcontacts->Contact_Type) };
#   if ( $currentLength > 6 && $data[6] ne "." && $data[6] =~ /\d{3,}-\d\d-\d\d/) { $date->SetValue($data[6]) }; 

if ( defined $allcontacts->Contact_ContactDate)
{
   my ($yy, $dd, $mm ) =  ParseInDate($allcontacts->Contact_ContactDate);

   my $dateObj = Wx::DateTime->newFromDMY($dd,$mm-1,$yy, 1,1,1,1);
   my $tmpstr = $dateObj->Format;
   print " date = ", $allcontacts->Contact_ContactDate, "\n  dateObj = $dateObj \n str = $tmpstr \n";
 
    $date->SetValue($dateObj); 
}  
#    my $dialog = $self->xrc->LoadDialog( $parent || $self, 'dlg1' );
  }
    $dialog->ShowModal();
    say " exit - add - change dialog .." unless $g_prodswt;
#    $dialog->Destroy;
}     

sub ParseInDate
{
    my $lclDate = shift;
    my $m;
    my $y;
    my $d;
 #   $lclDate =~ s{\/}{-}g;
    print " date mod: $lclDate \n";
    $m = substr($lclDate,4,2); 
    $y = substr($lclDate,0,4);
    $d = substr($lclDate,6,2);
 #   \d{3,}-\d\d-\d\d
  #  $date =~ /^(\d{4}) (\d{2}) (\d{2})\ (\d{2}):(\d{2})$/x;
#  my ($m,$d,$y) = $lclDate =~ /(\d+)-(\d+)-(\d+)/
  
  
#   or die;
   say " year = $y , month = $m, day = $d  " unless $g_prodswt;;   
    return ($y, $d, $m );
}

sub ParseDate
{
    my $lclDate = shift;
    $lclDate =~ s{\/}{-}g;
    print " date mod: $lclDate \n" unless $g_prodswt;
 #   \d{3,}-\d\d-\d\d
  #  $date =~ /^(\d{4}) (\d{2}) (\d{2})\ (\d{2}):(\d{2})$/x;
  my ($m,$d,$y) = $lclDate =~ /(\d+)-(\d+)-(\d+)/
   or die;
   print " year = $y , month = $m, day = $d  \n" unless $g_prodswt;   
    return ($y, $d, $m );
}

sub OnUpdate {
    my $this = shift;
    use Wx qw(wxOK wxCENTRE);
     my $lastID = 0;

     my $data = CreateString();
  
    # Refresh();
    
    Wx::MessageBox("_lbl1: $g_id\n $data\n(c)More On Perl",  # text
                   "About",                   # title bar
                   wxOK|wxCENTRE,             # buttons to display on form
                   $this                      # parent
                   );             
}

sub CreateString
{
    my $intype = shift;
    my @retArray;
    my $id;
    my $cnt = 0;
    my $yy;
    my $dd;
    my $mm;
    my $tdate;

    ($yy, $dd, $mm ) = ParseDate($date->GetValue()->FormatDate);
              $dd = "0". $dd unless length $dd > 1;
              $mm = "0" .$mm unless length $mm > 1;
              $tdate = $yy . $mm . $dd ; 

    if ($g_type == 0)
    {
        say "record change- type: $g_type" unless $g_prodswt;    
    
    my $allcontacts =    App::db::contacts->retrieve($g_id);
# Save the changes to the database: 
          $allcontacts->Contact_BusinessName($bname->GetValue());
          $allcontacts->Contact_FirstName($firstname->GetValue());
          $allcontacts->Contact_LastName($lastname->GetValue());
          $allcontacts->Contact_Street($address->GetValue());
          $allcontacts->Contact_City($city->GetValue());
          $allcontacts->Contact_State($state->GetValue());
          $allcontacts->Contact_Zip($zip->GetValue());
          $allcontacts->Contact_Phone($phone->GetValue());
          $allcontacts->Contact_ContactDate($tdate);
          $allcontacts->Contact_Type($type->GetValue());
          $allcontacts->Contact_Notes($note->GetValue());
   $allcontacts->update; 
   if( $@ ) { 
# There was an error: 
die $@; 
} 

   }
   else
   {
               say "record create - type: $g_type " unless $g_prodswt;    

       my $allcontacts = App::db::contacts->create(
                               Contact_ContactID => $g_id,
                               Contact_BusinessName => $bname->GetValue(),
                               Contact_FirstName => $firstname->GetValue(),
                               Contact_LastName => $lastname->GetValue(),
                               Contact_Street => $address->GetValue(),
                               Contact_City => $city->GetValue(),
                               Contact_State => $state->GetValue(),
                               Contact_Zip => $zip->GetValue(),
                               Contact_Phone => $phone->GetValue(),
                               Contact_ContactDate => $tdate,
                               Contact_Type => $type->GetValue(),
                               Contact_Notes => $note->GetValue(),
                               );
            if( $@ ) { 
# There was an error: 
die $@; 
} 
                   
   }
  return $lastname->GetValue();
}


sub Exit 
{ CloseWin(); 
} 
# 
# Close is not called by the menu, but is called to close all wind 
#         +ows 
# If there are any toplevel dialogs, close them here, otherwise th 
#               +e 
# program will not exit. 
# 
sub CloseWin 
{ our $frame->Destroy(); 
} 
1; 
