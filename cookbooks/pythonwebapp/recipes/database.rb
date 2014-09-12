include_recipe "database::postgresql"

dbname = node[:webapp][:dbname]
dbuser = node[:webapp][:dbuser]
dbpass = node[:webapp][:dbpass]

postgresql_connection_info = {
  :host     => 'localhost',
  :port     => node['postgresql']['config']['port'],
  :username => 'postgres',
  :password => node['postgresql']['password']['postgres']
}

postgresql_database 'webapp' do
  connection postgresql_connection_info
  action     :create
end


postgresql_database_user dbuser do
  connection postgresql_connection_info
  password   dbpass
  action     :create
end

# Grant all privileges on all tables in 'webapp'
postgresql_database_user dbuser do
  connection    postgresql_connection_info
  database_name dbname
  privileges    [:all]
  action        :grant
end
