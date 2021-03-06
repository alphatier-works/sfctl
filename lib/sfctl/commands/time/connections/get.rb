require 'pastel'
require_relative '../../../command'

module Sfctl
  module Commands
    class Time
      class Connections
        class Get < Sfctl::Command
          def initialize(options)
            @options = options
            @pastel = Pastel.new(enabled: !@options['no-color'])
          end

          def execute(output: $stdout)
            read_link_config

            if config.fetch(:connections).nil?
              output.puts @pastel.yellow('You have no connections. Please add them before continue.')
              return
            end

            print_connections(output)
          rescue TTY::Config::ReadError
            error_message = 'Please initialize time before continue and ensure that your account authenticated.'
            output.puts @pastel.yellow(error_message)
          end

          private

          def print_connections(output)
            config.fetch(:connections).each_key do |assignment_id|
              print_header!(output, assignment_id)

              case config.fetch(:connections, assignment_id, :provider)
              when TOGGL_PROVIDER
                print_toggl_connection!(output, assignment_id)
              when HARVEST_PROVIDER
                print_harvest_connection!(output, assignment_id)
              end

              print_footer!(output, assignment_id)
            end
          end

          def print_header!(output, assignment_id)
            output.puts "Connection: #{config.fetch(:connections, assignment_id, :name)}"
            output.puts "  service: #{config.fetch(:connections, assignment_id, :service)}"
          end

          def print_footer!(output, assignment_id)
            output.puts "  billable: #{config.fetch(:connections, assignment_id, :billable)}"
            output.puts "  rounding: #{config.fetch(:connections, assignment_id, :rounding)}"
            output.puts
          end

          def print_toggl_connection!(output, assignment_id)
            output.puts "  provider: #{TOGGL_PROVIDER}"
            output.puts "  workspace_id: #{config.fetch(:connections, assignment_id, :workspace_id)}"
            output.puts "  project_ids: #{config.fetch(:connections, assignment_id, :project_ids)}"
            output.puts "  task_ids: #{config.fetch(:connections, assignment_id, :task_ids)}"
          end

          def print_harvest_connection!(output, assignment_id)
            output.puts "  provider: #{HARVEST_PROVIDER}"
            output.puts "  project_id: #{config.fetch(:connections, assignment_id, :project_id)}"
            output.puts "  task_id: #{config.fetch(:connections, assignment_id, :task_id)}"
          end
        end
      end
    end
  end
end
