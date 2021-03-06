require 'benchmark/ips'
require 'json/ext'

require File.expand_path('lib/jrjackson')

obj = {
  'a' => 'Alpha', # string
  'b' => true,    # boolean
  'c' => 12345,   # number
  'd' => [ true, [false, [-123456789, nil], 3.9676, ['Something else.', false], nil]], # mix it up array
  'e' => { 'zero' => nil, 'one' => 1, 'two' => 2, 'three' => [3], 'four' => [0, 1, 2, 3, 4] }, # hash
  'f' => nil,     # nil
  'g' => Time.now,
  'h' => { 'a' => { 'b' => { 'c' => { 'd' => {'e' => { 'f' => { 'g' => nil }}}}}}}, # deep hash, not that deep
  'i' => [[[[[[[nil]]]]]]],  # deep array, again, not that deep
  'j' => Java::JavaUtil::ArrayList.new(["foo", 1])
}

json_source = JrJackson::Json.dump(obj)

puts "Json string size: #{json_source.size}"

# class GCSuite
#   def warming(*) run_gc; end
#   def running(*) run_gc; end
#   def warmup_stats(*) end
#   def add_report(*) end
#   private
#   def run_gc() GC.enable; GC.start; GC.disable; end
# end

# suite = GCSuite.new
# puts "using GC suite"

# Benchmark.ips do |x|
#   x.config(:suite => suite)

#   x.report("string keys") { JrJackson::Raw.parse_str(json_source) }
#   x.report("symbol keys") { JrJackson::Raw.parse_sym(json_source) }
#   x.report("symbol keys use handler") { JrJackson::Raw.parse_ro(json_source, nil) }
#   x.report("raw use handler") { JrJackson::Raw.parse_jo(json_source, nil) }
#   x.report("raw bd") { JrJackson::Raw.parse_raw_bd(json_source) }
#   x.report("raw") { JrJackson::Raw.parse_raw(json_source) }

#   x.report("generate") { JrJackson::Raw.generate(obj) }
# end

# puts "NOT using GC suite"
# puts 'Sleeping'
# sleep 30
# puts 'Working'

Benchmark.ips do |x|
  x.config(:time => 20, :warmup => 20)

  x.report("symbol keys use handler") { JrJackson::Ruby.parse_sym(json_source, nil) }
  # x.report("raw use handler") { JrJackson::Java.parse(json_source, nil) }
  # x.report("raw bd") { JrJackson::Raw.parse_raw_bd(json_source) }
  # x.report("raw") { JrJackson::Raw.parse_str(json_source) }
  x.report("JSON") { JSON.parse(json_source, {symbolize_names: true}) }
  # x.report("compat_parse symbol") { JrJackson::Ruby.compat_parse(json_source, {symbolize_keys: true}) }

  x.compare!
end
