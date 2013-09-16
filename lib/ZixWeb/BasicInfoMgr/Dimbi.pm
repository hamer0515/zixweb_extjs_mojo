package ZixWeb::BasicInfoMgr::Dimbi;

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
    my $sql = "select id, type as dim_bi_type, name, memo, rownumber() over(order by id desc) as rowid from dim_bi $condition";
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
    my $data;
    my @record;

    my $id   = $self->param("id");
    my $name = $self->param("name");
    my $type = $self->param("t");
    my $memo = $self->param("memo");

    my $sql =
        'insert into dim_bi(id, type, name, memo) values (\'' 
      . $id 
      . '\', \''
      . $type
      . '\', \''
      . $name
      . '\', \''
      . $memo . '\')';
    $self->dbh->begin_work;
    $self->dbh->do($sql) or $self->errhandle($sql);
    $self->dbh->commit;
    $self->updateBi;
    $self->redirect_to('/dimbi/index');

}

##########################
# edit dimbi for modify
##########################
sub edit {
    my $self = shift;
    my $id   = $self->param("id");
    my $data;
    my $dimbi_data = $self->select( "select id, type, name, memo from dim_bi where id=$id");
    $data->{dimbi_data} = $dimbi_data->[0];
    $data->{t_dict} = $self->dict->{types}->{dim_bi_type};
    $self->stash( 'pd', $data );
}

sub submit {
    my $self = shift;
    my $data;
    my $id   = $self->param("id");
    my $type = $self->param("t");
    my $name = $self->param("name");
    my $memo = $self->param("memo");
    my $sql =
        "update dim_bi set name=\'" 
      . $name
      . "\', type=\'$type"
      . "\',  memo=\'"
      . $memo . "\'"
      . " where id="
      . $id;
    $self->dbh->begin_work;
    $self->dbh->do($sql) or $self->errhandle($sql);
    $self->dbh->commit;
    $self->updateBi;
    $self->redirect_to('/dimbi/index');
}

sub delete {
    my $self = shift;
    my $data;
    my $id = $self->param("id");
    my $sql = "delete from dim_bi where id = '$id'";
    $self->dbh->begin_work;
    $self->dbh->do($sql) or $self->errhandle($sql);
    $self->dbh->commit;
    $self->updateBi;
    $self->redirect_to('/dimbi/index');

}

sub input {
    my $self = shift;
    my $data;
    my $id = $self->select("select max(id)+1 as id from dim_bi");
    $data->{id} = $id->[0]->{id};
    $data->{t_dict} = $self->dict->{types}->{dim_bi_type};
    $self->stash(pd => $data);
}

1;

