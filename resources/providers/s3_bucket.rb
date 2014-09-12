require 'chef/mixin/language'

def whyrun_supported?
  true
end

action :sync do
 Chef::Log.debug("Checking #{new_resource} for changes")

 Chef::Log.debug("File #{current_resource} checksum didn't match target checksum (#{new_resource.checksum}), updating")
 fetch_from_s3(new_resource.source) do |raw_file|
   Chef::Log.debug "copying remote file from origin #{raw_file.path} to destination #{new_resource.destination}"
   FileUtils.cp raw_file.path, new_resource.destination
 end

 new_resource.updated
end

def load_current_resource
  chef_gem 'aws-sdk' do
    action :install
  end

  require 'aws/s3'

  current_resource = new_resource.destination
  current_resource
end

def fetch_from_s3(source)
  begin
    protocol, bucket = URI.split(source).compact
    AWS::S3::Base.establish_connection!(
        :access_key_id     => new_resource.access_key_id,
        :secret_access_key => new_resource.secret_access_key
    )

    bucket.objects.each do |obj|
      name = obj.key

      if !new_resource.skip.contains(name)
        Chef::Log.debug("Downloading #{name} from S3 bucket #{bucket}")
        obj = AWS::S3::S3Object.find name, bucket

        file = Tempfile.new("chef-s3-file")
        file.write obj.value
        Chef::Log.debug("File #{name} is #{file.size} bytes on disk")
        begin
          yield file
        ensure
          file.close
        end
      else
        Chef::Log.debug("Skipping #{name} because it's in the skip list")
      end
    end

  rescue URI::InvalidURIError
    Chef::Log.warn("Expected an S3 URL but found #{source}")
    nil
  end
end
