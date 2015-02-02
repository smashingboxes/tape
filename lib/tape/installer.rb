module TapeBoxer
  class Installer < ExecutionModule
    TapeBoxer.register_module :installer, self

    action :install,
      proc {install},
      'Creates all nessisary hosts and config files'
    action :uninstall,
      proc {uninstall},
      'Cleans up files generated by the installer'

    def initialize(*args)
      super
    end

    protected
    def install
      puts "Installing ansible galaxy roles".pink
      `ansible-galaxy install -r #{tape_dir}/requirements.yml -p #{tape_dir}/vendor --force`
      mkdir 'roles'
      copy_example 'omnibox.example.yml', 'omnibox.yml'
      copy_example 'deploy.example.yml', 'deploy.yml'
      copy_example 'tape_vars.example.yml', 'tape_vars.yml'
      copy_example 'hosts.example', 'hosts'
      mkdir 'dev_keys'
      print 'Are you going to user vagrant? (y/n): '
      if gets.chomp == 'y'
        copy_example 'Vagrantfile', 'Vagrantfile'
      end
    end

    def uninstall
      rm 'omnibox.yml'
      rm 'deploy.yml'
      rm 'tape_vars.yml'
      rm 'roles'
      rm 'hosts'
      rm 'dev_keys'
      rm 'Vagrantfile'
    end

    def rm(file)
      print 'Deleting '.red
      FileUtils.rm_r "#{local_dir}/#{file}"
      puts file
    end

    def mkdir(name)
      print "#{name}: "
      begin
        FileUtils.mkdir name
        puts '✔'.green
      rescue Errno::EEXIST
        puts '✘ (Exists)'.green
      rescue Exception => e
        puts '✘'.red
        raise e
      end
    end

    def touch(file)
      File.new "#{local_dir}/#{file}", 'w'
    end

    def copy_example(file, cp_file)
      print "#{cp_file}: "
      begin
        if File.exists?("#{local_dir}/#{cp_file}")
          puts '✘ (Exists)'.green
        else
          FileUtils.cp("#{tape_dir}/#{file}", "#{local_dir}/#{cp_file}")
          puts '✔'.green
        end
      rescue Exception => e
        puts '✘'.red
        raise e
      end
    end
  end
end

class String
  # colorization
  def colorize(color_code)
    "\e[#{color_code}m#{self}\e[0m"
  end

  def red
    colorize(31)
  end

  def green
    colorize(32)
  end

  def yellow
    colorize(33)
  end

  def pink
    colorize(35)
  end
end
