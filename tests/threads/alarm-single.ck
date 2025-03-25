# -*- perl -*-
use tests::tests;
use tests::threads::alarm;
check_idle_ticks_positive ();
check_alarm (1);
