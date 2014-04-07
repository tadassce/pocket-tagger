guard :minitest do
  watch(%r{^spec/(.*)_spec\.rb$})
  watch(%r{^lib/(.+)\.rb$})         { |m| "spec/#{m[1]}_spec.rb" }
  watch(%r{^app\.rb$})              { |m| "spec/app_spec.rb" }
  watch(%r{^spec/spec_helper\.rb$}) { 'spec' }
end

guard 'pow' do
  watch('app.rb')
  watch('config.rb')
  watch('Gemfile')
  watch('Gemfile.lock')
end
