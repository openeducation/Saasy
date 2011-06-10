module LimitsHelper
  def current_percentage(limit, account)
    number_to_percentage((limit.current_count(account).to_f / limit.value) * 100)
  end

  def render_limit_meter(limit)
    if FileTest.exist?(File.join(Rails.root, 'app', 'views', 'limits' , "_#{limit.name}_meter.html.erb"))
      render "limits/#{limit.name}_meter", :limit => limit
    else
      render "limits/meter", :limit => limit
    end
  end
end
