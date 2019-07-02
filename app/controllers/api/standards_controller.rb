# frozen_string_literal: true

class Api::StandardsController < BaseController
  def index
    res = Standard.pluck(:id, :standard, :section)
    records = res.each_with_object({}) {|std, result| r = {std[1] => [{name: std[2], id: std[0]}]}; result.merge!(r) {|_std, old, new| old + new }; }
    render json: {data: records, status: 200}
  end
end
