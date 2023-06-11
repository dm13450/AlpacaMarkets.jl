function announcements_url(ca_types, since::Date, until::Date; symbol="none", cusip="none", date_type="none")

  @assert ca_types in ["dividend", "merger", "split", "spinoff"]

  params = Dict("ca_types" => ca_types, "since" => since, "until" => until)

  for x in [symbol, cusip, date_type]
    if x != "none"
      params["$x"] = x
    end
  end

  join([TRADING_API_URL, "corporate_actions/announcements"], "/") * "?" * params_uri(params)
end


function get_announcements(ca_types, since::Date, until::Date; symbol="none", cusip="none", date_type="none")
  url = announcements_url(ca_types, since, until; symbol=symbol, cusip=cusip, date_type=date_type)
  res = HTTP.get(url, headers = HEADERS[])
  resdict = JSON.parse(String(res.body))
  vcat(DataFrame.(resdict)...; cols = :union)
end

#Doesn't look like its working atm
function get_announcement(announcement_id::String)
  url = join([TRADING_API_URL, "corporate_actions/announcements"], "/") * "/id?announcement_id=" * announcement_id 
  res = HTTP.get(url, headers = HEADERS[])
  resdict = JSON.parse(String(res.body))
  DataFrame(resdict)
end