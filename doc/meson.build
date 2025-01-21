install_docs = get_option('install-documentation')
summary({'Documentation ': install_docs}, bool_yn: true)
if not install_docs
  subdir_done()
endif

doxygen = find_program('doxygen')
if not doxygen.found()
  error('doxygen binary cannot be found. Set the BUILD_DOCUMENTATION meson option to false, if you don\'t want to build the documentation')
  subdir_done()
endif

cdata = configuration_data()
cdata.set('PROJECT_VERSION', meson.project_version())
cdata.set('WAYLANDPP_DOXYGEN_OUTPUT_DIRECTORY', join_paths(meson.project_build_root(), 'doc'))
cdata.set('WAYLANDPP_BUILD_DIRECTORY', meson.project_build_root())

doxyfile = configure_file(
  input: 'Doxyfile.in',
  output: 'Doxyfile',
  configuration: cdata,
)

docdir = get_option('docdir')
if docdir == ''
  docdir = waylandppp_datadir / 'doc' / meson.project_name()
endif

# could be built on demand with ninja -C build doc/html if build_by_default is set to false
doxygen_html_docs = custom_target('doc',
  build_by_default: true,
  command: [doxygen, '-q', doxyfile],
  output: ['html'],
  install: true,
  install_tag: 'doc',
  install_dir: docdir,
)
