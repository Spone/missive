require "time_for_a_boolean"

module Missive
  class Engine < ::Rails::Engine
    isolate_namespace Missive
  end
end
