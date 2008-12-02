use inc::Module::Install;
name 'Github-IRCBot';
all_from 'lib/Github/IRCBot.pm';

test_requires 'Test::More';
use_test_base;
auto_include;
WriteAll;
