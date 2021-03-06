require 'optparse'
require 'drb/drb'

module Fluent
  class Gcprofiler
    def parse_options(argv = ARGV)
      op = OptionParser.new
      op.banner += ' <start/stop> [output_file]'

      (class<<self;self;end).module_eval do
        define_method(:usage) do |msg|
          puts op.to_s
          puts "error: #{msg}" if msg
          exit 1
        end
      end

      opts = {
        host: '127.0.0.1',
        port: 24230,
        unix: nil,
        command: nil, # start or stop or gc
        output: '/tmp/fluent-gcprofiler.txt',
      }

      op.on('-h', '--host HOST', "fluent host (default: #{opts[:host]})") {|v|
        opts[:host] = v
      }

      op.on('-p', '--port PORT', "debug_agent tcp port (default: #{opts[:host]})", Integer) {|v|
        opts[:port] = v
      }

      op.on('-u', '--unix PATH', "use unix socket instead of tcp") {|v|
        opts[:unix] = v
      }

      op.on('-o', '--output PATH', "output path (default: #{opts[:output]})") {|v|
        opts[:output] = v
      }

      op.parse!(argv)

      opts[:command] = argv.shift
      unless %w[start stop gc].include?(opts[:command])
        raise OptionParser::InvalidOption.new("`start` or `stop` or `gc` must be specified as the 1st argument")
      end

      opts
    end

    def run
      begin
        opts = parse_options
      rescue OptionParser::InvalidOption => e
        usage e.message
      end

      unless opts[:unix].nil?
        uri = "drbunix:#{opts[:unix]}"
      else
        uri = "druby://#{opts[:host]}:#{opts[:port]}"
      end

      $remote_engine = DRb::DRbObject.new_with_uri(uri)

      case opts[:command]
      when 'start'
        remote_code = <<-CODE
        GC::Profiler.enable
        CODE
      when 'stop'
        remote_code = <<-"CODE"
        File.open('#{opts[:output]}', 'w') {|f|
          GC::Profiler.report(f)
        }
        GC::Profiler.disable
        GC::Profiler.clear
        CODE
      when 'gc' # for debug
        remote_code = <<-"CODE"
        GC.start
        CODE
      end

      $remote_engine.method_missing(:instance_eval, remote_code)

      case opts[:command]
      when 'start'
        $stdout.puts 'fluent-gcprofiler: started'
      when 'stop'
        $stdout.puts "fluent-gcprofiler: outputs to #{opts[:output]}"
      when 'gc'
        $stdout.puts 'fluent-gcprofiler: run GC.start remotely'
      end
    end
  end
end
