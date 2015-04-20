if Rails.env.development?
  Slim::Engine.default_options(:pretty => true)
end
