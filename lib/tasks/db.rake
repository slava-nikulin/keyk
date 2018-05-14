namespace :db do
  desc 'Recreate db'
  task recreate: :environment do
    Rake::Task['db:drop'].invoke
    Rake::Task['db:create'].invoke
    Rake::Task['db:migrate'].invoke
    system('RAILS_ENV=test rails db:migrate')
    Rake::Task['db:seed'].invoke
  end
end
