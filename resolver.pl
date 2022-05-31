#! /usr/bin/perl

use constant DEBUG => 0;
use strict;
use warnings;
use Data::Dumper;
#use utf8;
use Net::DNS::Async;
use Benchmark;
use DBI;
use URI::UTF8::Punycode;  # использую v 0.97   https://metacpan.org/pod/URI::UTF8::Punycode

do "./config.pl";
use vars qw(%db_conf);
use vars qw(%files_conf);

my $bm_point00 = new Benchmark;

my %dnscache = ();
my @all_ip = ();
my $domain_punycode = '';
my $domain_punycode_part = '';

my $dbh = DBI->connect("DBI:mysql:dbname=$db_conf{db_name}:hostname=$db_conf{db_host}",$db_conf{db_login},$db_conf{db_password}) or die ("db not connect");
$dbh->do("set names utf8");

my $sql1 = "SELECT 
CASE
	WHEN block_type = 'domain-mask'
	THEN SUBSTRING(domain, 3)
	ELSE domain
END AS domain
FROM domain_all
GROUP BY domain
";

my $sth1 = $dbh->prepare($sql1) or die "Couldn't prepare statement: ".$dbh->errstr;
$sth1->execute() or die "Couldn't execute statement: ".$sth1->errstr.print "\n sql1 problem \n";

my $bm_point01 = new Benchmark;
my $bm_diff01 = timediff($bm_point01,$bm_point00);
print "We have data from mysql.  " . timestr($bm_diff01, 'all') . " seconds\n" if DEBUG;


my $c = new Net::DNS::Async(QueueSize => 100, Retries => 2);
my @query= ();

while ( my @row1 = $sth1->fetchrow_array ) {
	$domain_punycode = '';
	$query[0] = $row1[0];
	$query[1] = 'A';
	if ($row1[0] =~ /[А-Я,а-я]/) {
		my @split_arr = split('\.', $row1[0]);
		foreach my $domain_part (@split_arr) {
			my $domain_punycode_part = puny_enc($domain_part);
			$domain_punycode .= $domain_punycode_part.".";
		}
		chop ($domain_punycode);
		$query[0] = $domain_punycode;
	}

   $c->add(\&resolv_callback, @query);
   

}    

$c->await();

my $bm_point03 = new Benchmark;
my $bm_diff03 = timediff($bm_point03,$bm_point00);
print "We have all resolv and go make INSERTs.  " . timestr($bm_diff03, 'all') . " seconds\n" if DEBUG;

# чистим таблицу resolv_ip т.к. быстрее очистить и заполнить заново, нежели искать разницу в старых и новых данных
my $sql = "DELETE FROM ip_resolv WHERE id > 0";
my $sth = $dbh->do($sql) or print "ERROR IN SQL\n $sql \n";

# готовим sql-запрос и параметры для сохранения в таблицу результатов ресолва не по 1 а по 1000 строк за раз
my $sql_ip_all = "INSERT INTO ip_resolv (ip) VALUES ";
my $sql_ip_all_rows = 0;
my $sql_ip_all_ready = 0;
my $y = 1000;

# в цикле добавляем VALUES в sql-запрос
foreach my $ip (@all_ip) {
	$sql_ip_all .= "('$ip'),";
	$sql_ip_all_ready = 1;
	$sql_ip_all_rows++;
	# ... и если VALUES в запросе кратно $y то отправляем запрос в mysql
	if( 0 == $sql_ip_all_rows%$y and $sql_ip_all_ready == 1 ) {
		($sql_ip_all, $sql_ip_all_ready) = &insert_ip($sql_ip_all, $sql_ip_all_ready);
	}
}

# добавляем в таблицу остатки данных
if( $sql_ip_all_ready == 1 ) {
	($sql_ip_all, $sql_ip_all_ready) = &insert_ip($sql_ip_all, $sql_ip_all_ready);
}

my $bm_point02 = new Benchmark;
my $bm_diff02 = timediff($bm_point02,$bm_point00);
print "Data preparation took " . timestr($bm_diff02, 'all') . " seconds\n" if DEBUG;

# the END


###### subs ############################################################################

sub insert_ip {
	my ($sql_ip_all, $sql_ip_all_ready) = @_;
	chop($sql_ip_all);
	my $sth = $dbh->do($sql_ip_all) or print "ERROR IN SQL sql_ip_all \n";
	$sql_ip_all = "INSERT INTO ip_resolv (ip) VALUES ";
	$sql_ip_all_ready = 0;
	return ($sql_ip_all, $sql_ip_all_ready);
}


sub resolv_callback {
	my $response = shift;
	my $domain;
	my $ips = "";
	print Dumper $response if DEBUG;
 
	if (defined($response)) {
		my $cname = 0;
		my $cname_cnt = 0;
		$ips = "";
 
		foreach my $rr ($response->answer) {
			if ($rr->type eq "CNAME") {
				$cname = 1;
				if ($cname_cnt eq "0") {
					$domain = lc $rr->owner;
				}
				$cname_cnt++;
				print "CNAME: $domain\n" if DEBUG;
			}
     
			if ($rr->type eq "A") {
				my $ip = $rr->address;
				if ($cname eq "0") {
					$domain = lc $rr->owner;
				}
				$ips .= "$ip ";
			}
		}    
		# если ресолв успешный т.е. вернул какие-то ip, то пополняем ими общий массив @all_ip
		if ($ips) {
			$dnscache{$domain} = $ips;
			my @ip_arr = split(' ', $ips);
			foreach my $ip (@ip_arr) {
				push @all_ip, $ip;
			}
		}
	}
}






