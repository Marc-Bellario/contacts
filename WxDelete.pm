package WxDelete; use base qw(Wx::App Exporter); 
# use Class::Date qw(:errors date localdate gmdate now -DateParse -EnvC);
use strict; 
use Exporter;
use v5.10;
use App::db::contacts; 

our $VERSION = 0.10;
our @EXPORT_OK = qw(
$frame $xr show_delete  $currentData $xrc 
 ) ; 
use Wx; 
use Wx::Grid;
use Carp; 
our $dialog; 
our $xr; 
#our $xrc = 'res/res.xrc'; # location of resource file 
our $xrc = '.\\res\\xrc_delete_dialog.xrc'; # location of resource file 

our $dialogID = 'MyDialog2'; # XML ID of the main frame 
   my @lclDBData;
    
    my $g_id;
    my $g_prodswt = 0;
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
my ($idDelete) = FindWindowByXid('btnOK');
Wx::Event::EVT_BUTTON($dialog, $idDelete, \&OnDelete );

my ($idCancel) = FindWindowByXid('btnCancel');
Wx::Event::EVT_BUTTON($dialog, $idCancel, sub { $_[0]->Close } );


 
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
 


sub show_delete {
    my(@tmp ) = @_;
    $g_id = $tmp[0];
#   @lclDBData = @tmpDBData;
#    my $dialog = $self->xrc->LoadDialog( $parent || $self, 'dlg1' );
my $allcontacts =    App::db::contacts->retrieve($g_id); 
my $fname = $allcontacts->Contact_FirstName;
my $lname = $allcontacts->Contact_LastName;
my ($idLabel) = FindWindowByXid('m_staticText14');

         $idLabel->SetLabel("id: $g_id\n fname: $fname\n lname: $lname\n");

    $dialog->ShowModal();
#    $dialog->Destroy;
}       


sub show_dialog {
#    my( $self, $event, $parent ) = @_;
   my ($type) = @_;
    $dialog->ShowModal();
    print " exit - dialog \n";
#    $dialog->Destroy;
}       

sub OnDelete {
    my $this = shift;
    use Wx qw(wxOK wxCENTRE);
        my @data = @lclDBData;

      say " Enter Delete sub .. " unless $g_prodswt;;
 
my $allcontacts =    App::db::contacts->retrieve($g_id);
my $bname = $allcontacts->Contact_LastName;
 $allcontacts->delete;
 
     # Refresh();
    
    Wx::MessageBox("_lbl1: $g_id\n $bname\n(c) More On Perl",  # text
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
