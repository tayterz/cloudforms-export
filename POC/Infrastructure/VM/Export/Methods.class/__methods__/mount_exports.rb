#
# Description: Mounts the exports storage domain to the appliance
# Author: Kenneth Evensen <kenneth.evensen@redhat.com>
# Updated by: Taylor Biggs <taylor@redhat.com> 9/29/2015
#  - Added glusterfs stuff...
#  - Added previous-mount check (avoids gluster bug# 1088589)
#

require 'rest-client'
require 'nokogiri'
require 'open3'

@method = 'mount_exports'
$evm.log("info", "----Entering method #{@method}----")

# first, check to see if /mnt/exports is already mounted...
cmd = "mount | grep /mnt/exports"
mounted = false
error = false

Open3.popen3(cmd) do |stdin, stdout, stderr, wthr|
  stderr.each_line { |errline| $evm.log("error","#{errline}")
    error = true
    }
  stdout.each_line { |outline| $evm.log("info","#{outline}")
    mounted = true
    }
end

if mounted
  $evm.log("info","/mnt/exports already mounted")
  exit MIQ_OK
end 

if error
  $evm.log("error","Error in mount command.")
  exit MIQ_ABORT
end


export_domain = nil

vm = $evm.root['vm']
mgmt_sys=vm.ext_management_system


stores = mgmt_sys.storages

stores.each { |store| 
  
  $evm.log("info"," Store Name - #{store.name}")
  if store.name.eql? $evm.object['export_domain']
    export_domain = store
  end
    
}

$evm.log("info","Selected #{export_domain} as Export Domain")

export_store_id =  export_domain.ems_ref.sub("/api/storagedomains/","")

url = "https://"+mgmt_sys.hostname+":443/"+export_domain.ems_ref
user = mgmt_sys.authentication_userid
password = mgmt_sys.authentication_password

$evm.log("info","URL - #{url}")

#payload = "<action><storage_domain id=\"#{export_store_id}\"/><exclusive>true</exclusive></action>"

response = RestClient::Request.new(
 		  :method => :get,
          :url => url,
  		  :user => user,
          :password => password,
  		  :verify_ssl => false,
          :headers => { :accept => :xml,
          :content_type => :xml }
      ).execute

xml_response  = Nokogiri::XML(response)

$evm.log("info","Response - #{response}")

fs_type = xml_response.xpath("/storage_domain/storage/type[1]").first.content

unless fs_type.eql? 'nfs' or fs_type.eql? 'glusterfs'
  $evm.log("error","Unsupported filesystem #{fs_type} detected.")
  exit MIQ_ABORT
end
  
fs_server = xml_response.xpath("/storage_domain/storage/address[1]").first.content
fs_path = xml_response.xpath("/storage_domain/storage/path[1]").first.content

$evm.log("info", "fs_type = #{fs_type}")

if fs_type.eql? 'glusterfs'
  $evm.log("info", "Gluster Detected, mounting #{export_domain} with gluster")
  cmd = "mkdir -p /mnt/exports; mount -t glusterfs #{fs_server}:#{fs_path} /mnt/exports"

  $evm.log("info","Mount Command = #{cmd}")

  Open3.popen3(cmd) do |stdin, stdout, stderr, wthr|
	
    error = false
    stderr.each_line { |line| $evm.log("error","#{line}")
      unless line.include? "already mounted"
      	error = true
      else
        error = false
      end
      }    
  
    if error
      $evm.log("error","Unable to mount #{export_domain} to /mnt/exports")
      exit MIQ_ABORT
    end
  end
end

if fs_type.eql? 'nfs'
  $evm.log("info", "NFS Detected, mounting #{export_domain} with NFS")
  cmd = "mkdir -p /mnt/exports; mount -o vers=3 #{export_domain.location} /mnt/exports"

  $evm.log("info","Mount Command = #{cmd}")

  Open3.popen3(cmd) do |stdin, stdout, stderr, wthr|
	
    error = false
    stderr.each_line { |line| $evm.log("error","#{line}")
      unless line.include? "already mounted"
      	error = true
      else
        error = false
      end
      }    
  
    if error
      $evm.log("error","Unable to mount #{export_domain.location} to /mnt/exports")
      exit MIQ_ABORT
    end
  end
end


$evm.log("info", "----Exiting method #{@method}----")
