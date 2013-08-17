package WxSearch; use base qw(Wx::App Exporter); 
# use Class::Date qw(:errors date localdate gmdate now -DateParse -EnvC);
use strict; 
use Exporter; 
our $VERSION = 0.10;
our @EXPORT_OK = qw(StartApp FindWindowByXid MsgBox $frame $xr show_search show_dialog 
%test_list $currentData $xrc $Exit
 ) ; 
# use WxPackage1;
use Wx; 
use Wx::Grid;
use Carp; 
our $dialog; 
our $xr; 
#our $xrc = 'res/res.xrc'; # location of resource file 
our $xrc = '.\\res\\xrc_search_dialog.xrc'; # location of resource file 

our $dialogID = 'MyDialog3'; # XML ID of the main frame 

#global

my $g_state;
my $g_name;
my $g_type;

my $g_typeswt;
my $g_crit;




# it is the routine called before the end 
# it needs to Destroy() all top level dialogs 
our $icon = Wx::GetWxPerlIcon(); 
my $file; # the name of the file used in Open/Save 
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
# debub - print " pm - frame = $frame \n";
my ($idSearch) = FindWindowByXid('btnSearch');
Wx::Event::EVT_BUTTON($dialog, $idSearch, \&OnSearch );

my ($idCancel) = FindWindowByXid('btnCancel');
#Wx::Event::EVT_BUTTON($dialog, $idCancel, sub { $_[0]->Close } );

Wx::Event::EVT_BUTTON($dialog, $idCancel, \&Exit );


         my ($idType) = FindWindowByXid('ckType');
          my ($idState) = FindWindowByXid('ckState');
          my ($idName) = FindWindowByXid('ckName');

#   enable controls on start 
             $idName->SetValue(0);
             $idState->SetValue(0);
             $idType->SetValue(0);
           FindWindowByXid('ckType')->Enable();
           FindWindowByXid('ckState')->Enable();   
            FindWindowByXid('ckName')->Enable();
            
#  disable date for release 1          
           FindWindowByXid('ckDateBefore')->Disable();
          FindWindowByXid('ckDateAfter')->Disable();

 Wx::Event::EVT_CHECKBOX($dialog,$idType,\&disableFromType);
 
  Wx::Event::EVT_CHECKBOX($dialog,$idState,\&disableFromState);

  Wx::Event::EVT_CHECKBOX($dialog,$idName,\&disableFromName);

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
 


sub  disableFromType
{
         print "disable for type\n";
           if ( FindWindowByXid('ckName')->IsChecked)
          {
               FindWindowByXid('ckState')->Disable();
               FindWindowByXid('ckName')->Disable();
         }
         else
         {
               FindWindowByXid('ckState')->Enable();
               FindWindowByXid('ckName')->Enable();
         }
}

sub disableFromName
{
          if ( FindWindowByXid('ckName')->IsChecked)
          {
             FindWindowByXid('ckType')->Disable();
              FindWindowByXid('ckState')->Disable();
         }
         else
         {
               FindWindowByXid('ckType')->Enable();
              FindWindowByXid('ckState')->Enable();
         }
}

sub disableFromState
{
          print "disable for state\n";   
          if ( FindWindowByXid('ckState')->IsChecked)
          {
             FindWindowByXid('ckType')->Disable();
              FindWindowByXid('ckName')->Disable();
         }
         else
         {
              FindWindowByXid('ckType')->Enable();
              FindWindowByXid('ckName')->Enable();
         }
}

sub show_search {
    my( $self, $event, $parent ) = @_;

#    my $dialog = $self->xrc->LoadDialog( $parent || $self, 'dlg1' );
    $dialog->ShowModal();
#    $dialog->Destroy;
        Exit();
       return ($g_typeswt, $g_crit);
}       


sub show_dialog {
#    my( $self, $event, $parent ) = @_;
   my ($type) = @_;
    $dialog->ShowModal();
    print " exit - dialog \n";
#    $_[0]->Close
#    $dialog->Destroy;
}    
   
sub OnSearch {
    print " in search routine\n";
    my $type = settype();
    my $crit;
    $g_typeswt = $type;
    if ($type == 1) {
           $g_state = FindWindowByXid('cbState')->GetValue();
           $g_crit = $g_state;
    }      
    else
    {
            if ($type == 2) {
                   $g_name = FindWindowByXid('tbName')->GetValue();
                   $g_crit = $g_name;
            }      
            else
            {
                   if ($type == 3) {
                        $g_type = FindWindowByXid('cbType')->GetValue();
                        $g_crit = $g_type;
                   }      

            }
    } 
 #   print "state: $g_state\n";
  Exit();
}

sub settype
{         
          my $type;
          my $swt_type = FindWindowByXid('ckType')->GetValue();
          my $swt_state = FindWindowByXid('ckState')->GetValue();
          my $swt_name = FindWindowByXid('ckName')->GetValue();
          
          print " state-swt: $swt_state\n";
          print  " name-swt: $swt_name\n";
          print "type-swt: $swt_type\n";
          
          if (( $swt_type ==1 ) && ($swt_state!=1) && ($swt_name!=1))
          {
              $type = 3;
          }
          else
          {
                             if (( $swt_type != 1 ) && ($swt_state==1) && ($swt_name!=1))
                             {
                                     $type =1;
                             }
                             else
                             {
                                 if (( $swt_type!=1 ) && ($swt_state!=1) && ($swt_name==1))
                                  {
                                      $type = 2;
                                  } 
                             }
          }
          
         print "type:$type\n";
         return $type;
}


sub OnUpdate {
    my $this = shift;
    use Wx qw(wxOK wxCENTRE);
    my $lastID = 0;
        my @data = split (/ /, our $currentData);

       my @dataArray = CreateString();
    
    my $dbfile = "contactmanagement.db";
     my $dbh = DBI->connect("dbi:SQLite:dbname=$dbfile","","", {});
     
my $statement;
if ( $data[0] > 0 )
{
        $statement = "UPDATE ContactData SET Contact_FirstName = ?, Contact_LastName = ?, Contact_Phone= ?, Contact_State = ?, Contact_ContactDate = ? WHERE ContactID = ?"; 
        $dbh->do($statement, undef, $dataArray[0], $dataArray[1],$dataArray[2],$dataArray[3],$dataArray[4], $data[0]);
}
else
{
    # sub - get index --- 
     $statement = "INSERT INTO ContactData (ContactID, Contact_BusinessName, Contact_FirstName, Contact_LastName, Contact_Street, Contact_City, Contact_State, Contact_ContactDate) VALUES(?, ?, ?, ?, ?, ?, ?, ?)";
    $dbh->do($statement, undef, $dataArray[0], $dataArray[1],$dataArray[2],$dataArray[3],$dataArray[4], $data[0]);
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
    
}


sub Exit 
{ 
 print "search exit\n";
  $dialog->Close; 
} 
# 
# Close is not called by the menu, but is called to close all windows 
#         
# If there are any toplevel dialogs, close them here, otherwise the 
#               
# program will not exit. 
# 
sub CloseWin 
{ 
 our $frame->Destroy(); 
} 
1; 
