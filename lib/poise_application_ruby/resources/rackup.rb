#
# Copyright 2015, Noah Kantrowitz
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require 'chef/provider'
require 'chef/resource'
require 'poise'
require 'poise_application/service_mixin'

require 'poise_application_ruby/ruby_mixin'


module PoiseApplicationRuby
  module Resources
    # (see Rackup::Resource)
    # @since 4.0.0
    module Rackup
      class Resource < Chef::Resource
        include PoiseApplication::ServiceMixin
        include PoiseApplicationRuby::RubyMixin
        provides(:application_rackup)

        # @!attribute port
        #   TCP port to listen on. Defaults to 80.
        #   @return [String, Integer]
        attribute(:port, kind_of: [String, Integer], default: 80)
      end

      class Provider < Chef::Provider
        include PoiseApplication::ServiceMixin
        include PoiseApplicationRuby::RubyMixin
        provides(:application_rackup)

        private

        # Find the path to the config.ru. If the resource path was to a
        # directory, apparent /config.ru.
        #
        # @return [String]
        def configru_path
          @configru_path ||= if ::File.directory?(new_resource.path)
            ::File.join(new_resource.path, 'config.ru')
          else
            new_resource.path
          end
        end

        # Set up service options for rackup.
        #
        # @param resource [PoiseService::Resource] Service resource.
        # @return [void]
        def service_options(resource)
          super
          resource.command("rackup --port #{new_resource.port}")
          resource.directory(::File.dirname(configru_path))
          # Older versions of rackup ignore all signals.
          resource.stop_signal('KILL')
        end
      end
    end
  end
end
