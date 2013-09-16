package ZixWeb::BasicInfoMgr::Bip;

use Mojo::Base 'Mojolicious::Controller';
use utf8;
use DateTime;

################################
# show bip list
################################
sub index {
    my $self = shift;
    my $data;
    my @records;
    my $where;
    my $index = $self->param('index') || 1;
    $data->{id} = $self->param('id');
    my $p = $self->params(
        {
            id => $data->{id},
        }
    );
    my $condition = $p->{condition};
    my $sql = " select id, bi as im_bi, begin, end,
                bjhf_acct, bjhf_period, bjhf_delay, bjhf_nwd,
                round, disable, memo, rownumber() over(order by id desc) as rowid
                from bip $condition";
    my $pager = $self->page_data( $sql, $index );
    for my $key ( keys %$pager ) {
        $data->{$key} = $pager->{$key};
    }
    $data->{params} = $p->{params};
    $self->stash( 'pd' => $data );
}

################################
# add a new bip
################################
sub add {
    my $self = shift;
    my $data;
    my $id          = $self->param('id');
    my $bi          = $self->param('im_bi');
    my $begin       = $self->param('im_begin');
    my $end         = $self->param('im_end');
    my $bjhf_acct   = $self->param('im_bjhf_acct');
    my $bjhf_period = $self->param('im_bjhf_period');
    my $bjhf_delay  = $self->param('im_bjhf_delay');
    my $bjhf_nwd    = $self->param('im_bjhf_nwd');
    my $round       = $self->param('im_round');
    my $disable     = $self->param('im_disable');
    my $memo        = $self->param('memo');
    my $dt          = DateTime->now( time_zone => 'local' );
    my $ts_u        = $dt->ymd('-').' '.$dt->hms(':');
    my $oper_id     = $self->session->{uid};
    my $sql =
"insert into bip (id, bi, begin, end, bjhf_acct, bjhf_period, bjhf_delay, bjhf_nwd, round, disable, memo, oper_id, ts_u)
values ($id, $bi, \'$begin\',\'$end\', $bjhf_acct, \'$bjhf_period\', $bjhf_delay, \'$bjhf_nwd\', \'$round\',\'$disable\',\'$memo\',\'$oper_id\',\'$ts_u\')";
    $self->dbh->begin_work;
    $self->dbh->do($sql) or $self->errhandle($sql);
    $self->dbh->commit;
    $self->updateBi;
    $self->redirect_to('/dimbfj/index');
    $self->redirect_to('/bip/index');
}

################################
# delete a bip
################################
sub delete {
    my $self = shift;
    my $data;
    my $role_id = $self->param('id');
    my $sql = "delete from bip where id = \'$role_id\'";
    $self->dbh->begin_work;
    $self->dbh->do($sql) or $self->errhandle($sql);
    $self->dbh->commit;
    $self->updateBi;
    $self->redirect_to('/bip/index');
}

################################
# edit a bip for modify
################################
sub edit {
    my $self = shift;
    my $role_id = $self->param('id');
    my $data;
    my $role_data = $self->select( "select id, bi as im_bi, begin, end,
                bjhf_acct, bjhf_period, bjhf_delay, bjhf_nwd,
                round, disable, memo from bip where id=$role_id");
    $data->{data} = $role_data->[0];
    $data->{bi_dict} = $self->bi;
    $data->{bfj_acct_dict} = $self->bfj_acct;
    $data->{im_bjhf_period} = $self->dict->{types}->{im_bjhf_period};
    $data->{im_round} = $self->dict->{types}->{im_round};
    $self->stash( 'pd', $data );
}

################################
# update bip information
###############################
sub submit {
    my $self = shift;
    my $data;
    my $id          = $self->param('id');
    my $bi          = $self->param('im_bi');
    my $begin       = $self->param('im_begin');
    my $end         = $self->param('im_end');
    my $bjhf_acct   = $self->param('im_bjhf_acct');
    my $bjhf_period = $self->param('im_bjhf_period');
    my $bjhf_delay  = $self->param('im_bjhf_delay');
    my $bjhf_nwd    = $self->param('im_bjhf_nwd');
    my $round       = $self->param('im_round');
    my $disable     = $self->param('im_disable');
    my $memo        = $self->param('memo');
    my $dt          = DateTime->now( time_zone => 'local' );
    my $ts_u        = $dt->ymd('-').' '.$dt->hms(':');
    my $oper_id  = $self->session->{uid};
    $self->dbh->begin_work;

    my $sql =
"update bip set bi=$bi, begin=\'$begin\', end=\'$end\', bjhf_acct=$bjhf_acct, bjhf_period=\'$bjhf_period\', bjhf_delay=$bjhf_delay, bjhf_nwd=\'$bjhf_nwd\', round='$round',disable='$disable',memo=\'$memo\',oper_id=\'$oper_id\',ts_u=\'$ts_u\'  where id=$id";
    $self->dbh->begin_work;
    $self->dbh->do($sql) or $self->errhandle($sql);
    $self->dbh->commit;
    $self->updateBi;
    $self->redirect_to('/bip/index');
}

#
# 
#
sub input {
    my $self = shift;
    my $data;
    my $id = $self->select("select max(id)+1 as id from bip");
    $data->{id} = $id->[0]->{id} || 1;
    $data->{bi_dict} = $self->bi;
    $data->{bfj_acct_dict} = $self->bfj_acct;
    $data->{im_bjhf_period} = $self->dict->{types}->{im_bjhf_period};
    $data->{im_round} = $self->dict->{types}->{im_round};
    $self->stash( 'pd', $data );
}

1;
