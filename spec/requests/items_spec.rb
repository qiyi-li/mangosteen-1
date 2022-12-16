require "rails_helper"

RSpec.describe "Items", type: :request do
  describe "获取账目" do
    it "分页" do
      user1 = User.create email: "1@qq.com"
      user2 = User.create email: "2@qq.com"
      11.times { Item.create amount: 100, user_id: user1.id }
      11.times { Item.create amount: 100, user_id: user2.id }

      get "/api/v1/items", headers: user1.generate_auth_header

      expect(response).to have_http_status 200
      json = JSON.parse(response.body)
      expect(json["resources"].size).to eq 10
      get "/api/v1/items?page=2", headers: user1.generate_auth_header
      expect(response).to have_http_status 200
      json = JSON.parse(response.body)
      expect(json["resources"].size).to eq 1
    end
    it "按时间筛选" do
      user1 = User.create email: "1@qq.com"
      item1 = Item.create amount: 100, created_at: "2018-01-02", user_id: user1.id
      item2 = Item.create amount: 100, created_at: "2018-01-02", user_id: user1.id
      item3 = Item.create amount: 100, created_at: "2019-01-01", user_id: user1.id

      get "/api/v1/items?created_after=2018-01-01&created_before=2018-01-03", headers: user1.generate_auth_header
      expect(response).to have_http_status 200
      json = JSON.parse(response.body)
      expect(json["resources"].size).to eq 2
      expect(json["resources"][0]["id"]).to eq item1.id
      expect(json["resources"][1]["id"]).to eq item2.id
    end
    it "按时间筛选（边界条件）" do
      user1 = User.create email: "1@qq.com"
      item1 = Item.create amount: 100, created_at: "2018-01-01", user_id: user1.id

      get "/api/v1/items?created_after=2018-01-01&created_before=2018-01-02", headers: user1.generate_auth_header
      expect(response).to have_http_status 200
      json = JSON.parse(response.body)
      expect(json["resources"].size).to eq 1
      expect(json["resources"][0]["id"]).to eq item1.id
    end
    it "按时间筛选（边界条件2）" do
      user1 = User.create email: "1@qq.com"
      item1 = Item.create amount: 100, created_at: "2018-01-01", user_id: user1.id
      item2 = Item.create amount: 100, created_at: "2017-01-01", user_id: user1.id
      get "/api/v1/items?created_after=2018-01-01", headers: user1.generate_auth_header
      expect(response).to have_http_status 200
      json = JSON.parse(response.body)
      expect(json["resources"].size).to eq 1
      expect(json["resources"][0]["id"]).to eq item1.id
    end
    it "按时间筛选（边界条件3）" do
      user1 = User.create email: "1@qq.com"
      item1 = Item.create amount: 100, created_at: "2018-01-01", user_id: user1.id
      item2 = Item.create amount: 100, created_at: "2019-01-01", user_id: user1.id

      get "/api/v1/items?created_before=2018-01-02", headers: user1.generate_auth_header
      expect(response).to have_http_status 200
      json = JSON.parse(response.body)
      expect(json["resources"].size).to eq 1
      expect(json["resources"][0]["id"]).to eq item1.id
    end
  end
  describe "创建账目" do
    it "未登录创建" do
      expect {
        post "/api/v1/items", params: { amount: 99 }
      }.to change { Item.count }.by 0
      expect(response).to have_http_status 401
    end
    it "登陆后创建" do
      user1 = User.create email: "1@qq.com"
      tag1 = Tag.create name: "吃饭", sign:'x', user_id: user1.id
      tag2 = Tag.create name: "吃饭1", sign:'x1', user_id: user1.id
      expect {
        post "/api/v1/items", params: { amount: 99 ,tags_id:[tag1.id,tag2.id], happen_at:'2008-12-01T14:00:00+8:00'}, headers: user1.generate_auth_header
      }.to change { Item.count }.by 1
      expect(response).to have_http_status 200
      json = JSON.parse(response.body)
      expect(json['resource']['amount']).to eq 99
      expect(json['resource']['user_id']).to eq user1.id
    end
    it "创建时 amount、tags_id、happen_at 必填" do
      user1 = User.create email: "1@qq.com"
      post "/api/v1/items", params: {} , headers: user1.generate_auth_header
      expect(response).to have_http_status 422
      json = JSON.parse(response.body)
      expect(json['errors']['amount']).to eq ["can't be blank"]
      expect(json['errors']['tags_id']).to eq ["can't be blank"]
      expect(json['errors']['happen_at']).to eq ["can't be blank"]
    end
  end
end
