package ZixWeb::BasicInfoMgr::Acctzyzj;

use Mojo::Base 'Mojolicious::Controller';
use utf8;

################################
# show index list
################################
sub index {
    my $self = shift;
    my $data;

    my $index = $self->param('index') || 1;
    $data->{id} = $self->param('id');
    
    my $p = $self->params(
        {
            id => $data->{id},
        }
    );
    my $condition = $p->{condition};
    my $sql = "select id, b_acct, acct_name, b_name, memo, rownumber() over(order by id desc) as rowid from dim_zyzj_acct $condition";
    my $pager = $self->page_data( $sql, $index );
    for my $key ( keys %$pager ) {
        $data->{$key} = $pager->{$key};
    }
    $data->{params} = $p->{params};
    $self->stash( 'pd' => $data );

}

################################
# add dim_p data
################################
sub add {
    my $self = shift;

    my $id        = $self->param("id");
    my $b_acct    = $self->param("b_acct");
    my $acct_name = $self->param("acct_name");
    my $b_name    = $self->param("b_name");
    my $memo      = $self->param("memo");
    my $acct_id = $self->select("select max(id)+1 as id from dim_acct");
    $acct_id = $acct_id->[0]->{id} || 1;
    my $sql_acct = 'insert into dim_acct (id, sub_type, sub_id) values ('
      . $acct_id
      . ', '
      . 2
      . ', '
      . $id
      . ')';
    my $sql =
'insert into dim_zyzj_acct (id, b_acct, acct_name, b_name, memo, valid) values (\''
      . $id
      . '\', \''
      . $b_acct
      . '\', \''
      . $acct_name
      . '\', \''
      . $b_name
      . '\', \''
      . $memo . '\', 1)';
    $self->dbh->begin_work;
    $self->dbh->do($sql) or $self->errhandle($sql);
    $self->dbh->do($sql_acct) or $self->errhandle($sql_acct);
    $self->dbh->commit;
    $self->updateZyzjacct;
    $self->redirect_to('/acctzyzj/index');

}

##########################
# edit acctzyzj for modify
##########################
sub edit {
    my $self = shift;
    my $id   = $self->param("id");
    my $data;
    my $acctzyzj_data = $self->select( "select id, b_acct, acct_name, b_name, memo from dim_zyzj_acct where id=$id");
    $data->{acctzyzj_data} = $acctzyzj_data->[0];
    $data->{id} = $id;
    $self->stash( 'pd', $data );
}

##########################
# update acctzyzj acct info
##########################
sub submit {
    my $self = shift;
    my $data;

    my $id        = $self->param("id");
    my $b_acct    = $self->param("b_acct");
    my $acct_name = $self->param("acct_name");
    my $b_name    = $self->param("b_name");
    my $memo      = $self->param("memo");

    my $sql =
        "update dim_zyzj_acct set b_acct=\'" 
      . $b_acct
      . "\', acct_name=\'"
      . $acct_name
      . "\', b_name=\'"
      . $b_name
      . "\', memo=\'"
      . $memo
      . "\'  where id=\'"
      . $id . "\'";
    $self->dbh->begin_work;
    $self->dbh->do($sql) or $self->errhandle($sql);
    $self->dbh->commit;
    $self->updateZyzjacct;
    $self->redirect_to('/acctzyzj/index');

}

##########################
# delete acctzyzj acct info
##########################
sub delete {
    my $self = shift;
    my $data;
    my $id = $self->param("id");
    my $sql = "delete from dim_zyzj_acct where id = '$id'";
    $self->dbh->begin_work;
    $self->dbh->do($sql) or $self->errhandle($sql);
    $self->dbh->commit;
    $self->updateZyzjacct;
    $self->redirect_to('/acctzyzj/index');

}

sub input {
    my $self = shift;
    my $data;
    my $id = $self->select("select max(id)+1 as id from dim_zyzj_acct");
    $data->{id} = $id->[0]->{id} || 1;
    $self->stash(pd => $data);
}

1;

