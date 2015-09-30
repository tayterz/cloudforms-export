#
# Description: This method will ensure qemu-img is installed for conversion to vmdk or qcow2.
# Author: Kenneth D. Evensen <kenneth.evensen@redhat.com>
# Updated: Taylor Biggs <taylor@redhat.com>
#  - add glusterfs requirement
#  - use RPM instead of yum (in case of broken links)

require 'open3'

@method = 'pre_flight'
$evm.log("info", "----Entering method #{@method}----")

qemu_cmd = "rpm -qa | grep qemu-img"
glust_cmd = "rpm -qa | grep glusterfs-fuse"

Open3.popen3(qemu_cmd) do |stdin, stdout, stderr, wthr|
	
  error = true
  
  stdout.each_line { |line| $evm.log("info","#{line}")
    error = false
    } 
  
  stderr.each_line { |line| $evm.log("error","#{line}")
    error = true
    }    
  
  if error
    $evm.log("error","qemu-img not installed.  Cannot continue.")
    exit MIQ_ABORT
  end
  
end

Open3.popen3(glust_cmd) do |stdin, stdout, stderr, wthr|
	
  error = true
  
  stdout.each_line { |line| $evm.log("info","#{line}")
    error = false
    } 
  
  stderr.each_line { |line| $evm.log("error","#{line}")
    error = true
    }    
  
  if error
    $evm.log("error","glusterfs-fuse not installed.  Cannot continue.")
    exit MIQ_ABORT
  end
  
end

$evm.log("info", "----Exiting method #{@method}----")
