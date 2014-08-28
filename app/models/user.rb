class User < ActiveRecord::Base
  mount_uploader :avatar_image, UserAvatarUploader

  authenticates_with_sorcery!

  enum role: { member: 0, admin: 1 }

  has_many :authentications, dependent: :destroy
  accepts_nested_attributes_for :authentications

  has_many :owner_of_events, class_name: 'Event', foreign_key: 'organizer_id'
  has_many :event_participations
  has_many :member_in_events, class_name: 'Event', through: :event_participations, source: :event

  validates :password, presence: true, if: :password_required?
  validates :password, length: { minimum: 3 }, if: 'password.present?'
  validates :password, confirmation: true, if: :password_required?

  validates :email, presence: true, if: :email_required?
  validates :email, uniqueness: true, if: :email_required?

  before_create :assign_default_role, if: -> { role.nil? }

  def login
    name || email.split('@').first
  end

  def full_name
    [first_name, last_name].compact.join(' ').presence || login
  end

  private

  def password_required?
    (new_record? && authentications.empty?) || password.present?
  end

  def email_required?
    authentications.empty? || name.blank?
  end

  def assign_default_role
    self.role = :member
  end
end
