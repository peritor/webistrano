# see http://groups.google.com/group/capistrano/browse_thread/thread/b5e11c0ebf37a8be
Capistrano::Configuration::Namespaces::Namespace.class_eval { undef :symlink }