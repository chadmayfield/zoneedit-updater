# zoneedit updater

ZoneEdit Updater monitors your WAN IP address and if there is a change updates the defined [ZoneEdit.com](http://zoneedit.com/) dynamic dns zones with the updated IP address.  It's recommended that this script run from cron, and logs are stored as a user configuration options, the default is /var/log/zoneedit/ip.log.

### Requirements
1. Account with [zoneedit.com](http://zoneedit.com/) (free or paid).
2. Perl 5+ (with [LWP](http://search.cpan.org/dist/libwww-perl/lib/LWP.pm), specifically LWP::UserAgent & LWP::Simple)

**NOTE**: This project is no longer maintained, the last time it was used was in 2010 and I can't confirm that it still works.
