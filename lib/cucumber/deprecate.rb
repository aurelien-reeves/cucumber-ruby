# frozen_string_literal: true

require 'cucumber/platform'
require 'cucumber/gherkin/formatter/ansi_escapes'

module Cucumber
  module Deprecate
    class CliOption
      include Cucumber::Gherkin::Formatter::AnsiEscapes

      def self.deprecate(stream, option, message, remove_after_version)
        return if stream.nil?
        CliOption.new.deprecate(stream, option, message, remove_after_version)
      end

      def deprecate(stream, option, message, remove_after_version)
        stream.puts(failed + "\nWARNING: #{option} is deprecated" \
        " and will be removed after version #{remove_after_version}.\n#{message}.\n" \
        + reset)
      end
    end

    module ForUsers
      AnsiEscapes = Cucumber::Gherkin::Formatter::AnsiEscapes

      def self.call(message, method, remove_after_version)
        STDERR.puts AnsiEscapes.failed + "\nWARNING: ##{method} is deprecated" \
        " and will be removed after version #{remove_after_version}. #{message}.\n" \
        "(Called from #{caller(3..3).first})" + AnsiEscapes.reset
      end
    end

    module ForDevelopers
      def self.call(_message, _method, remove_after_version)
        raise "This method is due for removal after version #{remove_after_version}" if Cucumber::VERSION > remove_after_version
      end
    end

    STRATEGY = $PROGRAM_NAME =~ /rspec$/ ? ForDevelopers : ForUsers
  end

  def self.deprecate(*args)
    Deprecate::STRATEGY.call(*args)
  end
end
