package ZixWeb::BookMgr::index;

use Mojo::Base 'Mojolicious::Controller';
use utf8;
use Encode qw/encode decode/;
use JSON::XS;
use boolean;

use constant {
    DEBUG  => $ENV{BOOK_DEBUG} || 0 ,
};

BEGIN {
    require Data::Dump if DEBUG;
}
use Data::Dump;
# result:
#{
#  1 => {
#    1002 => {
#      "01"   => {
#                  d => "0.00",
#                  j => "65,7963.28",
#                  name => "\x{5907}\x{4ED8}\x{91D1}\x{5B58}\x{6B3E}-1002.01",
#                  url => "deposit_bfj",
#                },
#      ...
#      "d"    => "0.00",
#      "j"    => "65,7963.28",
#      "name" => "\x{94F6}\x{884C}\x{5B58}\x{6B3E}-1002",
#    },
#    ...
#  total => ["\x{6C47}\x{603B}", "327,2959.52", "327,2959.52"],
#}
sub get_books {
    my $self  = shift;
    my $type  = shift;
    my $result = [];
    my $books = $self->dict->{book};
    my $data = {};
    my @books;
    if ($type eq 'all') {
        @books = sort { $books->{$a}[2] cmp $books->{$b}[2] } keys %$books;
    } elsif ($type eq 'bfj') {
        @books = grep {$books->{$_}[4] == 1} sort { $books->{$a}[2] cmp $books->{$b}[2] } keys %$books;
    } elsif ($type eq 'zyzj') {
        @books = grep {$books->{$_}[4] == 0} sort { $books->{$a}[2] cmp $books->{$b}[2] } keys %$books;
    }
    # 从数据库里面获得数据
    for my $book (@books){
        my $d = $self->select('select sum(j) as j, sum(d) as d from sum_' . $books->{$book}[0])->[0];
        $d->{j} ||= 0;
        $d->{d} ||= 0;
        $data->{$book}->{j} = $d->{j}; 
        $data->{$book}->{d} = $d->{d};
    }
    my $total = { j => 0, d => 0, text => '汇总', leaf => true };
    
    # 组织树结构
    my $tree = {};
    for my $book ( @books ) {
        my $bn = $books->{$book}->[0];
        my $cls = $books->{$book}->[3];
        my $name = $books->{$book}->[1];
        my $code = $books->{$book}->[2];
        my $row = $data->{$book};
        
        $total->{j} += $row->{j};
        $total->{d} += $row->{d};
        $tree->{$cls}{j} += $row->{j};
        $tree->{$cls}{d} += $row->{d};
        $tree->{$cls}{text} = $self->dict->{types}{class}{$cls}.'-'.$cls;
        my @name = split '-', $name;
        my @code = split '\.', $code;
        $tree->{$cls}{$code[0]}{j} +=  $row->{j};
        $tree->{$cls}{$code[0]}{d} +=  $row->{d};
        $tree->{$cls}{$code[0]}{text} =  $name[0].'-'.$code[0];
        
        if($#name == 0) {
          $tree->{$cls}->{$code[0]}->{url} = $bn;
          $tree->{$cls}->{$code[0]}->{leaf} = true;
        }
        if($#name > 0) {
          $tree->{$cls}->{$code[0]}->{$code[1]}->{j} +=  $row->{j};
          $tree->{$cls}->{$code[0]}->{$code[1]}->{d} +=  $row->{d};
          $tree->{$cls}->{$code[0]}->{$code[1]}->{text} =  $name[1].'-'.join '.', @code[0..1];
          if($#name == 1){
            $tree->{$cls}->{$code[0]}->{$code[1]}->{url} = $bn;
            $tree->{$cls}->{$code[0]}->{$code[1]}->{leaf} = true;
          }
        }
        if($#name > 1) {
          $tree->{$cls}->{$code[0]}->{$code[1]}->{$code[2]}->{j} +=  $row->{j};
          $tree->{$cls}->{$code[0]}->{$code[1]}->{$code[2]}->{d} +=  $row->{d};
          $tree->{$cls}->{$code[0]}->{$code[1]}->{$code[2]}->{text} =  $name[2].'-'.join '.', @code[0..2];
          if($#name == 2){
            $tree->{$cls}->{$code[0]}->{$code[1]}->{$code[2]}->{url} = $bn;
            $tree->{$cls}->{$code[0]}->{$code[1]}->{$code[2]}->{leaf} = true;
          }
        }
    }
    $tree->{total} = $total;
    
    #转换为extjs要求格式
    return &_trans($tree);
}

sub all {
    my $self  = shift;
    my $data  = $self->get_books('all');
    
    warn "package: ", __FILE__, "\ndata:", Data::Dump->dump($data) if DEBUG;

    $self->render(json => $data->{children});
}

sub bfj {
    my $self  = shift;
    my $data  = $self->get_books('bfj');
    
    warn "package: ", __FILE__, "\ndata:", Data::Dump->dump($data) if DEBUG;
    
    $data->{title} = '科目余额表-备付金帐套';
    #$self->stash( sum_book => $data );
    $self->render(json => $data->{children});
}

sub zyzj {
    my $self  = shift;
    my $data  = $self->get_books('zyzj');
    
    warn "package: ", __FILE__, "\ndata:", Data::Dump->dump($data) if DEBUG;
    
    $data->{title} = '科目余额表-自有资金帐套';
    #$self->stash( sum_book => $data );
    $self->render(json => $data->{children});
}

sub _trans{
	my $href = shift;
	my $record = {};
	for my $key(sort keys %$href){
		if(ref $href->{$key} eq 'HASH'){
			push @{$record->{children}}, &_trans($href->{$key})
		}else{
			$record->{$key} = $href->{$key};
		}
	}
	return $record;
}


1;