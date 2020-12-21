require 'active_record'

class RailsDbConnPoolPreloader
  def initialize(preload_count: nil, retry_interval_sec: nil)
    @preload_count = preload_count
    @preload_count ||= Integer(ENV['DB_CONN_POOL_PRELOAD_COUNT']) rescue nil
    @preload_count ||= conn_pool.size
    @preload_count = conn_pool.size if @preload_count > conn_pool.size
    @retry_interval_sec ||= Integer(ENV['DB_CONN_POOL_PRELOAD_RETRY_INTERVAL_SEC']) rescue nil
    @retry_interval_sec ||= 1
  end

  def await_preload
    loop do
      unfulfilled, conn_error = try_preload_once

      break if unfulfilled.zero?

      $stdout.puts "unable to fully satisfy database connection pool size, #{unfulfilled} unfulfilled (retrying in #{@retry_interval_sec} sec):"
      $stdout.puts conn_error&.message

      sleep retry_interval_sec
    end
  end

  private

  attr_reader :preload_count, :retry_interval_sec

  def conn_pool
    ActiveRecord::Base.connection_pool
  end

  def used_count
    conn_pool.connections.count(&:in_use?)
  end

  def try_preload_once
    unfulfilled = 0
    conn_error = nil

    conn_pool.synchronize do
      num_to_checkout = (preload_count - used_count)
      num_checked, conn_error = attempt_checkout_n_connections(num_to_checkout)
      unfulfilled = num_to_checkout - num_checked
    end

    [unfulfilled, conn_error]
  end

  def attempt_checkout_n_connections(num_to_acquire)
    checked_connections = []
    num_to_acquire.times.each do
      begin
        checked_connections << conn_pool.checkout(0)
      rescue => conn_error
        return checked_connections.size, conn_error
      end
    end

    checked_connections.size
  ensure
    checked_connections.each { |conn| conn_pool.checkin(conn) }
  end
end
