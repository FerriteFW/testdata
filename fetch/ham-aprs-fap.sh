#!/bin/sh
# Ham::APRS::FAP 1.21 (Tapio Sokura, Heikki Hannikainen; same terms as Perl) from CPAN, unpacked in aprs/: the
# parser whose test suite gave aprs/suite.hex. The Docker image installs its own copy; this one is for reading.
. "$(dirname "$0")/lib.sh"
get https://cpan.metacpan.org/authors/id/H/HE/HESSU/Ham-APRS-FAP-1.21.tar.gz aprs/Ham-APRS-FAP-1.21.tar.gz
tar -xzf aprs/Ham-APRS-FAP-1.21.tar.gz -C aprs
ls -d aprs/Ham-APRS-FAP-1.21
