#!/usr/bin/ruby

#
# This is just a container class basically, that acts like File::Struct
#
# You must supply an initialize method that somehow populates the stathash..
#

module Rex
module Post

class FileStat
	@@ftypes = [
	  'fifo', 'characterSpecial', 'directory',
	  'blockSpecial', 'file', 'link', 'socket'
	]

#	class <<self
#		attr_accessor :client
#	end

	private
	attr_accessor :stathash
	public

#	def initialize(file)
#		self.stathash = self.class.client.file.stat_hash(file)
#	end

	def dev
		stathash['st_dev']
	end
	def ino
		stathash['st_ino']
	end
	def mode
		stathash['st_mode']
	end
	def nlink
		stathash['st_nlink']
	end
	def uid
		stathash['st_uid']
	end
	def gid
		stathash['st_gid']
	end
	def rdev
		stathash['st_rdev']
	end
	def size
		stathash['st_size']
	end
	def blksize
		stathash['st_blksize']
	end
	def blocks
		stathash['st_blocks']
	end
	def atime
		Time.at(stathash['st_atime'])
	end
	def mtime
		Time.at(stathash['st_mtime'])
	end
	def ctime
		Time.at(stathash['st_ctime'])
	end


	#
	# S_IFMT     0170000   bitmask for the file type bitfields
	# S_IFSOCK   0140000   socket
	# S_IFLNK    0120000   symbolic link
	# S_IFREG    0100000   regular file
	# S_IFBLK    0060000   block device
	# S_IFDIR    0040000   directory
	# S_IFCHR    0020000   character device
	# S_IFIFO    0010000   fifo
	#

	# this is my own, just a helper...
	def filetype?(mask)
		return true if mode & 0170000 == mask
		return false
	end

	def blockdev?
		filetype?(060000)
	end
	def chardev?
		filetype?(020000)
	end
	def directory?
		filetype?(040000)
	end
	def file?
		filetype?(0100000)
	end
	def pipe?
		filetype?(010000) # ??? fifo?
	end
	def socket?
		filetype(0140000)
	end
	def symlink?
		filetype(0120000)
	end

	def ftype
		return @@ftypes[(mode & 0170000) >> 13].dup
	end

	#
	# S_ISUID    0004000   set UID bit
	# S_ISGID    0002000   set GID bit (see below)
	# S_ISVTX    0001000   sticky bit (see below)
	# S_IRWXU    00700     mask for file owner permissions
	# S_IRUSR    00400     owner has read permission
	# S_IWUSR    00200     owner has write permission
	# S_IXUSR    00100     owner has execute permission
	# S_IRWXG    00070     mask for group permissions
	# S_IRGRP    00040     group has read permission
	# S_IWGRP    00020     group has write permission
	# S_IXGRP    00010     group has execute permission
	# S_IRWXO    00007     mask for permissions for others (not in group)
	# S_IROTH    00004     others have read permission
	# S_IWOTH    00002     others have write permisson
	# S_IXOTH    00001     others have execute permission
	#

	def perm?(mask)
		return true if mode & mask == mask
		return false
	end

	def setgid?
		perm?(02000)
	end
	def setuid?
		perm?(04000)
	end
	def sticky?
		perm?(01000)
	end

	def executable?
		raise NotImplementedError
	end
	def executable_real?
		raise NotImplementedError
	end
	def grpowned?
		raise NotImplementedError
	end
	def owned?
		raise NotImplementedError
	end
	def readable?
		raise NotImplementedError
	end
	def readable_real?
		raise NotImplementedError
	end
	def writeable?
		raise NotImplementedError
	end
	def writeable_real?
		raise NotImplementedError
	end

	def prettymode
		m  = mode
		om = '%04o' % m
		perms = ''

		3.times {
			perms = ((m & 01) == 01 ? 'x' : '-') + perms
			perms = ((m & 02) == 02 ? 'w' : '-') + perms
			perms = ((m & 04) == 04 ? 'r' : '-') + perms
			m >>= 3
		}

		return "#{om}/#{perms}"
	end

	def pretty
		"  Size: #{size}   Blocks: #{blocks}   IO Block: #{blksize}   Type: #{rdev}\n"\
		"Device: #{dev}  Inode: #{ino}  Links: #{nlink}\n"\
		"  Mode: #{prettymode}\n"\
		"   Uid: #{uid}  Gid: #{gid}\n"\
		"Access: #{atime}\n"\
		"Modify: #{mtime}\n"\
		"Change: #{ctime}\n"
	end

end
end; end # Post/Rex
