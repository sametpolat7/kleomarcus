require "rails_helper"
require "middleware/cloudflare_remote_ip"

RSpec.describe CloudflareRemoteIp do
  let(:endpoint) do
    ->(env) { [ 200, { "content-type" => "text/plain" }, [ ActionDispatch::Request.new(env).remote_ip.to_s ] ] }
  end

  let(:visitor)   { "203.0.113.7" }
  let(:edge_node) { "198.51.100.42" }
  let(:kamal_proxy_request) do
    { "REMOTE_ADDR" => "172.17.0.4", "HTTP_X_FORWARDED_FOR" => "#{visitor}, #{edge_node}" }
  end

  def remote_ip_for(env, through_middleware: true)
    app = ActionDispatch::RemoteIp.new(endpoint)
    app = described_class.new(app) if through_middleware

    Rack::MockRequest.new(app).get("/", env).body
  end

  it "reports the visitor Cloudflare names rather than the edge node" do
    request = kamal_proxy_request.merge("HTTP_CF_CONNECTING_IP" => visitor)

    expect(remote_ip_for(request)).to eq(visitor)
  end

  it "corrects a request that would otherwise resolve to the edge node" do
    request = kamal_proxy_request.merge("HTTP_CF_CONNECTING_IP" => visitor)

    expect(remote_ip_for(request, through_middleware: false)).to eq(edge_node)
  end

  it "leaves X-Forwarded-For alone when Cloudflare did not set the header" do
    request = { "REMOTE_ADDR" => "172.17.0.4", "HTTP_X_FORWARDED_FOR" => edge_node }

    expect(remote_ip_for(request)).to eq(edge_node)
  end

  it "leaves X-Forwarded-For alone when the header is blank" do
    request = { "REMOTE_ADDR" => "172.17.0.4", "HTTP_X_FORWARDED_FOR" => edge_node, "HTTP_CF_CONNECTING_IP" => "" }

    expect(remote_ip_for(request)).to eq(edge_node)
  end

  it "falls back to the peer address when the reported value is not an address" do
    request = kamal_proxy_request.merge("HTTP_CF_CONNECTING_IP" => "not-an-address")

    expect(remote_ip_for(request)).to eq("172.17.0.4")
  end
end
