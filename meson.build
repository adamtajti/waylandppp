# Copyright (c) 2025 Adam Tajti
# Copyright (c) 2014-2022 Philipp Kerling, Nils Christopher Brause, Craig Andrews, Tobias Kortkamp, Balint Reczey
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# 1. Redistributions of source code must retain the above copyright notice, this
#    list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright notice,
#    this list of conditions and the following disclaimer in the documentation
#    and/or other materials provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
# ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
# (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
# LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
# ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

project(
  'waylandppp',
  'cpp',
  version: '1.0.0',
  default_options : ['default_library=static'])

# Resolve dependencies as soon as possible to avoid unnecessary work
# tested with 1.14
pugixml_dep = dependency('pugixml', version: '>=1.4')
pugixml_pkgdatadir = pugixml_dep.get_pkgconfig_variable('pkgdatadir')
# tested with 1.23.1
wayland_client_dep = dependency('wayland-client', version: '>=1.11.0')
wayland_client_pkgdatadir = wayland_client_dep.get_pkgconfig_variable('pkgdatadir')

libdir = wayland_client_dep.get_pkgconfig_variable('libdir')

# tested with 1.23.1
wayland_server_dep = dependency('wayland-server', version: '>=1.17.0')
wayland_server_pkgdatadir = wayland_server_dep.get_pkgconfig_variable('pkgdatadir')
# tested with 1.23.1
wayland_cursor_dep = dependency('wayland-cursor')
wayland_cursor_pkgdatadir = wayland_cursor_dep.get_pkgconfig_variable('pkgdatadir')
# tested with 18.1.0
wayland_egl_dep = dependency('wayland-egl')
wayland_egl_pkgdatadir = wayland_egl_dep.get_pkgconfig_variable('pkgdatadir')
# tested with 1.39
wayland_protocols_dep = dependency('wayland-protocols')
wayland_protocols_pkgdatadir = wayland_protocols_dep.get_pkgconfig_variable('pkgdatadir')
# tested with 1.0
wlr_protocols_dep = dependency('wlr-protocols')
wlr_protocols_pkgdatadir = wlr_protocols_dep.get_pkgconfig_variable('pkgdatadir')

# Setup the installation directories
# https://mesonbuild.com/Builtin-options.html#directories
# default(prefix(linux)): /usr/local
prefix = get_option('prefix')
# default(datadir(linux)): share (/usr/local/share/)
waylandppp_datadir = prefix / get_option('datadir')
# the build folder
build_root = meson.project_build_root()
# the git root folder
git_root = meson.project_source_root()

# Versioning
wayland_version_config = configuration_data()
wayland_version_config.set('PROJECT_VERSION', meson.project_version())
version_array = meson.project_version().split('.')
wayland_version_config.set('PROJECT_VERSION_MAJOR', version_array[0])
wayland_version_config.set('PROJECT_VERSION_MINOR', version_array[1])
wayland_version_config.set('PROJECT_VERSION_PATCH', version_array[2])
configure_file(
  input: 'include/wayland-version.hpp.in',
  output:  'wayland-version.hpp',
  configuration: wayland_version_config,
)

wayland_scanner_pp = executable(
  'wayland-scanner+++',
  'scanner/scanner.cpp',
  dependencies: [ pugixml_dep ],
  build_by_default: true,
  install: true)

wayland_scanner_pp_full_path = wayland_scanner_pp.full_path()

# build wayland-client-protocol
protocols_wayland_path = join_paths(git_root, 'protocols', 'wayland.xml')

wayland_client_protocol = custom_target('wayland-client-protocol',
  depends: [wayland_scanner_pp],
  input: wayland_scanner_pp,
  output: [
    'wayland-client-protocol.hpp',
    'wayland-client-protocol.cpp',
  ],
  command: [
    wayland_scanner_pp,
    protocols_wayland_path,
    join_paths(build_root, 'wayland-client-protocol.hpp'),
    join_paths(build_root, 'wayland-client-protocol.cpp'),
  ],
  build_by_default : true)
# build wayland-client-protocol-stable
wayland_stable_protocol_xmls = run_command(
  'find',
  join_paths(wayland_protocols_pkgdatadir, 'stable'),
  '-regex',
  '.*\.xml',
  check: true).stdout().split('\n')
wayland_client_protocol_stable = custom_target('wayland-client-protocol-stable',
  depends: [wayland_scanner_pp],
  input: wayland_scanner_pp,
  output: [
    'wayland-client-protocol-stable.hpp',
    'wayland-client-protocol-stable.cpp',
  ],
  command: [
    wayland_scanner_pp,
    wayland_stable_protocol_xmls,
    join_paths(build_root, 'wayland-client-protocol-stable.hpp'),
    join_paths(build_root, 'wayland-client-protocol-stable.cpp'),
  ],
  build_by_default : true)
# build wayland-client-protocol-unstable
wayland_unstable_protocol_xmls = run_command(
  './scripts/find-unique-unstable-protocols.sh',
  join_paths(wayland_protocols_pkgdatadir, 'unstable'),
  check: true).stdout().split('\n')

wayland_client_protocol_unstable = custom_target('wayland-client-protocol-unstable',
  depends: [wayland_scanner_pp],
  input: wayland_scanner_pp,
  output: [
    'wayland-client-protocol-unstable.hpp',
    'wayland-client-protocol-unstable.cpp',
  ],
  command: [
    wayland_scanner_pp,
    wayland_unstable_protocol_xmls,
    join_paths(build_root, 'wayland-client-protocol-unstable.hpp'),
    join_paths(build_root, 'wayland-client-protocol-unstable.cpp'),
    '-x',
    wayland_client_protocol_stable
  ],
  build_by_default : true)
# build wayland-server-protocol
wayland_server_protocol = custom_target('wayland-server-protocol',
  depends: [wayland_scanner_pp],
  input: wayland_scanner_pp,
  output: [
    'wayland-server-protocol.hpp',
    'wayland-server-protocol.cpp',
  ],
  command: [
    wayland_scanner_pp,
    '-s',
    'on',
    protocols_wayland_path,
    join_paths(build_root, 'wayland-server-protocol.hpp'),
    join_paths(build_root, 'wayland-server-protocol.cpp'),
  ],
  build_by_default : true)
# build wayland-server-protocol-stable
wayland_server_protocol_stable = custom_target('wayland-server-protocol-stable',
  depends: [wayland_scanner_pp],
  input: wayland_scanner_pp,
  output: [
    'wayland-server-protocol-stable.hpp',
    'wayland-server-protocol-stable.cpp',
  ],
  command: [
    wayland_scanner_pp,
    '-s',
    'on',
    wayland_stable_protocol_xmls,
    join_paths(build_root, 'wayland-server-protocol-stable.hpp'),
    join_paths(build_root, 'wayland-server-protocol-stable.cpp'),
    '-x',
    wayland_server_protocol
  ],
  build_by_default : true)
# build wayland-server-protocol-unstable
wayland_server_protocol_unstable = custom_target('wayland-server-protocol-unstable',
  depends: [wayland_scanner_pp],
  input: wayland_scanner_pp,
  output: [
    'wayland-server-protocol-unstable.hpp',
    'wayland-server-protocol-unstable.cpp',
  ],
  command: [
    wayland_scanner_pp,
    '-s',
    'on',
    wayland_unstable_protocol_xmls,
    join_paths(build_root, 'wayland-server-protocol-unstable.hpp'),
    join_paths(build_root, 'wayland-server-protocol-unstable.cpp'),
    '-x',
    wayland_server_protocol_stable

  ],
  build_by_default : true)
# build wlr-client-protocol-unstable
wlr_unstable_protocol_xmls = run_command(
  'find',
  join_paths(wlr_protocols_pkgdatadir, 'unstable'),
  '-regex', '.*\.xml',
  check: true).stdout().split('\n')
wlr_client_protocol_unstable = custom_target('wlr-client-protocol-unstable',
  depends: [wayland_scanner_pp],
  input: wayland_scanner_pp,
  output: [
    'wlr-client-protocol-unstable.hpp',
    'wlr-client-protocol-unstable.cpp',
  ],
  command: [
    wayland_scanner_pp,
    wlr_unstable_protocol_xmls,
    join_paths(build_root, 'wlr-client-protocol-unstable.hpp'),
    join_paths(build_root, 'wlr-client-protocol-unstable.cpp'),
  ],
  build_by_default : true)
# build wlr-server-protocol-unstable
wlr_server_protocol_unstable = custom_target('wlr-server-protocol-unstable',
  depends: [wayland_scanner_pp],
  input: wayland_scanner_pp,
  output: [
    'wlr-server-protocol-unstable.hpp',
    'wlr-server-protocol-unstable.cpp',
  ],
  command: [
    wayland_scanner_pp,
    '-s',
    'on',
    wlr_unstable_protocol_xmls,
    join_paths(build_root, 'wlr-server-protocol-unstable.hpp'),
    join_paths(build_root, 'wlr-server-protocol-unstable.cpp'),
  ],
  build_by_default : true)

# Build both shared and static libraries
# note: only the first output is taken for these lib dependencies, reasoning:
# https://github.com/mesonbuild/meson/issues/7891

# pkgconfig (.pc) files will be generated by this module
pkg_config = import('pkgconfig')


# These variables will be augmented to the .pc files
pkg_vars = [
  'exec_prefix=${prefix}',
  'datarootdir=${prefix}/share',
  'pkgdatadir=${prefix}/share/waylandppp',
]

# Build wayland-client+++ (static and shared)
wayland_client_ppp = both_libraries(
  'wayland-client+++',
  include_directories: [ 'include', ],
  sources: [
    join_paths(build_root, 'wayland-version.hpp'),
    join_paths(git_root, 'src/wayland-client.cpp'),
    join_paths(git_root, 'src/wayland-util.cpp'),
    wayland_client_protocol,
    wayland_client_protocol_stable
  ],
  dependencies: [ wayland_client_dep ],
)

pkg_config.generate(
  libraries: wayland_client_ppp,
  subdirs: [ 'include' ],
  version: meson.project_version(),
  filebase: 'wayland-client+++',
  name: 'Wayland C++ Client',
  description: 'Wayland C++ client side library',
  variables: pkg_vars,
)
# Build wayland-client-stable+++ (static and shared)
wayland_client_stable_ppp = both_libraries(
  'wayland-client-stable+++',
  include_directories: [ 'include', ],
  override_options: ['b_lundef=false'],
  sources: [
    wayland_client_protocol_stable,
    join_paths(build_root, 'wayland-version.hpp'),
    join_paths(git_root, 'src/wayland-client.cpp'),
    join_paths(git_root, 'src/wayland-util.cpp'),
  ],
  link_with: [wayland_client_ppp ],
  dependencies: [ wayland_client_dep ],
)

pkg_config.generate(
  libraries: wayland_client_ppp,
  subdirs: [ 'include' ],
  version: meson.project_version(),
  filebase: 'wayland-client-stable+++',
  name: 'Wayland C++ Client Stable Protocols',
  description: 'Wayland C++ client side library stable protocols',
  variables: pkg_vars,
)
# Build wayland-client-unstable+++ (static and shared)
wayland_client_unstable_ppp = both_libraries(
  'wayland-client-unstable+++',
  include_directories: [ 'include', ],
  override_options: ['b_lundef=false'],
  sources: [
    join_paths(git_root, 'src/wayland-client.cpp'),
    join_paths(git_root, 'src/wayland-util.cpp'),
    wayland_client_protocol_unstable,
    wayland_client_protocol,
    join_paths(build_root, 'wayland-version.hpp'),
  ],
  link_with: [wayland_client_ppp, wayland_client_stable_ppp ],
  dependencies: [ wayland_client_dep ],
)

pkg_config.generate(
  libraries: wayland_client_ppp,
  subdirs: [ 'include' ],
  version: meson.project_version(),
  filebase: 'wayland-client-unstable+++',
  name: 'Wayland C++ Client Unstable Protocols',
  description: 'Wayland C++ client side library unstable protocols',
  variables: pkg_vars,
)

# Build wayland-server+++ (static and shared)
wayland_server_ppp = both_libraries(
  'wayland-server+++',
  include_directories: [ 'include', ],
  sources: [
    wayland_server_protocol,
    join_paths(git_root, 'src/wayland-server.cpp'),
    join_paths(git_root, 'src/wayland-util.cpp'),
  ],
  dependencies: [ wayland_server_dep ],
  install: true,
)

pkg_config.generate(
  libraries: wayland_server_ppp,
  subdirs: [ 'include' ],
  version: meson.project_version(),
  filebase: 'wayland-server+++',
  name: 'Wayland C++ Server',
  description: 'Wayland C++ server side library',
  variables: pkg_vars,
)

# Build wayland-server-stable+++ (static and shared)
wayland_server_stable_ppp = both_libraries(
  'wayland-server-stable+++',
  include_directories: [ 'include', ],
  override_options: ['b_lundef=false'],
  sources: [
    wayland_server_protocol,
    wayland_server_protocol_stable,
    join_paths(git_root, 'src/wayland-server.cpp'),
    join_paths(git_root, 'src/wayland-util.cpp'),
  ],
  link_with: [ wayland_server_ppp ],
  dependencies: [ wayland_server_dep ],
)

pkg_config.generate(
  libraries: wayland_server_stable_ppp,
  subdirs: [ 'include' ],
  version: meson.project_version(),
  filebase: 'wayland-server-stable+++',
  name: 'Wayland C++ Server Stable Protocols',
  description: 'Wayland C++ server side library stable protocols',
  variables: pkg_vars,
)

# Build wayland-server-unstable+++ (static and shared)
wayland_server_unstable_ppp = both_libraries(
  'wayland-server-unstable+++',
  include_directories: [ 'include', ],
  sources: [
    wayland_server_protocol_unstable,
    wayland_server_protocol,
    join_paths(git_root, 'src/wayland-server.cpp'),
    join_paths(git_root, 'src/wayland-util.cpp'),
  ],
  dependencies: [ wayland_server_dep ],
  link_with: [wayland_server_ppp, wayland_server_stable_ppp ],
  install: true,
)

pkg_config.generate(
  libraries: wayland_server_unstable_ppp,
  subdirs: [ 'include' ],
  version: meson.project_version(),
  filebase: 'wayland-server-unstable+++',
  name: 'Wayland C++ Server Unstable Protocols',
  description: 'Wayland C++ server side library unstable protocols',
  variables: pkg_vars,
)

# Create and install the HTML based API documentation (requires Doxygen)
# Configurable with the BUILD_DOCUMENTATION option (default: true)
subdir('doc')
