#
# Cookbook:: stateofthemap
# Recipe:: jekyll
#
# Copyright:: 2022, OpenStreetMap Foundation
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

include_recipe "apache"
include_recipe "podman"

apache_module "proxy_http"

%w[2016 2017 2018 2019 2020 2021 2022].each do |year|
  docker_external_port = 6080 + year.to_i # 8096+

  podman_service "#{year}.stateofthemap.org" do
    description "Container service for #{year}.stateofthemap.org"
    image "ghcr.io/openstreetmap/stateofthemap-#{year}:latest"
    ports docker_external_port => "8080"
  end

  ssl_certificate "#{year}.stateofthemap.org" do
    domains ["#{year}.stateofthemap.org", "#{year}.stateofthemap.com", "#{year}.sotm.org"]
    notifies :reload, "service[apache2]"
  end

  apache_site "#{year}.stateofthemap.org" do
    template "apache.jekyll.erb"
    variables :docker_external_port => docker_external_port, :aliases => ["#{year}.stateofthemap.com", "#{year}.sotm.org"]
  end
end
