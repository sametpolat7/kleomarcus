# Cloudflare proxies every request to this site, so the peer address Rack sees is a Cloudflare
# edge node and never the visitor. Cloudflare reports the visitor in CF-Connecting-IP, setting
# it on every request it forwards and replacing whatever the client sent, which behind Cloudflare
# makes it the one address header worth trusting. X-Forwarded-For is not: it arrives with the
# edge node appended, and ActionDispatch::RemoteIp discards only private addresses, so it keeps
# the public edge node and reports that as the visitor.
#
# This rewrites X-Forwarded-For rather than assigning remote_ip itself, which leaves
# ActionDispatch::RemoteIp as the single place that decides the answer. Everything downstream
# then agrees on one value: `rate_limit` throttles per visitor instead of per edge node,
# Session#ip_address records who actually signed in, and the logs match both.
#
# A request that reaches the origin without passing through Cloudflare can forge this header —
# but the same request can already forge X-Forwarded-For, so trusting it widens nothing.
# Closing that gap means restricting the origin's port 443 to Cloudflare's ranges, at the
# firewall rather than here.
#
# It lives under lib rather than app because the middleware stack is built before Zeitwerk can
# autoload anything, so this has to be a plain required file. config/environments/production.rb
# requires it and inserts it ahead of ActionDispatch::RemoteIp; no other environment does,
# because Cloudflare fronts nothing else.
class CloudflareRemoteIp
  CONNECTING_IP = "HTTP_CF_CONNECTING_IP"
  FORWARDED_FOR = "HTTP_X_FORWARDED_FOR"

  def initialize(app)
    @app = app
  end

  def call(env)
    visitor_ip = env[CONNECTING_IP]
    env[FORWARDED_FOR] = visitor_ip if visitor_ip.present?

    @app.call(env)
  end
end
