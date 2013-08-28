use Irssi qw(print settings_get_str settings_set_str);
use Irssi::Irc;
$VERSION = '0.1.4';
%IRSSI = (
		  authors     => 'Jonathan Annas',
		  contact     => 'author@far.away',
		  name        => 'Flood Protector',
		  description => 'This script catches ' .
		  'the [flood] signal from irssi and bans '.
		  'the offender by domain.' ,
		  license     => 'Public Domain',
);

Irssi::settings_add_str('flood', 'channels', '');

sub flood_add_chan{
		  $channel = shift;
		  $channels = settings_get_str('channels');
		  $sep = ($channels ne '') ? ',' : '';
		  $channels = $channels .$sep. $channel;
		  settings_set_str('channels', $channels);
		  print("Added channel $channel to flood protection list.");
}

sub flood_rm_chan{
		  $index = shift;
		  $channels = settings_get_str('channels');
		  @list = split(/,/,$channels);
		  splice @list, $index, 1;
		  $channels = join ',', @list;
		  settings_set_str('channels', $channels);
		  &flood_list;
}

sub flood_list{
		  $channels = settings_get_str('channels');
		  @list = split(/,/,$channels);
		  $i = 0;
		  print "";
		  print "Flood protected channels:";
		  foreach (@list){
					 print "[$i] $_";
					 $i++;
		  }
}

sub flood{
		  my ($server, $nick, $host, $level, $target) = @_;
		  print("There is a flood!");
		  print "$nick $host $level $target";
		  $chan = Irssi::channel_find($target);
		  $n = $chan->nick_find($nick);
		  $channels = settings_get_str('channels');
		  @flood_channels = split(/,/,$channels);
		  if($n->{op} == 1 || !($target ~~ @flood_channels)){
					 return;
		  }
		  $server->command("MSG $target $nick, stop spamming!");
		  $n->{host} =~ m/@(.*)/;
		  $host = $1;
		  $server->command("mode $target +b *!*\@$1");
}

Irssi::signal_add 'flood' => \&flood;
Irssi::command_bind 'flood_list' => \&flood_list;
Irssi::command_bind 'flood_add_chan' => \&flood_add_chan;
Irssi::command_bind 'flood_rm_chan' => \&flood_rm_chan;
