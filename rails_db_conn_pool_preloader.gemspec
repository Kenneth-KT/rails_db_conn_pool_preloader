Gem::Specification.new do |s|
  s.name        = 'rails_db_conn_pool_preloader'
  s.version     = '1.0.0'
  s.date        = '2020-12-21'
  s.summary     = "A gem for preloading your database connection pool to force scaling up of the connected database system"
  s.description = "A gem for preloading your database connection pool to force scaling up of the connected database system"
  s.authors     = ["Kenneth Law"]
  s.email       = 'cyt05108@gmail.com'
  s.files       = ["lib/rails_db_conn_pool_preloader.rb"]
  s.homepage    =
    'https://github.com/Kenneth-KT/rails_db_conn_pool_preloader'
  s.license       = 'MIT'
  s.add_runtime_dependency 'activerecord'
end
