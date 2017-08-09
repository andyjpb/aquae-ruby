require "bundler/gem_tasks"

WINDOWS = (/cygwin|mswin|mingw|bccwin|wince|emx/ =~ RUBY_PLATFORM) != nil
PROTOC_PLUGIN_PATH = File.join Gem.bindir, "protoc-gen-ruby#{if WINDOWS then '.bat' else '' end}"

task :default => :protos

task :protos => ['metadata.pb.rb', 'messaging.pb.rb']

rule '.pb.rb' do |p|
  sh 'protoc',
    "../pde-specification/#{p.name.sub(/.pb.rb/, '')}.proto",
    '-I', '../pde-specification/',
    '--ruby2_out=.',
    "--plugin=protoc-gen-ruby2=#{PROTOC_PLUGIN_PATH}"
end
