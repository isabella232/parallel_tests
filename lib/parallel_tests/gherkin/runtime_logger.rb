require 'parallel_tests/gherkin/io'

module ParallelTests
  module Gherkin
    class RuntimeLogger
      include Io

      def initialize(step_mother, path_or_io, options)
        @io = prepare_io(path_or_io)
        @example_times = Hash.new(0)
      end

      def before_test_case(_test_case)
        @start_at = ParallelTests.now.to_f
      end

      def after_test_case(test_case, _result)
        file_set = test_case.source.each_with_object(Set.new) { |source, set|
          set.add source.location.file
        }

        if file_set.length > 1
          raise ArgumentError, "More than one file (#{file_set.join("\n")}) in source locations"
        end

        file = file_set.to_a[0]

        @example_times[file] += ParallelTests.now.to_f - @start_at
      end

      def done
        lock_output do
          @io.puts @example_times.map { |file, time| "#{file}:#{time}" }
        end
      end
    end
  end
end
