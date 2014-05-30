# Encoding: utf-8
# IBM WebSphere Application Server Liberty Buildpack
# Copyright 2013 the original author or authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require 'liberty_buildpack/diagnostics/logger_factory'
require 'liberty_buildpack/framework'
require 'liberty_buildpack/framework/framework_utils'
require 'liberty_buildpack/framework/spring_auto_reconfiguration/web_xml_modifier'
require 'liberty_buildpack/repository/configured_item'
require 'liberty_buildpack/util/application_cache'
require 'liberty_buildpack/util/download'
require 'liberty_buildpack/util/format_duration'
require 'English'
require 'fileutils'
require 'open-uri'
require 'yaml'

module LibertyBuildpack::Framework

  # Encapsulates the detect, compile, and release functionality for enabling cloud auto-reconfiguration in Spring
  # applications.
  class RestWink

    # Creates an instance, passing in an arbitrary collection of options.
    #
    # @param [Hash] context the context that is provided to the instance
    # @option context [String] :app_dir the directory that the application exists in
    # @option context [String] :lib_directory the directory that additional libraries are placed in
    # @option context [Hash] :configuration the properties provided by the user
    def initialize(context = {})
      @logger = LibertyBuildpack::Diagnostics::LoggerFactory.get_logger
      @lib_directory = context[:lib_directory]
      @configuration = context[:configuration]
      @app_dir = context[:app_dir]
    end

    # Detects whether this application is suitable for auto-reconfiguration
    #
    # @return [String] returns +spring-auto-reconfiguration-<version>+ if the application is a candidate for
    #                  auto-reconfiguration otherwise returns +nil+
    def detect
      if File.exist?(wink.*.jar)
    	  return "apche-wink-1.4"
    
      else
        return nil
      end
    end

    # Downloads the Auto-reconfiguration JAR
    #
    # @return [void]
    def compile
      print "\n\n------>calling restwink compile method...."
      @version, @uri = get_wink_uri(@configuration)
      print "\n\n*****Restwink uri: "
      print @uri
      print "\n\n*****Restwink version: "
      print @version
      print "\n"
      
     
     # jar_name=jar_name(@version)
      print "-----> Downloading wink jars from #{@uri} "

      LibertyBuildpack::Util::ApplicationCache.new.get(@uri) do |file| # TODO: Use global cache #50175265
        download_start_time = Time.now
        system "tar -zxf #{file.path} -C #{@lib_directory} 2>&1"
        print "\n------>Untared wink tar to #{@lib_directory}....."
        puts "(#{(Time.now - download_start_time).duration})"
      end
  end
    
   def get_wink_uri(configuration)
      version, uri=LibertyBuildpack::Repository::ConfiguredItem.find_item(configuration)
      uri=uri["uri"]
      return version, uri
   end
    
    
    # Does nothing
    #
    # @return [void]
    def release
    end

  
    def id(version)
       "wink-#{version}"
    end

  #  def jar_name(version)
   #     "#{id version}.jar"
   # end

    
  end

end
