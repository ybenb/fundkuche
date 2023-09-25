# frozen_string_literal: true

class HealthCheckController < ApplicationController
  def index
    val = ActiveRecord::Base.connection.execute('select 1+2 as val').first['val']
    render plain: "1+2=#{val}"
  end
end
