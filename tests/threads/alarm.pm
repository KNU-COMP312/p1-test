sub check_alarm {
    my ($iterations) = @_;
    our ($test);

    @output = read_text_file ("$test.output");
    common_checks ("run", @output);

    my (@products);
    for (my ($i) = 0; $i < $iterations; $i++) {
	for (my ($t) = 0; $t < 5; $t++) {
	    push (@products, ($i + 1) * ($t + 1) * 10);
	}
    }
    @products = sort {$a <=> $b} @products;

    local ($_);
    foreach (@output) {
	fail $_ if /out of order/i;

	my ($p) = /product=(\d+)$/;
	next if !defined $p;

	my ($q) = shift (@products);
	fail "Too many wakeups.\n" if !defined $q;
	fail "Out of order wakeups ($p vs. $q).\n" if $p != $q; # FIXME
    }
    fail scalar (@products) . " fewer wakeups than expected.\n"
      if @products != 0;
    pass;
}

sub check_idle_ticks_positive {
  our ($test);
  my @output = read_text_file("$test.output");

  foreach my $line (@output) {
    if ($line =~ /Thread:\s+(\d+)\s+idle ticks,.*?kernel ticks,.*?user ticks/i) {
      my $idle_ticks = $1;
      if ($idle_ticks > 0) {
        return;
      } else {
        fail("Idle ticks is zero or negative");
        return;
      }
    }
  }

  fail("No idle tick line found in output.");
}

1;
