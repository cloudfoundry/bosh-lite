# Install an NFS server for use by CloudFoundry
nfs_export = '/export/blobstore'

directory ::File.join(nfs_export, 'shared') do
  mode 0755
  action :create
  recursive true
end

template '/etc/exports' do
  source 'exports.erb'
  mode 0755
  owner 'vagrant'
  variables(nfs_export: nfs_export)
end

package 'nfs-kernel-server'
