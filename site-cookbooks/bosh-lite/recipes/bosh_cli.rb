include_recipe 'bosh-lite::rbenv'

rbenv_gem 'bosh_cli' do
  ruby_version "1.9.3-p448"
end

rbenv_gem 'bosh_cli' do
  ruby_version "1.9.3-p484"
end
