namespace :db do
  namespace :seed do
    task :test_data => :environment do
      system('rails dbconsole < lib/tasks/users_data.sql')
    end
  end
end