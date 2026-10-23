#!/usr/bin/env ruby
# 场景特定检查：图像集合来自本夹具固定输入，不扫描任意Markdown推断采用关系。
require 'yaml'
require 'json'
require 'pathname'
repo = File.expand_path('../../..', __dir__)
goal = ARGV.fetch(0) { abort '用法：ruby verify-image-sources.rb <教学goal.yaml>' }
doc = YAML.safe_load(File.read(goal))
expected = Dir[File.join(__dir__, 'prototype/images/*.png')].sort.map { |p| Pathname.new(p).relative_path_from(Pathname.new(repo)).to_s }
abort "固定输入应有5张实际PNG，当前#{expected.length}；拒绝空/缺失夹具假通过" unless expected.length == 5
actual = doc.fetch('results').values.select { |r| r['kind'] == 'user_result' }.flat_map { |r| r.fetch('sources').map { |s| s.fetch('path') } }.uniq
missing = expected - actual
puts JSON.pretty_generate({ check: '本夹具5张固定图片直接进入相关user_result来源集合', missing: missing, passed: missing.empty?, limitation: '只检直接引用覆盖；每张图归属的正确结果、语义、过程与业务仍须独立审查' })
exit(missing.empty? ? 0 : 1)
