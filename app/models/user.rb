# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  name                   :string(255)
#  email                  :string(255)      default(""), not null
#  encrypted_password     :string(255)      default(""), not null
#  reset_password_token   :string(255)
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0)
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :string(255)
#  last_sign_in_ip        :string(255)
#  confirmation_token     :string(255)
#  confirmed_at           :datetime
#  confirmation_sent_at   :datetime
#  unconfirmed_email      :string(255)
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  bio                    :text
#  website                :string(255)
#  slug                   :string(255)
#

class User < ActiveRecord::Base
  # Constants (should always be declared at the top)
  TYPES = {
    individual: 1,
    charity: 2,
    company: 3
  }

  # Devise modules. Others available are: :token_authenticatable, :lockable, :timeoutable
  devise :database_authenticatable, :registerable, :omniauthable, :confirmable, :recoverable, :rememberable, :trackable, :validatable

  attr_accessible :name, :email, :password, :password_confirmation, :remember_me , :website, :bio, :user_type,
    # singular
    :avatar_attributes, :location_attributes,
    # plural
    :preferences_attributes

  # Relations
  has_many :authentications, dependent: :destroy
  has_many :user_permissions, dependent: :destroy
  has_one :location, :as => :locatable, dependent: :destroy
  has_one :avatar, :as => :avatarable, dependent: :destroy
  has_many :preferences, dependent: :destroy
  has_many :evaluations, class_name: "RSEvaluation", as: :source
  has_many :projects, through: :user_permissions, source: :entity, source_type: 'Project'

  has_many :admin_projects,
    through: :user_permissions,
    source: :entity,
    source_type: 'Project',
    conditions: "user_permissions.role_id=#{Role::TYPES[:project_admin]}"

  has_many :collaborator_projects,
    through: :user_permissions,
    source: :entity,
    source_type: 'Project',
    conditions: "user_permissions.role_id=#{Role::TYPES[:project_collaborator]}"

  has_reputation :votes, source: {reputation: :votes, of: :projects}, aggregated_by: :sum

  accepts_nested_attributes_for :avatar, :location, :preferences

  # Friendly Id
  extend FriendlyId
  friendly_id :name, use: :slugged

  # Named Scopes
  scope :name_like, lambda { |n| where("name ilike ?", "%#{n}%") } # WARN: Potential DB Change Problem
  scope :confirmed_users, where("confirmed_at is not null")

  # Devise
  def self.new_with_session(params, session)
    if session["devise.user_attributes"]
      new(session["devise.user_attributes"], without_protection: true) do |user|
        user.attributes = params
        user.valid?
      end
    else
      super
    end
  end

  def update_with_password(params, *options)
    if encrypted_password.blank?
      update_attributes(params, *options)
    else
      super
    end
  end

  def password_required?
    (authentications.empty? || !password.blank?) && super
  end

  def voted_for?(project)
    evaluations.where(target_type: project.class, target_id: project.id).present?
  end

  def karma_points
   reputation_value_for(:votes).to_i* 10
  end

  def is_collaborator?(project)
    collaborator_projects.include? project
  end
end
