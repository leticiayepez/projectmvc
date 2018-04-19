package ManagerUser;
use strict;
use base qw(CGI::Application);
use CGI::Application::Plugin::TT;
use CGI::Application::Plugin::ConfigAuto (qw/cfg cfg_file/);
use lib '/var/www/html/projectx/kernel/system';
use User;

#------------------------------------------------------------------------------
# Define our run modes
#------------------------------------------------------------------------------
sub setup {
    my $self = shift;
    $self->start_mode('list_users');
    $self->mode_param('rm');
    $self->run_modes(
        'display_user_form' => 'display_user_form',
        'maintain_user'     => 'maintain_user',
        'list_users'        => 'list_users',
        'get_user_details'  => 'get_user_details',
        'delete_user'       => 'delete_user' 
    );
}

#------------------------------------------------------------------------------
# Execute the following before we execute the requested run mode
#------------------------------------------------------------------------------
sub cgiapp_init {
    my $self = shift;

   # Configure the template
    $self->tt_config(
              TEMPLATE_OPTIONS => {
                        INCLUDE_PATH => '/var/www/html/projectx/kernel/output/templates/',
                        POST_CHOMP   => 1,
                        #PRE_PROCESS => 'header.tmpl',
                        #POST_PROCESS => 'footer.tmpl',
                        FILTERS => {
                                     'currency' => sub { sprintf('$ %0.2f', @_) },
                        },
              },
    );
}

sub cgiapp_prerun {
    my $self = shift;
    $self->tmpl_path($self->cfg('template_path'));
    $self->{user}  = User->new( $self->cfg('dsn'), $self->cfg('user'), $self->cfg('password')); 
}

#------------------------------------------------------------------------------
# Display the form for creating/maintaining users
#------------------------------------------------------------------------------
sub display_user_form {
    my $self = shift;
    my $errs = shift;
    my $q    = $self->query;

    my $user_id  = $q->param('user_id') || 0;
    # If we have a user id, then get the user's details
    $self->{user}->_retrieve_user_details($user_id) if ($user_id);

    my %detailu;
    ## Populate the template
    my @varUser=qw(user_firstname user_lastname user_address user_birthdate message);
    foreach my $form_val(@varUser){ ##qw(user_firstname user_lastname user_address user_birthdate message) {
        $detailu{$form_val} = $self->{user}->param($form_val) || '';
    }
    $detailu{'user_id'} = $user_id;
    $detailu{'content_page'} = 'pageform.tmpl'; 
    $detailu{$errs} if $errs;
        
    #display the form
    #return $self->tt_process('user_form_toolkit.tmpl', \%detailu);

    return $self->tt_process('maindefault.tmpl', \%detailu); 
}

#------------------------------------------------------------------------------
# Process the submitted form
#------------------------------------------------------------------------------
sub maintain_user {
    my $self = shift;
    my $q    = $self->query;

    # validate the input
    use CGI::Application::Plugin::ValidateRM (qw/check_rm/);
    my ($results, $err_page) = $self->check_rm('display_user_form', '_user_profile');
    
    return $err_page if $err_page;

    # if the user_id is zero, then we create a new user, otherwise we
    # update the user associated with the id
    if ($q->param('user_id') == 0) {
        $self->{user}->_create_user();
    } else {
        $self->{user}->_update_user();
    }

    $self->{user}->param('message', 'The user was saved successfully.');
    $self->display_user_form();
}


#------------------------------------------------------------------------------
# Process the submitted form
#------------------------------------------------------------------------------
sub delete_user {
    my $self = shift;
    my $q    = $self->query;

    # if the user_id is not zero, then delete the user 
    if ($q->param('user_id') != 0) {
        $self->{user}->_delete_user();
    }

    $self->list_users;
}



#------------------------------------------------------------------------------
# List users for editing
#------------------------------------------------------------------------------
sub list_users {
    my $self     = shift;
    my $users = $self->{user}->_get_users();

    my %listu = (
        listuser => $users,
        content_page => 'pagelist.tmpl' 
    );
 
    return $self->tt_process('maindefault.tmpl', \%listu);
    #return $self->tt_process('user_list_toolkit.tmpl', \%listu);
}

#------------------------------------------------------------------------------
# Rules for validating the submitted form parameters
#------------------------------------------------------------------------------
sub _user_profile {
    my $self = shift;
    return {
        required     => [qw( user_firstname user_lastname user_id )],
        optional     => [qw( user_address user_birthdate )],
        filters           => ['trim'],
        constraints       => { },
        msgs => {
            any_errors  => 'some_errors',
            prefix      => 'err_',
            constraints => { }
        }
    };
}

1;
