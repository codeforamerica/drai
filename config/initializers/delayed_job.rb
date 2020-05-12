Delayed::Worker.sleep_delay = 1
Delayed::Worker.max_attempts = 99
Delayed::Worker.max_run_time = 2.minutes
Delayed::Worker.read_ahead = 1
Delayed::Worker.default_queue_name = 'default'
Delayed::Worker.raise_signal_exceptions = :term