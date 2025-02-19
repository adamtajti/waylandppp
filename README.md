# waylandppp

Wayland is an object oriented display protocol, which features request
and events. Requests can be seen as method calls on certain objects,
whereas events can be seen as signals of an object. This makes the
Wayland protocol a perfect candidate for a C++ binding.

The goal of this library is to create such a C++ binding for Wayland
using the most modern C++ technology currently available, providing
an easy to use C++ API to Wayland.

## Fork

This fork was created because there were ongoing compilation issues on
the upstream repo and the pull requests were kept unreviewed. One additional
reason was to add support for Meson builds, so that this project can be
included as a subproject wrap to another project that I'm working on.

I attempted to add bindings for the wlr-protocols as well. The project thus
have been modified enough to give it a new name, which will be `waylandppp`
for now.

## Requirements

To build this library, a recent version of cmake is required. Furthermore,
a recent C++ Compiler with C++11 support, such as GCC or clang, is required.
Also, pugixml is required to build the XML protocol scanner. Apart from the
Wayland libraries, there are no further library dependencies.

The documentation is autogenerated using Doxygen, therefore doxygen as
well as graphviz is required.

## Building

### Debug

```bash
# -Db_sanitize=address
# address sanitizer support
#
# --prefix=/usr
# on my system, Meson chose /usr/local/lib64 for libdir by default, which was
# problematic, because pkg-config doesn't search in that directory by default.
# As a workaround, lets set the prefix in the setup call
meson setup -Db_sanitize=address --prefix=/usr --reconfigure build
meson compile -C build
meson install -C build
```

### Release

```bash
meson setup -Dbuildtype=release -Doptimization=3 -Ddebug=false --prefix=/usr --reconfigure build
meson compile -C build
meson install -C build
```

### Documentation

If the requirements are met, the documentation will normally be built
automatically. HTML pages, LaTeX source files as well as manpages are generated.

To build the documentation manually, `doxygen` needs to be executed
in the root directory of the repository. The resulting documentation
can then be found in the `doc` directory. The required Doxyfile is
available after the library has been built. The documentaion is also
online availabe [here](https://nilsbrause.github.io/waylandpp_docs/).

### Example programs

To build the example programs the `BUILD_EXAMPLES` option needs to be enabled
during the build. The resulting binaries will be put under the `example`
directory inside the build directory. They can be run directly without
installing the library first.

To build the example programs manually, `make` can executed in
the example directory after the library has been built and installed.

## Usage

In the following, it is assumed that the reader is familiar with
basic Wayland concepts and at least version 11 of the C++
programming language.

### Clients

Each interface is represented by a class. E.g. the `wl_registry`
interface is represented by the `registry_t` class.

An instance of a class is a wrapper for a Wayland object (a `wl_proxy`
pointer). If a copy is made of a particualr instance, both instances
refer to the same Wayland object. The underlying Wayland object is
destroyed once there are no copies of this object left. Only a few
classes are non-copyable, namely `display_t` and `egl_window_t`.
There are also special rules for proxy wrappers and the use of
foreigen objects. Refer to the documentation for more details.

A request to an object of a specific interface corresponds to a method
in this class. E.g. to marshal the `create_pool` request on an
`wl_shm` interface, the `create_pool()` method of an instance of
`shm_t` has to be called:

    shm_t shm;
    int fd;
    int32_t size;
    // ... insert the initialisation of the above here ...
    shm_pool_t shm_pool = shm.create_pool(fd, size);

Some methods return newly created instances of other classes. In this
example an instance of the class `shm_pool_t` is returned.

Events are implemented using function objects. To react to an event, a
function object with the correct signature has to be assigned to
it. These can not only be static functions, but also member functions
or closures. E.g. to react to global events from the registry using a
lambda expression, one could write:

    registry.on_global() = [] (uint32_t name, std::string interface,
                               uint32_t version)
      { std::cout << interface << " v" << version << std::endl; };

An example for using member functions can be found in
example/opengles.cpp or example/shm.cpp.

The Wayland protocol uses arrays in some of its events and requests.
Since these arrays can have arbitrary content, they are not directly
mapped to a std::vector. Instead there is a new type array_t, which
can converted to and from a std::vectory with an user specified type.
For example:

    keyboard.on_enter() = [] (uint32_t serial, surface_t surface,
                              array_t keys)
      { std::vector<uint32_t> vec = keys; };

### Servers

Instead of proxies the object wrappers of a specific interface are
called resources and are represented by a `resource_t` object. They
are pretty similar to proxies, as they have events and requests.

The server bindings allow the creation of global objects. These can
be constructed by prepending `global_` to the class name. They have
to be initialised with the display object:

    display_t display;
    global_output_t output(display);

Global objects only have a single event called "on_bind", that is
called whenever a client binds to this interface. The event then
supplies the corresponding resource:

    output.on_bind() = [this] (client_t client, output_t output) { /* ... */ }

A `client_t` object which represents the client connected to the
server is also supplied with the bind event.

The client and resource objects should be saved for later to be able
to identify the exact origin of a request. To help with that, all
server-side wrapper classes allow saving of user data through the
`user_data()` member which returns a reference to an `any` type.

### Compiling

To compile code that using this library, pkg-config can be used to
take care of the compiler flags. Assuming the source file is called
`foo.cpp` and the executable shall be called `foo` type:

    $ c++ -c foo.cpp `pkg-config --cflags wayland-client++` -o foo.o
    $ c++ foo.o `pkg-config --libs wayland-client++` -o foo

If the library and headers are installed in the default search paths
of the compiler, the linker flag `-lwayland-client++` can also
directly be specified on the command line.

If the Wayland cursor classes and/or EGL is used, the corresponding
libreries `wayland-cursor++` and/or `wayland-egl++` need to be linked
in as well. If any extension protocols such as xdg-shell are used,
the library `wayland-client-extra++` should be linked in as well,
and if the Waylans server bindings are used, the library
`wayland-server++` needs to be linked in as well.

Further examples can be found in the examples/Makefile.
