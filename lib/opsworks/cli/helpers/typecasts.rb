module OpsWorks
  module CLI
    module Helpers
      module Typecasts
        def typecast_string_argument(arg)
          case arg
          when 'true' then true
          when 'false' then false
          else arg
          end
        end
      end
    end
  end
end
