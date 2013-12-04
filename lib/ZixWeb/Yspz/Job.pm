package ZixWeb::Yspz::Job;

use Mojo::Base 'Mojolicious::Controller';

sub job {
	my $self = shift;
	my $data;
	my $id = $self->param('id');
	my $sql =
"select id, type, date,index, total, fail, succ, ts_u, ts_c, status as jstatus from load_job where mission_id = $id order by index";
	$data->{data} = $self->select($sql);

	$self->render( json => $data );
}

1;
