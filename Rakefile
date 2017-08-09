require "bundler/gem_tasks"

WINDOWS = (/cygwin|mswin|mingw|bccwin|wince|emx/ =~ RUBY_PLATFORM) != nil
PROTOC_PLUGIN_PATH = File.join Gem.bindir, "protoc-gen-ruby#{if WINDOWS then '.bat' else '' end}"
PROTO_DIR = './lib/aquae/protos'
PROTOS = Rake::FileList['metadata.pb.rb', 'messaging.pb.rb', 'transport.pb.rb'].pathmap("#{PROTO_DIR}/%f")

task :default => :protos

directory PROTO_DIR
task :protos => [PROTO_DIR, *PROTOS]

rule '.pb.rb' do |p|
  sh 'protoc',
    "../pde-specification/#{p.name.pathmap('%{.pb,}n')}.proto",
    '-I', '../pde-specification/',
    "--ruby2_out=#{p.name.pathmap('%d')}",
    "--plugin=protoc-gen-ruby2=#{PROTOC_PLUGIN_PATH}"
end
