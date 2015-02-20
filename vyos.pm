package vyos;
##
## $Id: vyos.pm.in 2804 2014-03-19 00:27:18Z heas $
##
## rancid 3.1
## Copyright (c) 1997-2014 by Terrapin Communications, Inc.
## All rights reserved.
##
## This code is derived from software contributed to and maintained by
## Terrapin Communications, Inc. by Henry Kilmer, John Heasley, Andrew Partan,
## Pete Whiting, Austin Schutz, and Andrew Fort.
##
## Redistribution and use in source and binary forms, with or without
## modification, are permitted provided that the following conditions
## are met:
## 1. Redistributions of source code must retain the above copyright
##    notice, this list of conditions and the following disclaimer.
## 2. Redistributions in binary form must reproduce the above copyright
##    notice, this list of conditions and the following disclaimer in the
##    documentation and/or other materials provided with the distribution.
## 3. All advertising materials mentioning features or use of this software
##    must display the following acknowledgement:
##        This product includes software developed by Terrapin Communications,
##        Inc. and its contributors for RANCID.
## 4. Neither the name of Terrapin Communications, Inc. nor the names of its
##    contributors may be used to endorse or promote products derived from
##    this software without specific prior written permission.
## 5. It is requested that non-binding fixes and modifications be contributed
##    back to Terrapin Communications, Inc.
##
## THIS SOFTWARE IS PROVIDED BY Terrapin Communications, INC. AND CONTRIBUTORS
## ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
## TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
## PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE COMPANY OR CONTRIBUTORS
## BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
## CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
## SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
## INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
## CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
## ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
## POSSIBILITY OF SUCH DAMAGE.
# 
#  RANCID - Really Awesome New Cisco confIg Differ
#
#  vyos.pm - Vyatta VyOS rancid procedures
#

use 5.005;
use strict 'vars';
use warnings;
require(Exporter);
our @ISA = qw(Exporter);
$Exporter::Verbose=1;

#XXX use 3.1 when we have a version w/o letters in it
#XXX use rancid 3.1;
use rancid;

@ISA = qw(Exporter rancid main);
#our @EXPORT = qw($VERSION)

# load-time initialization
sub import {
    $timeo = 120;			# vlogin timeout in seconds

    0;
}

# post-open(collection file) initialization
sub init {
    # add content lines and separators
    ProcessHistory("","","","#RANCID-CONTENT-TYPE: $devtype\n#\n");

    0;
}

# main loop of input of device output
sub inloop {
    my($INPUT, $OUTPUT) = @_;
    my($cmd, $rval);

TOP: while (<$INPUT>) {
	tr/\015//d;
	if (/^Error:/) {
	    print STDOUT ("$host vlogin error: $_");
	    print STDERR ("$host vlogin error: $_") if ($debug);
	    $clean_run=0;
	    last;
	}
	if (/System shutdown message/) {
	    print STDOUT ("$host shutdown msg: $_");
	    print STDERR ("$host shutdown msg: $_") if ($debug);
	    $clean_run = 0;
	    last;
	}
	if (/error: cli version does not match Managment Daemon/i) {
	    print STDOUT ("$host mgd version mismatch: $_");
	    print STDERR ("$host mgd version mismatch: $_") if ($debug);
	    $clean_run = 0;
	    last;
	}
	while (/\s*($cmds_regexp)\s*$/) {
	    $cmd = $1;
	    $prompt = ":~";

	    if (!defined($prompt)) {
		$prompt = ($_ =~ /^([^>]+>)/)[0];
		$prompt =~ s/([][}{)(\\])/\\$1/g;
		print STDERR ("PROMPT MATCH: $prompt\n") if ($debug);
	    }
	    print STDERR ("HIT COMMAND:$_") if ($debug);
	    if (! defined($commands{$cmd})) {
		print STDERR "$host: found unexpected command - \"$cmd\"\n";
		$clean_run = 0;
		last TOP;
	    }
	    $rval = &{$commands{$cmd}}($INPUT, $OUTPUT, $cmd);
	    delete($commands{$cmd});
	    if ($rval == -1) {
		$clean_run = 0;
		last TOP;
	    }
	}
	if (/\s*exit/) {
	    $clean_run=1;
	    last;
	}
    }
}

# This routine parses "show hardware"
sub ShowHardware {
    my($INPUT, $OUTPUT, $cmd) = @_;
    print STDERR "    In ShowHardware: $_" if ($debug);

    s/^[a-z]+@//;
    ProcessHistory("","","","# $_");
    while (<$INPUT>) {
	tr/\015//d;
	last if (/$prompt/);
	return 1 if (/^aborted!/i);
	next if (/^system (shutdown message from|going down )/i);
	next if (/^\{(master|backup)(:\d+)?\}/);
	next if (/^show/);

	/Couldn\'t initiate connection/ && return(-1);
	/Unrecognized command/ && return(1);
	/command is not valid/ && return(1);
	/^\s+\^/ && return(1);
	/syntax error/ && return(1);

	ProcessHistory("","","","# $_");
    }
    return(0);
}

# This routine parses "show version"
sub ShowVersion {
    my($INPUT, $OUTPUT, $cmd) = @_;
    print STDERR "    In ShowVersion: $_" if ($debug);

    s/^[a-z]+@//;
    ProcessHistory("","","","# $_");
    while (<$INPUT>) {
	tr/\015//d;
	last if (/$prompt/);
	next if (/^\s*$/);
	next if (/^system (shutdown message from|going down )/i);
	next if (/^\{(master|backup)(:\d+)?\}/);
	next if (/^uptime/i);
	next if (/^show/);
	/# error: abnormal / && return(-1);

	ProcessHistory("","","","# $_");
    }
    ProcessHistory("","","","#\n");

    return(0);
}

# This routine parses "show configuration"
sub ShowConfiguration {
    my($INPUT, $OUTPUT, $cmd) = @_;
    my($lines) = 0;
    my($snmp) = 0;
    print STDERR "    In ShowConfiguration: $_" if ($debug);

    s/^[a-z]+@//;
    ProcessHistory("","","","# $_");
    while (<$INPUT>) {
	tr/\015//d;
	next if (/^\s*$/);
	# end of config - hopefully.  VyOS does not have a reliable
	# end-of-config tag.  appears to end with "\nPROMPT:~$".
	if (/$prompt/) {
	    $found_end++;
	    last;
	}
	next if (/^system (shutdown message from|going down )/i);
	next if (/^\{(master|backup)(:\d+)?\}/);
	next if (/^\{(primary|secondary)(:\d+)?\}/);
	next if (/^show/);
	next if (/^exit/);

	$lines++;

	/^database header mismatch: / && return(-1);
	/^version .*;\d+$/ && return(-1);

	s/ # SECRET-DATA$//;
	s/ ## SECRET-DATA$//;
	# filter snmp community, when in snmp { stanza }
	/^\s*snmp/ && $snmp++;
	/^}/ && ($snmp = 0);
	if ($snmp && /^(\s*)(community|trap-group) [^ ;]+(\s?[;{])$/) {
		if ($filter_commstr) {
		    $_ = "$1$2 \"<removed>\"$3\n";
		}
	}

	if (/^(.* snmp community) [^ ;]+(\s?.*)$/) {
		if ($filter_commstr) {
		    $_ = "$1 \"<removed>\"$2\n";
		}
	}
	if (/^(.* snmp .*-key) [^ ;]+(\s?.*)$/) {
		if ($filter_commstr) {
		    $_ = "$1 \"<removed>\"$2\n";
		}
	}
	if (/(\s*authentication-key )[^ ;]+/ && $filter_pwds >= 1) {
	    ProcessHistory("","","","#$1<removed>$'");
	    next;
	}
	if (/(\s*md5 \d+ key )[^ ;]+/ && $filter_pwds >= 1) {
	    ProcessHistory("","","","#$1<removed>$'");
	    next;
	}
	if (/(\s*hello-authentication-key )[^ ;]+/ && $filter_pwds >= 1) {
	    ProcessHistory("","","","#$1<removed>$'");
	    next;
	}
	# don't filter this one - there is no secret here.
	if (/^\s*permissions .* secret /) {
	    ProcessHistory("","","","$_");
	    next;
	}
	if (/^(.*\ssecret )[^ ;]+/ && $filter_pwds >= 1) {
	    ProcessHistory("","","","#$1<removed>$'");
	    next;
	}
	if (/(.* encrypted-password )[^ ;]+/ && $filter_pwds >= 2) {
	    ProcessHistory("","","","#$1<removed>\n");
	    next;
	}
	if (/(\s+ssh-(rsa|dsa) )\"/ && $filter_pwds >= 2) {
	    ProcessHistory("","","","#$1<removed>;\n");
	    next;
	}
	if (/^(\s+(pre-shared-|)key (ascii-text|hexadecimal) )[^ ;]+/ && $filter_pwds >= 1) {
	    ProcessHistory("","","","#$1<removed>$'");
	    next;
	}
	ProcessHistory("","","","$_");
    }

    if ($lines < 1) {
	printf(STDERR "ERROR: $host configuration appears truncated.\n");
	$found_end = 0;
	return(-1);
    }

    return(0);
}

1;
