package User;
use strict;
use base qw(CGI::Application);
use CGI::Application::Plugin::DBH        (qw/dbh_config dbh/);

sub new
{
   my ($class, $dsn, $dbuser, $dbpassword) = @_;
   my $self = bless {}, $class;
   $self->{dsn} = $dsn;
   $self->{dbuser} = $dbuser;
   $self->{dbpassword} = $dbpassword; 
   $self->dbh_config( $self->{dsn}, $self->{dbuser}, $self->{dbpassword});
   
   return $self;
} 


sub _changeDate{
        my $date = shift;
        my @adate=split (/\//, $date);
        my $ndate=$adate[2]."-".sprintf("%02d", $adate[1])."-".sprintf("%02d",$adate[0]);
        return $ndate;
}


#------------------------------------------------------------------------------
# Create a new user record in the database
#------------------------------------------------------------------------------
sub _create_user {
    my $self = shift;
    my $q    = $self->query;

    my $sql = "insert into user (user_firstname, user_lastname, user_address, user_birthdate) values (?, ?, ?, ?)";

    $self->dbh->{PrintError} = 0;
    $self->dbh->{RaiseError} = 1;
 
    #my $dateformat = _changeDate($q->param('user_birthdate'));
 
    $self->dbh->do(
        $sql, undef,
        ($q->param('user_firstname'),$q->param('user_lastname'),$q->param('user_address'),$q->param('user_birthdate')
        )

    ); 

}

#------------------------------------------------------------------------------
# Update an existing user record in the database
#------------------------------------------------------------------------------
sub _update_user {
    my $self = shift;
    my $q    = $self->query;

    $self->dbh->{PrintError} = 0;
    $self->dbh->{RaiseError} = 1;

    my @params = ($q->param("user_firstname"), $q->param("user_lastname"),
                  $q->param("user_address") || undef,
                  $q->param("user_birthdate") || 'n');

    my $sql = "update user
               set    user_firstname         = ?,
                      user_lastname          = ?,
                      user_address              = ?,
                      user_birthdate = ?";


    # Now add the where clause
    $sql .= " where user_id = ?";

    $self->dbh->do($sql, undef, @params, $q->param('user_id'));
}


#------------------------------------------------------------------------------
# Delete an existing user record in the database
#------------------------------------------------------------------------------
sub _delete_user {
    my $self = shift;
    my $q    = $self->query;

    $self->dbh->{PrintError} = 0;
    $self->dbh->{RaiseError} = 1;

    my $sql = "delete from user ";

    # Now delete the where clause
    $sql .= " where user_id = ?";

    $self->dbh->do($sql, {}, $q->param('user_id'));
}



#------------------------------------------------------------------------------
# Retrieve the list of users from the database
#------------------------------------------------------------------------------
sub _get_users {
    my $self = shift;
       
    my $sql  = "select * from user order by user_firstname";
    $self->dbh->{PrintError} = 0;
    $self->dbh->{RaiseError} = 1;

    my $sth = $self->dbh->prepare($sql);
    $sth->execute();
    my $rs = $sth->fetchall_arrayref(
        {
            user_id        => 1,
            user_firstname => 1,
            user_lastname  => 1,
            user_address   => 1,
            user_birthdate => 1
        }
    );
    return $rs;
}

#------------------------------------------------------------------------------
# Retrieve the record for a given user_id
#------------------------------------------------------------------------------
sub _retrieve_user_details {
    my $self    = shift;
    my $user_id = shift;
    my $sql     = "select * from user where user_id = ?";
    $self->dbh->{PrintError} = 0;
    $self->dbh->{RaiseError} = 1;

    my $sth = $self->dbh->prepare($sql);
    $sth->execute($user_id);
    my $rs = $sth->fetchrow_hashref();

    # Save each column (field) value in CGI::Application parameter
    foreach my $user_field (keys %$rs) {
       $self->param($user_field, $rs->{$user_field});
    }
}
1;
