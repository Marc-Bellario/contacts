package WxContact; use base qw(Wx::App Exporter); 
# use Class::Date qw(:errors date localdate gmdate now -DateParse -EnvC);
use strict; 
use Exporter; 
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
sub Open 
{ use Wx qw (wxID_CANCEL wxFD_FILE_MUST_EXIST); 
my $dlg = Wx::FileDialog->new( our $frame, 
'Select one or more Files', '', '', 
'Text Files|*.txt|All Files|*.*', 
wxFD_FILE_MUST_EXIST); 
if ($dlg->ShowModal() == wxID_CANCEL) { return } 
$file = $dlg->GetPath(); 
 $frame->SetStatusText("Opening...$file", 0); 
my $busy = Wx::BusyCursor->new(); 
$OpenFile->($file); 
 $frame->SetStatusText("Opening...$file...Done", 0); 
} 
sub Save 
{ our $frame->SetStatusText("Saving...$file", 0); 
my $busy = Wx::BusyCursor->new(); 
$SaveFile->($file); 
$frame->SetStatusText("Saving...$file...Done", 0); 
} 
sub SaveAs 
{ use Wx qw (wxID_CANCEL wxFD_OVERWRITE_PROMPT wxFD_SAVE); 
my $dlg = Wx::FileDialog->new( our $frame, 
'Select one or more Files', '', '', 
'Text Files|*.txt|All Files|*.*', 
wxFD_OVERWRITE_PROMPT | wxFD_SAVE); 
if ($dlg->ShowModal() == wxID_CANCEL) { return } 
$file = $dlg->GetPath(); 
Save(); 
} 


sub show_add {
    my( $self, $event, $parent ) = @_;

#    my $dialog = $self->xrc->LoadDialog( $parent || $self, 'dlg1' );
    $dialog->ShowModal();
#    $dialog->Destroy;
}       


sub show_dialog {
#    my( $self, $event, $parent ) = @_;
   my ($type, @thisCurrentData ) = @_;
   
   @lclDBData = @thisCurrentData;
   
             my $idClear = FindWindowByXid('btnClear');

             my $idA1 = FindWindowByXid('btnAdd');

   if ($type) { print " ADD - $type \n "; 
    #      $idA1->SetLabel( "ADD");   
          $lclDBData[0] = "-99";
          $idA1->SetLabel( "Add" );
          $idClear->SetLabel( "Clear");
    } 
    else 
    { print "CHG\n"; 
    
          $idA1->SetLabel( "Change" );
          $idClear->SetLabel( "Delete" );

        
   
   print " sub $dialog \n ";
   my $id;
   
    
      my $sizer = $date->GetContainingSizer();
      my $parentP = $date->GetParent();
#       $date->Hide();
#      $date->SetDefaultStyle( wxDP_ALLOWNONE);
#    $date->SetStyle( wxDP_ALLOWNONE );
#     $sizer->DeleteWindows();

my $dater;
if (0){
#    $sizer->DeleteWindows();
    $sizer->Replace($date, Wx::DatePickerCtrl->new(
    $parentP,
    -1,
    Wx::DateTime->newFromDMY(10,10,2010, 1,1,1,1),
    wxDefaultPosition,
     wxDefaultSize,
    wxDP_ALLOWNONE
));  

    
    
   } else { print "sizer - not found\n"; }
   
   # if ( our $currentIndex ) print " currentIndex = $currentIndex\n";
    my @data = ();
       @data = @lclDBData;
    
    $id = $data[0];
   my $currentLength = scalar @data;
#   print " current data : $thisCurrentData \n";
   print " current data len: $currentLength \n ";
   
   if ( $currentLength > 1 && $data[1] ne ".") {  $bname->ChangeValue($data[1]) } else { $bname->ChangeValue("")} ;
   if ( $currentLength > 2 && $data[2] ne ".") {  $firstname->ChangeValue($data[2]) } else { $firstname->ChangeValue("")} ;
   if ( $currentLength > 3 && $data[3] ne ".") { $lastname->ChangeValue($data[3]) } else {$lastname->ChangeValue("")} ;
   if ( $currentLength > 8  && $data[8] ne ".") { $phone->ChangeValue($data[8]) } else {$phone->ChangeValue("")}; 
   if ( $currentLength > 5  && $data[5] ne ".") { $city->ChangeValue($data[5]) } else {$phone->ChangeValue("")}; 
   if ( $currentLength > 4 && $data[4] ne ".") {  $address->ChangeValue($data[4]) } else { $address->ChangeValue("")} ;
   if ( $currentLength > 6 && $data[6] ne ".") { $state->SetValue($data[6]) };
    
#   if ( $currentLength > 6 && $data[6] ne "." && $data[6] =~ /\d{3,}-\d\d-\d\d/) { $date->SetValue($data[6]) }; 
 my ($yy, $dd, $mm ) =  ParseDate($data[9]);

 my $dateObj = Wx::DateTime->newFromDMY($dd,$mm-1,$yy, 1,1,1,1);
 my $tmpstr = $dateObj->Format;
 print " date = $data[9] \n  dateObj = $dateObj \n str = $tmpstr \n";

 
    if ( $currentLength > 9 && $data[9] ne "." ) { $date->SetValue($dateObj) }; 
  
#    my $dialog = $self->xrc->LoadDialog( $parent || $self, 'dlg1' );
  }
    $dialog->ShowModal();
    print " exit - add - change dialog \n";
#    $dialog->Destroy;
}       

sub ParseDate
{
    my $lclDate = shift;
    $lclDate =~ s{\/}{-}g;
    print " date mod: $lclDate \n";
 #   \d{3,}-\d\d-\d\d
  #  $date =~ /^(\d{4}) (\d{2}) (\d{2})\ (\d{2}):(\d{2})$/x;
  my ($m,$d,$y) = $lclDate =~ /(\d+)-(\d+)-(\d+)/
   or die;
   print " year = $y , month = $m, day = $d \n ";   
    return ($y, $d, $m );
}

sub OnUpdate {
    my $this = shift;
    use Wx qw(wxOK wxCENTRE);
     my $lastID = 0;

     my @dataArray = CreateString();
  
  	  my @dbColums = qw( 
                           Contact_BusinessName
                           Contact_FirstName
	                   Contact_LastName
	                   Contact_Street
	                   Contact_City 
	                   Contact_State 
	                   Contact_Zip
	                   Contact_Phone
	                   Contact_ContactDate
	                   Contact_Type
	                      );
 
  
  
  
  
    
     my $dbfile = "contactmanagement.db";
     my $dbh = DBI->connect("dbi:SQLite:dbname=$dbfile","","", {});
    
    
    
       my @data = @lclDBData;
  
     
my $statement;
if ( $data[0] > 0 )
{
          
         print " in upt --- > $data[0] \n ";
         my $ind = 0;
         while ( $ind < 10 )
         {  
             print "val: $ind ---> $dataArray[$ind] <-----";
             $ind++;
         }
         print " \n";
	  my $tempe = join(" = ?, ",@dbColums);
#        $statement = "UPDATE ContactData SET Contact_FirstName = ?, Contact_LastName = ?, Contact_Phone= ?, Contact_State = ?, Contact_ContactDate = ? WHERE ContactID = ?"; 
	                   
        $statement = "UPDATE ContactData SET " . $tempe . "= ?, Contact_Notes = ? WHERE ContactID = ?"; 
        $dbh->do($statement, undef, $dataArray[0], $dataArray[1],$dataArray[2],$dataArray[3],$dataArray[4],$dataArray[5], $dataArray[6],$dataArray[7],$dataArray[8],$dataArray[9],$dataArray[10], $data[0]);
}
else
{
    # sub - get index --- 
                          my $tempez = join(", ", @dbColums);
#      $statement = "INSERT INTO ContactData (ContactID, Contact_BusinessName, Contact_FirstName, Contact_LastName, Contact_Street, Contact_City, Contact_State, Contact_ContactDate) VALUES(?, ?, ?, ?, ?, ?, ?, ?)";
             my $sth = $dbh->prepare("select ContactID from ContactData order by ContactID desc limit 1");
    $sth->execute();
    while (
        my @result = $sth->fetchrow_array()) {
        print "id: $result[0]\n";
        $lastID = $result[0];
    }
    $sth->finish;
    $lastID++;
                     
     $statement = "INSERT INTO ContactData (ContactID, " . $tempez . ",Contact_Notes) VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
    $dbh->do($statement, undef, $lastID, $dataArray[0], $dataArray[1],$dataArray[2],$dataArray[3],$dataArray[4], $dataArray[5], $dataArray[6],$dataArray[7],$dataArray[8],$dataArray[9],$dataArray[10],$dataArray[11]);
}

    $dbh->disconnect;
    # Refresh();
    
    Wx::MessageBox("_lbl1: $dataArray[0]\n $dataArray[1]\n(c)DamienLearnsPerl",  # text
                   "About",                   # title bar
                   wxOK|wxCENTRE,             # buttons to display on form
                   $this                      # parent
                   );             
}

sub CreateString
{
    my @retArray;
    my $id;
    my $cnt = 0;
    
          push(@retArray, $bname->GetValue());
          push(@retArray, $firstname->GetValue());
          push(@retArray, $lastname->GetValue());
          push(@retArray, $address->GetValue());
          push(@retArray, $city->GetValue());
          push(@retArray, $state->GetValue());
          push(@retArray, $zip->GetValue());
          push(@retArray, $phone->GetValue());
          push(@retArray, $date->GetValue()->FormatDate);
          push(@retArray, $type->GetValue());
          push(@retArray, $note->GetValue());
   
  return @retArray;
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
