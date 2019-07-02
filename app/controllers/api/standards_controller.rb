class Api::StandardsController < BaseController
  def index
    res = Standard.pluck(:id, :standard, :section)
    records = res.inject({}){|result, std| r = { std[1] => [{ name: std[2], id: std[0] }] }; result.merge!(r){ |std, old, new| old + new }; result }
    render json: { data: records, status: 200 }
  end
end