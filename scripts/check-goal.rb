#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative 'goal-v3'

exit GoalV3.cli(ARGV) if $PROGRAM_NAME == __FILE__
