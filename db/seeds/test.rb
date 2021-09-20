# Country CSV import
require "csv"

CSV.foreach("db/country.csv", headers: true) do |row|
  Country.create!(
    country_name: row["国・地域名"],
    region: row["場所"],
    ancestry: row["ancestry"]
  )
end

# Airline CSV import
CSV.foreach("db/airline.csv", headers: true) do |row|
  Airline.create!(
    airline_name: row["航空会社"],
    country_id: row["国番号"],
    alliance: row["アライアンス"],
    alliance_type: row["アライアンス種別"]
  )
end
