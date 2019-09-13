module ::MItamae
  module Plugin
    module ResourceExecutor
      class Debconf < ::MItamae::ResourceExecutor::Base
        def apply
          if current.exists && desired.exists
            # nothing...
          elsif !current.exists && desired.exists
            debconf = "#{attributes.package} #{attributes.question} #{attributes.vtype} #{attributes.value}"
            result = run_command("echo '#{debconf}' | debconf-set-selections")
          elsif current.exists && !desired.exists
            # nothing...
          elsif !current.exists && !desired.exists
            # nothing...
          end
        end

        private

        def set_current_attributes(current, action)
          @@debconf ||= {}
          @@debconf[attributes.package] = {}

          result = run_command(['debconf-show', attributes.package], error: false)
          result.stdout.each_line do |raw|
            line = raw.chomp.strip
            case line
            when /^(\* )?([0-9a-zA-Z-_\.\/]+): ?(.*)?$/
              @@debconf[attributes.package][$2] = {}
              @@debconf[attributes.package][$2][:value] = $3
              if $1 == '* '
                @@debconf[attributes.package][$2][:changed] = true
              else
                @@debconf[attributes.package][$2][:changed] = false
              end
            else
              raise NotImplementedError, "[Debconf::#{attributes.package}] Regex Error"
            end
          end

          if attributes.vtype == 'password'
            result = run_command("echo 'get #{attributes.question}' | debconf-communicate", error: false)
            case result.exit_status
            when 0
              case result.stdout.chomp
              when /\A(\d+)(?:\s*)?(.*)(?:\s*)?\z/
                @@debconf[attributes.package][attributes.question][:value] = $2
              else
                raise NotImplementedError, "[Debconf::#{attributes.package}] Communicate Regex Error"
              end
            when 10
              # doesn't exist
            else
              raise NotImplementedError, "[Debconf::#{attributes.package}] Communicate Status Error"
            end
          end

          case action
          when :set
            current.exists = false
            current.package = nil
            current.question = nil
            current.value = nil

            if @@debconf.has_key?(attributes.package)
              current.package = attributes.package

              if @@debconf[attributes.package].has_key?(attributes.question)
                current.question = attributes.question

                if @@debconf[attributes.package][attributes.question][:value] == attributes.value
                  current.exists = true
                  current.value = attributes.value
                else
                  current.value = @@debconf[attributes.package][attributes.question][:value]
                end
              end
            end
          when :reset
            current.exists = false
          else
            raise NotImplementedError, "[Debconf::#{attributes.package}] Current :set or :reset"
          end
        end

        def set_desired_attributes(desired, action)
          case action
          when :set
            desired.exists = true
          when :reset
            desired.exists = false
          else
            raise NotImplementedError, "[Debconf::#{attributes.package}] Desired :set or :reset"
          end
        end
      end
    end
  end
end
