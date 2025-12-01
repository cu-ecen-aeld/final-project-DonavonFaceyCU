// SPDX-License-Identifier: GPL-2.0-or-later
// SPDX-FileCopyrightText: 2023 Kent Gibson

/*
 * Modified to run as a SysV-style daemon.
 */

#include <errno.h>
#include <gpiod.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <syslog.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <fcntl.h>
#include <signal.h>

#define NUM_LINES 8
#define PIDFILE "/var/run/uptimeclock.pid"

/* ---------------- DAEMON SETUP ---------------- */

static void daemonize(void)
{
	pid_t pid;

	/* 1st fork */
	pid = fork();
	if (pid < 0)
		exit(EXIT_FAILURE);
	if (pid > 0)
		exit(EXIT_SUCCESS); /* Parent exits */

	/* Become session leader */
	if (setsid() < 0)
		exit(EXIT_FAILURE);

	/* 2nd fork */
	pid = fork();
	if (pid < 0)
		exit(EXIT_FAILURE);
	if (pid > 0)
		exit(EXIT_SUCCESS);

	/* Set root as working dir */
	chdir("/");

	/* Clear file mode mask */
	umask(0);

	/* Close inherited file descriptors */
	close(STDIN_FILENO);
	close(STDOUT_FILENO);
	close(STDERR_FILENO);

	/* Redirect std* to /dev/null */
	open("/dev/null", O_RDWR);
	dup(0);
	dup(0);
}

/* ---------------- GPIO LOGIC FROM ORIGINAL CODE ---------------- */

static struct gpiod_line_request *
request_output_lines(const char *chip_path, const unsigned int *offsets,
		     enum gpiod_line_value *values, unsigned int num_lines,
		     const char *consumer)
{
	struct gpiod_request_config *rconfig = NULL;
	struct gpiod_line_request *request = NULL;
	struct gpiod_line_settings *settings;
	struct gpiod_line_config *lconfig;
	struct gpiod_chip *chip;
	unsigned int i;
	int ret;

	chip = gpiod_chip_open(chip_path);
	if (!chip)
		return NULL;

	settings = gpiod_line_settings_new();
	if (!settings)
		goto close_chip;

	gpiod_line_settings_set_direction(settings, GPIOD_LINE_DIRECTION_OUTPUT);

	lconfig = gpiod_line_config_new();
	if (!lconfig)
		goto free_settings;

	for (i = 0; i < num_lines; i++) {
		ret = gpiod_line_config_add_line_settings(lconfig, &offsets[i],
							  1, settings);
		if (ret)
			goto free_line_config;
	}

	gpiod_line_config_set_output_values(lconfig, values, num_lines);

	if (consumer) {
		rconfig = gpiod_request_config_new();
		if (!rconfig)
			goto free_line_config;

		gpiod_request_config_set_consumer(rconfig, consumer);
	}

	request = gpiod_chip_request_lines(chip, rconfig, lconfig);

	gpiod_request_config_free(rconfig);

free_line_config:
	gpiod_line_config_free(lconfig);

free_settings:
	gpiod_line_settings_free(settings);

close_chip:
	gpiod_chip_close(chip);

	return request;
}

static enum gpiod_line_value toggle_line_value(enum gpiod_line_value value)
{
	return (value == GPIOD_LINE_VALUE_ACTIVE)
		       ? GPIOD_LINE_VALUE_INACTIVE
		       : GPIOD_LINE_VALUE_ACTIVE;
}

static void toggle_line_values(enum gpiod_line_value *values,
			       unsigned int num_lines)
{
	unsigned int i;
	for (i = 0; i < num_lines; i++)
		values[i] = toggle_line_value(values[i]);
}

static void print_values_syslog(const unsigned int *offsets,
			        const enum gpiod_line_value *values,
			        unsigned int num_lines)
{
	char buffer[200];
	char *p = buffer;
	unsigned int i;

	for (i = 0; i < num_lines; i++) {
		p += sprintf(p, "%d=%s ",
			     offsets[i],
			     (values[i] == GPIOD_LINE_VALUE_ACTIVE)
				     ? "Active"
				     : "Inactive");
	}

	syslog(LOG_INFO, "%s", buffer);
}

/* ---------------- MAIN ---------------- */

int main(void)
{
	/* Open syslog first */
	openlog("uptimeclock", LOG_PID | LOG_CONS, LOG_DAEMON);

	syslog(LOG_INFO, "Starting uptimeclock daemon");

	/* Become daemon */
	daemonize();

	/* Optional: write PID file */
	FILE *pf = fopen(PIDFILE, "w");
	if (pf) {
		fprintf(pf, "%d\n", getpid());
		fclose(pf);
	}

	static const char *const chip_path = "/dev/gpiochip1";
	static const unsigned int line_offsets[NUM_LINES] = {78, 79, 80, 81, 82, 83, 84, 85};

	enum gpiod_line_value values[NUM_LINES] = {
		GPIOD_LINE_VALUE_INACTIVE,
		GPIOD_LINE_VALUE_INACTIVE,
		GPIOD_LINE_VALUE_INACTIVE,
		GPIOD_LINE_VALUE_INACTIVE,
		GPIOD_LINE_VALUE_INACTIVE,
		GPIOD_LINE_VALUE_INACTIVE,
		GPIOD_LINE_VALUE_INACTIVE,
		GPIOD_LINE_VALUE_INACTIVE
	};

	struct gpiod_line_request *request;

	request = request_output_lines(chip_path,
				       line_offsets,
				       values,
				       NUM_LINES,
				       "uptimeclock");
	if (!request) {
		syslog(LOG_ERR, "Failed to request lines: %s", strerror(errno));
		return EXIT_FAILURE;
	}
	
	static uint8_t secondCount = 0;

	while (1) {
		print_values_syslog(line_offsets, values, NUM_LINES);
		sleep(1);
		
		secondCount = (secondCount+1) & 0xFF;
		
		uint8_t bitmask = 0x1;
		
		for(int i = 0; i < NUM_LINES; i++){
			if(bitmask & secondCount){
				values[i] = GPIOD_LINE_VALUE_ACTIVE;
			} else {
				values[i] = GPIOD_LINE_VALUE_INACTIVE;
			}
		}
		
		gpiod_line_request_set_values(request, values);
	}

	gpiod_line_request_release(request);

	syslog(LOG_INFO, "uptimeclock daemon terminated");
	closelog();

	return EXIT_SUCCESS;
}

