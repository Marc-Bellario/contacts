package WxSearch; use base qw(Wx::App Exporter); 
# use Class::Date qw(:errors date localdate gmdate now -DateParse -EnvC);
use strict; 
use Exporter; 
use v5.10;
use YAML qw(LoadFile);

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
my $g_prodswt = 0;

my $state;
my $type;

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


    $type = FindWindowByXid('cbType');
    $state = FindWindowByXid('cbState');
      append_combo();

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


sub  disableFromType
{
         say "disable for type" unless $g_prodswt;
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
          say "disable for state" unless $g_prodswt;   
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
    say " exit - dialog " unless $g_prodswt;
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
    elsif ($type == 2)
    {
                   $g_name = FindWindowByXid('tbName')->GetValue();
                   $g_crit = $g_name;
    }      
    elsif ($type ==3)
    {
                        $g_type = FindWindowByXid('cbType')->GetValue();
                        $g_crit = $g_type;
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
          
          say " state-swt: $swt_state" unless $g_prodswt;
          say  " name-swt: $swt_name" unless $g_prodswt;
          say "type-swt: $swt_type" unless $g_prodswt;
          
          if (( $swt_type ==1 ) && ($swt_state!=1) && ($swt_name!=1))
          {
              $type = 3;
          }
          elsif (( $swt_type != 1 ) && ($swt_state==1) && ($swt_name!=1))
          {
              $type =1;
          }
          elsif (( $swt_type!=1 ) && ($swt_state!=1) && ($swt_name==1))
          { 
              $type = 2;
          }
          
         say "type:$type" unless $g_prodswt;
         return $type;
}


sub CreateString
{
    my @retArray;
    my $id;
    my $cnt = 0;
    
}


sub Exit 
{ 
 say "search exit";
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
