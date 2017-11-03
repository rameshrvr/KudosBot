require 'mysql2'

module DBInt
  def init_db_object
    # Create a Database object
    @db = Mysql2::Client.new(
      host: 'localhost',
      username: ENV['SQL_USERNAME'],
      password: ENV['SQL_PASSWORD'],
      database: 'kudos_bot'
    )
  end

  def update_details(**params)
    columns, values = [], []
    params.each do |key, value|
      columns.push(key.to_s)
      values.push("'#{value.to_s}'")
    end
    @db.query("insert into kudos (#{columns.join(',')}) values (#{values.join(',')})")
  end

  def get_leaderboard
    get_board_details(who: 'performer')
  end

  def get_giverboard
    get_board_details(who: 'createdby')
  end

  # Method to fetch details for users
  def get_board_details(
      who:
    )
    result = Array.new { Hash.new }
    # In Default take last 30 days of record
    data = @db.query(
      "select distinct #{who} from kudos where created >= adddate(now(), INTERVAL-1 MONTH)"
    ).as_json
    data.each_with_index do |single_user|
      user = single_user[who]
      temp = @db.query(
        "select count(#{who}) from kudos where #{who} = '#{user}' and created >= adddate(now(), INTERVAL-1 MONTH)"
      ).as_json[0].values.join()
      result.push("#{user}" => temp)
    end
    # Return result as an Array of Hash
    result
  end
end
