#! /usr/bin/perl

use constant DEBUG => 0;
use strict;
use warnings;
use Data::Dumper;
use utf8;
use XML::Simple;
use Benchmark;
use DBI;

do "./config.pl";
use vars qw(%db_conf);
use vars qw(%files_conf);

my $bm_point00 = new Benchmark;


my $y = 1000;  # множитель, кратно которому будем делать INSERTы в таблицы, а не по 1 строке за 1 раз
my $sth;
# готовим sql для будущего использования
my $sql_domain_all = "INSERT INTO domain_all
	( domain, content_id, block_type )
	VALUES 
	";
my $sql_domain_all_rows = 0;
my $sql_domain_all_ready = 0;
my $sql_ip_all = "INSERT INTO ip_all
	( ip, content_id, block_type )
	VALUES 
	";
my $sql_ip_all_rows = 0;
my $sql_ip_all_ready = 0;
my $sql_subnet_all = "INSERT INTO subnet_all
	( subnet, content_id, block_type )
	VALUES 
	";
my $sql_subnet_all_rows = 0;
my $sql_subnet_all_ready = 0;


my $dbh = DBI->connect("DBI:mysql:dbname=$db_conf{db_name}:hostname=$db_conf{db_host}",$db_conf{db_login},$db_conf{db_password}) or die ("db not connect");
$dbh->do("set names utf8");


# чистим таблицы с данными т.к. быстрее очистить и перезалить, нежели искать и добавлять разницу в новом файле от ркн
clear_tables('domain_all');
clear_tables('ip_all');
clear_tables('subnet_all');


# загружаем файл
my $xml = new XML::Simple;
my $data_xml = $xml->XMLin($files_conf{rkn_dump_file}, ForceArray=> 0, KeyAttr => {});

my $bm_point01 = new Benchmark;
my $bm_diff01 = timediff($bm_point01,$bm_point00);
print "xml parse OK  " . timestr($bm_diff01, ' ') . " seconds\n" if DEBUG;

# разбираем файл с одновременной записью данных в таблицы  
my $data_type = ref($data_xml->{content});
	if($data_type eq 'ARRAY') {
		foreach my $arr (@{$data_xml->{content}}) {
			my %content_data = &parsecontent($arr);
							
			foreach my $domain( @{$content_data{'domains'}} ) {
				$sql_domain_all .= "('$domain', $content_data{'id'},  '$content_data{'block_type'}'),";
				$sql_domain_all_ready = 1;
				$sql_domain_all_rows++;
				# а это использование множителя что задали выше,
				# вставка в ьаблицу не по 1 а по 1000 строк за раз уменьшает время работы скрипта в десятки раз
				if( 0 == $sql_domain_all_rows%$y and $sql_domain_all_ready == 1 ) {
					($sql_domain_all, $sql_domain_all_ready) = &insert_domain($sql_domain_all, $sql_domain_all_ready);
				}
			}
			foreach my $ip( @{$content_data{'ips'}} ) {
				$sql_ip_all .= "('$ip', $content_data{'id'},  '$content_data{'block_type'}'),";
				$sql_ip_all_ready = 1;
				$sql_ip_all_rows++;
				if( 0 == $sql_ip_all_rows%$y and $sql_ip_all_ready == 1 ) {
					($sql_ip_all, $sql_ip_all_ready) = &insert_ip($sql_ip_all, $sql_ip_all_ready);
				}
			}								
			foreach my $subnet( @{$content_data{'subnets'}} ) {
				$sql_subnet_all .= "('$subnet', $content_data{'id'},  '$content_data{'block_type'}'),";
				$sql_subnet_all_ready = 1;
				$sql_subnet_all_rows++;
				if( 0 == $sql_subnet_all_rows%$y and $sql_subnet_all_ready == 1 ) {
					($sql_subnet_all, $sql_subnet_all_ready) = &insert_subnet($sql_subnet_all, $sql_subnet_all_ready);
				}
			}										
		}
	} elsif ( $data_type eq 'HASH' ) {
		print Dumper $data_xml->{content} if DEBUG;
		# to do
		# таких записей в файле выгрузки пока не встречается
	}


if( $sql_domain_all_ready == 1 ) {
	($sql_domain_all, $sql_domain_all_ready) = &insert_domain($sql_domain_all, $sql_domain_all_ready);
}
if( $sql_ip_all_ready == 1 ) {
	($sql_ip_all, $sql_ip_all_ready) = &insert_domain($sql_ip_all, $sql_ip_all_ready);
}
if( $sql_subnet_all_ready == 1 ) {
	($sql_subnet_all, $sql_subnet_all_ready) = &insert_domain($sql_subnet_all, $sql_subnet_all_ready);
}
									
$dbh->disconnect;

my $bm_point02 = new Benchmark;
my $bm_diff02 = timediff($bm_point02,$bm_point00);
print "Data preparation took " . timestr($bm_diff02, 'all') . " seconds\n" if DEBUG;

# the END


###### subs ############################################################################

sub clear_tables {
	my ($table_name) = @_;
	my $sql = "DELETE FROM $table_name WHERE id > 0";
	my $sth = $dbh->do($sql) or print "ERROR IN SQL\n $sql \n";
}


sub insert_domain {
	my ($sql_domain_all, $sql_domain_all_ready) = @_;
	
	chop($sql_domain_all);
	my $sth = $dbh->do($sql_domain_all) or print "ERROR IN SQL sql_domain_all \n";
	$sql_domain_all = "INSERT INTO domain_all
	( domain, content_id, block_type )
	VALUES 
	";
	$sql_domain_all_ready = 0;
	return ($sql_domain_all, $sql_domain_all_ready);
}


sub insert_ip {
	my ($sql_ip_all, $sql_ip_all_ready) = @_;
	
	chop($sql_ip_all);
	my $sth = $dbh->do($sql_ip_all) or print "ERROR IN SQL sql_ip_all \n";
	$sql_ip_all = "INSERT INTO ip_all
	( ip, content_id, block_type )
	VALUES 
	";
	$sql_ip_all_ready = 0;
	return ($sql_ip_all, $sql_ip_all_ready);
}


sub insert_subnet {
	my ($sql_subnet_all, $sql_subnet_all_ready) = @_;
	
	chop($sql_subnet_all);
	my $sth = $dbh->do($sql_subnet_all) or print "ERROR IN SQL sql_subnet_all \n";
	$sql_subnet_all = "INSERT INTO subnet_all
	( subnet, content_id, block_type )
	VALUES 
	";
	$sql_subnet_all_ready = 0;
	return ($sql_subnet_all, $sql_subnet_all_ready);
}



sub parsecontent {
	my $content = shift;
	my @domains = ();
	my @ips = ();
	my @subnets = ();
	my $content_id = $content->{id};
	my $content_blockType = 'default';
	$content_blockType = $content->{blockType} or $content_blockType = 'default';
	
    my %content_data = (
		'id'    => $content_id,
        'block_type'  => $content_blockType
	);	

	# domains parsing
	if (defined( $content->{domain} )) {
		if (ref($content->{domain}) eq 'ARRAY') {
			foreach my $domain (@{$content->{domain}}) {
				if(ref($domain) eq 'HASH') {
					push @domains, $domain->{content};
					print "$domain->{content} \n" if DEBUG;
				} else {
					push @domains, $domain;
					print "$domain \n" if DEBUG;
				}
			}
		} elsif (ref($content->{domain}) eq 'HASH') {
			push @domains, $content->{domain}->{content};
			print "$content->{domain}->{content} \n" if DEBUG;
		} else {
			push @domains, $content->{domain};
			print "$content->{domain} \n" if DEBUG;
		}
	}
	$content_data{'domains'} = \@domains;
	print Dumper $content_data{'domains'} if DEBUG;
		
	# IPs parsing
	if (defined( $content->{ip} ) ) {
		if (ref($content->{ip}) eq 'ARRAY' ) {
			foreach my $ip (@{$content->{ip}}) {
				if (ref($ip) eq 'HASH') {
					push @ips, $ip->{content};
				} else {
					push @ips, $ip;
				}
			}
		} elsif (ref($content->{ip}) eq 'HASH') {
			push @ips, $content->{ip}->{content};
		} else {
			push @ips, $content->{ip};
		}
	}
	$content_data{'ips'} = \@ips;
	print Dumper $content_data{'ips'} if DEBUG;

	# subnets parsing
	if (defined( $content->{ipSubnet} ) ) {
		if (ref($content->{ipSubnet}) eq 'ARRAY' ) {
			foreach my $subnet ( @{$content->{ipSubnet}} ) {
				if (ref($subnet) eq 'HASH') {
					push @subnets, $subnet->{content};
				} else {
					push @subnets, $subnet;
				}
			}
		} elsif (ref($content->{ipSubnet}) eq 'HASH') {
			push @subnets, $content->{ipSubnet}->{content};
		} else {
			push @subnets, $content->{ipSubnet};
		}
	}
	$content_data{'subnets'} = \@subnets;
	print Dumper $content_data{'subnets'} if DEBUG;
	
	return (%content_data);
	
}
