package ZixWeb::BasicInfoMgr::Dimp;

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
    my $sql = "select id, name, memo, rownumber() over(order by id desc) as rowid from dim_p $condition";
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

    my $id   = $self->param("id");
    my $name = $self->param("name");
    my $memo = $self->param("memo");

    my $sql =
        'insert into dim_p(id, name, memo) values (\'' 
      . $id 
      . '\', \'' 
      . $name
      . '\', \''
      . $memo . '\')';
    $self->dbh->begin_work;
    $self->dbh->do($sql) or $self->errhandle($sql);
    $self->dbh->commit;
    $self->updateP;
    $self->redirect_to('/dimp/index');

}

##########################
# edit dimp for modify
##########################
sub edit {
    my $self = shift;
    my $id   = $self->param("id");
    my $data;
    my $dimp_data = $self->select("select * from dim_p where id = $id");
    $data->{dimp_data} = $dimp_data->[0];
    $self->stash( 'pd', $data );
}

sub submit {
    my $self = shift;
    my $data;
    my $id   = $self->param("id");
    my $name = $self->param("name");
    my $memo = $self->param("memo");

    my $sql =
        "update dim_p set name=\'" 
      . $name
      . "\',  memo=\'"
      . $memo . "\'"
      . " where id=\'"
      . $id . "\'";

    $self->dbh->begin_work;
    $self->dbh->do($sql) or $self->errhandle($sql);
    $self->dbh->commit;
    $self->updateP;
    $self->redirect_to('/dimp/index');

}

sub delete {
    my $self = shift;
    my $data;
    my $id = $self->param("id");

    # begin work
    $self->dbh->begin_work;

    my $sql = "delete from dim_p where id = '$id'";
    $self->dbh->do($sql) or $self->errhandle($sql);
    $self->dbh->commit;
    $self->updateP;
    $self->redirect_to('/dimp/index');

}

sub input {
    my $self = shift;
    my $data;
    my $id = $self->select("select max(id)+1 as id from dim_p");
    $data->{id} = $id->[0]->{id} || 1;
    $self->stash(pd => $data);
}

1;

