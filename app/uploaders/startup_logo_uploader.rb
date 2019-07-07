# frozen_string_literal: true

class StartupLogoUploader < CarrierWave::Uploader::Base
  include UploaderConcern

  def default_url
    ActionController::Base.helpers.asset_path('avatars_fallback/' + [version_name, 'default.png'].compact.join('_'))
  end

  version :big do
    process resize_to_fit: [512, 512]
  end

  version :medium do
    process resize_to_fit: [256, 256]
  end

  version :small do
    process resize_to_fit: [32, 32]
  end
end
