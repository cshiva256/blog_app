module ExceptionsHandler
  extend ActiveSupport::Concern

  included do
    rescue_from ActiveRecord::RecordNotFound do |error|
      error!({ error: error.message }, 404)
    end

    rescue_from ActiveRecord::RecordInvalid do |error|
        error!({ error: error.message }, 422)
    end

    rescue_from :all do |error|
      error!({ error: error.message }, 500)
    end
  end
end
