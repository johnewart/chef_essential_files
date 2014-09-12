actions :sync
default_action :sync if defined?(default_action) # Chef > 10.8

# Default action for Chef <= 10.8
def initialize(*args)
  super
  @action = :sync
end

attribute :destination, :kind_of => String, :name_attribute => true
attribute :omit, :kind_of => Array
attribute :access_key_id, :kind_of => String
attribute :secret_access_key, :kind_of => String
