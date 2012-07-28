Rails.application.config.middleware.use OmniAuth::Builder do
  if Rails.env.production?
    provider :google, ENV['GOOGLE_KEY'], ENV['GOOGLE_SECRET']
  else
    provider :developer
  end
end
