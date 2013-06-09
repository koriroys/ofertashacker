class Company < ActiveRecord::Base

  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable, :lockable and :timeoutable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :jobs, :dependent => :destroy

  validates :title, :presence => true, :uniqueness => true
  validates_format_of :website, :with => /^(http:\/\/(www\.)?|(www\.)?)\w+\.\D{2,}.*$/i, :on => :update, :if => :has_website?
  validates_format_of :contact_email, :with => /^\w(\w|[.-])+@\w+\.\w{2,}$/i, :on => :update, :if => :has_contact_email?
  validates_format_of :facebook, :with => /^(\/?\w+|((http:\/\/(www\.)?|(www\.)?)facebook.com\/\w+))$/i, :on => :update, :if => :has_facebook?
  validates_format_of :twitter, :with => /^((\/|@)?\w+|((http:\/\/(www\.)?|(www\.)?)twitter.com\/\w+))$/i, :on => :update, :if => :has_twitter?

  validates_attachment_content_type :logo,
                                    :content_type => ['image/jpg', 'image/jpeg',
                                                      'image/png', 'image/gif']

  attr_accessible :email, :password, :password_confirmation,
                  :remember_me, :title, :city_name, :logo, :description,
                  :phone1, :phone2, :contact_email, :linkedin, :facebook, :twitter, :website, :role, :terms_of_service

  validates_acceptance_of :terms_of_service

	metropoli_for :city
  scope :members, where(:role => "member")

  DEFAULT_LOGO_ROUTE = "/images/shareIcon.png"

  has_attached_file :logo, :styles => {:list => "150x100", :medium => "200x100>", :thumb => "130x35>"},
                            :default_style => :thumb,
                            :storage => {
                              'development' => :filesystem,
                              'test' => :filesystem,
                              'staging' => :s3,
                              'production' => :s3
                            }[Rails.env],
                            :s3_credentials => "#{Rails.root}/config/s3.yml",
                            :url => "../files/#{ENV['RAILS_ENV']}/:attachment/:id/:style/:basename.:extension",
                            :path => "public/files/#{Rails.env}/:attachment/:id/:style/:basename.:extension",
                            :bucket => 'rubypros',
                            :default_url => DEFAULT_LOGO_ROUTE

  def has_logo
    self.logo.file?
  end

  def to_s
    title
  end

  def to_param
    "#{self.id}-#{self.title.parameterize}"
  end

  def admin?
    self.role == "admin"
  end

  def member?
    self.role == "member"
  end

  def logo_url
    if Rails.env == 'production'
      self.logo.url
    else
     self.logo.path.nil? ?  DEFAULT_LOGO_ROUTE : self.logo.path[6..-1]
    end
  end

  def has_facebook?
    !self.facebook.blank?
  end

  def has_website?
    !self.website.blank?
  end

  def has_twitter?
    !self.twitter.blank?
  end

  def has_contact_email?
    !self.contact_email.blank?
  end

  def has_phone1?
    !self.phone1.blank?
  end

  def latest_jobs
    Job.latest(self).to_a
  end

  def formatted_facebook
    start = 0
    if (self.facebook.match(/(^http:\/\/(www\.)?)facebook.com/i))
      start = self.facebook[7..-1].index('/') + self.facebook.index('/') + 3
    elsif (self.facebook.match(/^(www\.)?facebook.com/i) )
      start = self.facebook.index('/') + 1
    elsif (self.facebook.index('/')==0)
      start = 1
    end
    return "http://www.facebook.com/#{self.facebook[start..-1]}"
  end

  def facebook_text
    start = 0
    if (self.facebook.match(/(^http:\/\/(www\.)?)facebook.com/i))
      start = self.facebook[7..-1].index('/') + self.facebook.index('/') + 3
    elsif (self.facebook.match(/^(www\.)?facebook.com/i) )
      start = self.facebook.index('/') + 1
    elsif (self.facebook.index('/')==0)
      start = 1
    end
    return "facebook.com/#{self.facebook[start..-1]}"
  end

  def formatted_twitter
    start = 0
    if (self.twitter.match(/(^http:\/\/(www\.)?)twitter.com/i))
      start = self.twitter[7..-1].index('/') + self.twitter.index('/') + 3
    elsif (self.twitter.match(/^(www\.)?twitter.com/i) )
      start = self.twitter.index('/') + 1
    elsif (self.twitter.index('/')==0)
      start = 1
    elsif (!self.twitter.index('@').nil?)
      start = 1
    end
    return "http://www.twitter.com/#{self.twitter[start..-1]}"
  end

  def twitter_text
    start = 0
    if (self.twitter.match(/(^http:\/\/(www\.)?)twitter.com/i))
      start = self.twitter[7..-1].index('/') + self.twitter.index('/') + 3
    elsif (self.twitter.match(/^(www\.)?twitter.com/i) )
      start = self.twitter.index('/') + 1
    elsif (self.twitter.index('/')==0)
      start = 1
    elsif (!self.twitter.index('@').nil?)
      start = 1
    end
    return "@#{self.twitter[start..-1]}"
  end

  def formatted_website
    if (self.website.match(/^http:\/\/(www\.)?\w+\.\w+.*/i))
      return self.website
    elsif (self.website.match(/^(www\.)?\w+\.\w+.*/i))
      return "http://#{self.website}"
    else
      return self.website
    end
  end

  def formatted_description
    self.description.gsub(/^h2./,'h3.').gsub(/^h1./,'h2.')
  end

  def blank_profile?
    #TODO Refactor this method
    self.city.blank? && !self.logo.file?  && self.twitter.blank? && self.facebook.blank? && self.contact_email.blank?  && self.website.blank? && self.description.blank?
  end

  def origin
    if city.present?
      city_name
    else
      city2
    end
  end

end

