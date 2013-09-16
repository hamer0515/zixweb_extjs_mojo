package ZixWeb::BasicInfoMgr::Dictyspz;

use Mojo::Base 'Mojolicious::Controller';
use utf8;

################################
# show index list
################################
sub index {
    my $self = shift;
    my $data;

    my $index = $self->param('index') || 1;
    $data->{code} = $self->param("code");
    
    my $p = $self->params(
        {
            code => $data->{code},
        }
    );
    my $condition = $p->{condition};
    my $sql = "select code, name, memo, rownumber() over(order by code desc) as rowid from dict_yspz $condition";
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

    my $code = $self->param("code");
    my $name = $self->param("name");
    my $memo = $self->param("memo");
    my $sql =
        'insert into dict_yspz (code, name, memo) values (\'' 
      . $code 
      . '\', \''
      . $name
      . '\', \''
      . $memo . '\')';
    $self->dbh->begin_work;
    $self->dbh->do($sql) or $self->errhandle($sql);
    $self->dbh->commit;
    $self->updateYstype;
    $self->redirect_to('/dictyspz/index');

}

##########################
# edit dictyspz for modify
##########################
sub edit {
    my $self = shift;
    my $code   = $self->param("code");
    my $data;
    my $dictyspz_data = $self->select( "select code, name, memo from dict_yspz where code=$code");
    $data->{dictyspz_data} = $dictyspz_data->[0];
    $self->stash( 'pd', $data );
}

sub submit {
    my $self = shift;
    my $data;

    my $code = $self->param("code");
    my $name = $self->param("name");
    my $memo = $self->param("memo");

    my $sql =
        "update dict_yspz set name=\'" 
      . $name
      . "\', memo=\'"
      . $memo
      . "\'  where code=\'"
      . $code . "\'";
    $self->dbh->begin_work;
    $self->dbh->do($sql) or $self->errhandle($sql);
    $self->dbh->commit;
    $self->updateYstype;
    $self->redirect_to('/dictyspz/index');

}

sub delete {
    my $self = shift;
    my $data;
    my $code = $self->param("code");
    my $sql = "delete from dict_yspz where code = '$code'";
    $self->dbh->begin_work;
    $self->dbh->do($sql) or $self->errhandle($sql);
    $self->dbh->commit;
    $self->updateYstype;
    $self->redirect_to('/dictyspz/index');

}

sub input {
    my $self = shift;
    my $data;
    my $id = $self->select("select max(code)+1 as code from dict_yspz");
    $data->{code} = $id->[0]->{code} || 1;
    $self->stash(pd => $data);
}

1;

