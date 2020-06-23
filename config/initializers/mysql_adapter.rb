# Avoid "All parts of a PRIMARY KEY must be NOT NULL; if you need NULL in a
# key, use UNIQUE instead" errors on MySQL 5.7 and above.

class ActiveRecord::ConnectionAdapters::MysqlAdapter
  NATIVE_DATABASE_TYPES[:primary_key] = "int(11) auto_increment PRIMARY KEY"
end
