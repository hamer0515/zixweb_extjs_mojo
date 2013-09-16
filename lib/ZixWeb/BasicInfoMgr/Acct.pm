package ZixWeb::BasicInfoMgr::Acct;

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
    my $sql = " select acct.id as id, acct.sub_id as sub_id, acct.sub_type as sub_type,
                bfj_acct.b_acct as b_acct, bfj_acct.acct_name as acct_name,
                bfj_acct.b_name as b_name, bfj_acct.memo as memo
                from dim_acct acct, dim_bfj_acct bfj_acct
                where acct.sub_type=1 and acct.sub_id=bfj_acct.id";
    $sql .= " and acct.id=$data->{id}" if $condition;
    $sql .= "   union
                select acct.id as id, acct.sub_id as sub_id, acct.sub_type as sub_type,
                zyzj_acct.b_acct as b_acct, zyzj_acct.acct_name as acct_name,
                zyzj_acct.b_name as b_name, zyzj_acct.memo as memo
                from dim_acct acct, dim_zyzj_acct zyzj_acct
                where acct.sub_type=2 and acct.sub_id=zyzj_acct.id";
    $sql .= " and acct.id=$data->{id}" if $condition;
    $sql = "select id, sub_id, sub_type, b_acct, acct_name, b_name, memo, rownumber() over() as rowid from ($sql)";
    my $pager = $self->page_data( $sql, $index );
    for my $key ( keys %$pager ) {
        $data->{$key} = $pager->{$key};
    }
    $data->{params} = $p->{params};
    $self->stash( 'pd' => $data );

}

##########################
# delete acct acct info
##########################
sub delete {
    my $self = shift;
    my $data;
    my $id = $self->param("id");
    my $type = $self->param("type");
    my $sub_id = $self->param("sub_id");
    my $sql_acct = "delete from dim_acct where id = $id";
    my $tbl = $type==1?"dim_bfj_acct":"dim_zyzj_acct";
    my $sql = "delete from $tbl where id = '$sub_id'";
    $self->dbh->begin_work;
    $self->dbh->do($sql) or $self->errhandle($sql);
    $self->dbh->do($sql_acct) or $self->errhandle($sql_acct);
    $self->dbh->commit;
    $self->redirect_to('/acct/index');

}

1;

