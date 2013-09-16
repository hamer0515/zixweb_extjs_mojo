package ZixWeb::MaintenanceMgr::TBSP;

use Mojo::Base 'Mojolicious::Controller';
use utf8;
use Digest::MD5;

use constant {
  DEBUG  => $ENV{MAINTENCE_DEBUG} || 0 ,
};

BEGIN {
    require Data::Dump if DEBUG;
}
sub tbsp {
    my $self = shift;
    my $data;
    $data->{data} = $self->select("select  tbsp_id as id, tbsp_name as name, 
	tbsp_page_size as page_size, tbsp_extent_size as extent_size, 
	tbsp_state as state, tbsp_total_pages as total_pages,
	tbsp_usable_pages as usable_pages,  tbsp_used_pages as used_pages,
	tbsp_free_pages as free_pages, tbsp_page_top as page_top,
	tbsp_type as type, tbsp_using_auto_storage as using_auto_storage,
	tbsp_utilization_percent as utilization_percent
	from sysibmadm.tbsp_utilization
        order by type, using_auto_storage, utilization_percent desc");
    $self->stash( 'pd', $data );
}

sub adjust_tbsp {
    my $self = shift;
    my $id = $self->param("id");
    my $data;
    $data->{data} = $self->select("select  tbsp_id as id, tbsp_name as name, 
	tbsp_page_size as page_size, tbsp_extent_size as extent_size, 
	tbsp_state as state, tbsp_total_pages as total_pages,
	tbsp_usable_pages as usable_pages,  tbsp_used_pages as used_pages,
	tbsp_free_pages as free_pages, tbsp_page_top as page_top,
	tbsp_type as type, tbsp_using_auto_storage as using_auto_storage,
	tbsp_utilization_percent as utilization_percent
	from sysibmadm.tbsp_utilization
        where tbsp_id=$id");
    $data->{container} = $self->select("select container_name, substr(container_type,1,4) as container_type,
                                        total_pages as size, usable_pages as usable, accessible
                                        from sysibmadm.container_utilization
                                        where tbsp_id=$id");
    $self->stash( 'pd', $data );
}

sub add_task {
    my $self = shift;
    my $type = $self->param('type');
    my $tbsp = $self->param('tbsp');
    my $container = $self->param('container');
    $container =~ s/^\s+//;
    $container =~ s/\s+$//;
    my $extentSize = $self->param('extentSize');
    $self->render( json => { result => 0 } );
}

sub list_task {
    
}

sub commit_task {
    
}

1;
