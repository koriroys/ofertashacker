require 'spec_helper'

describe Company do
  let(:company) { FactoryGirl.create(:company) }

  context 'Validations' do
    context 'Company is valid' do
      it 'With all attributes' do
        company.should be_valid
      end

      context 'When there is a website' do
        it 'With a valid website format' do
          websites = ['www.website.com', 'http://www.website.com', 'website.com', 'http://website.com']
          check_contact_info(company, websites, 'website').should be_true
        end
      end

      context 'When there is a facebook page' do
        it 'With a valid facebook format' do
          facebooks = ['www.facebook.com/thepage', 'http://www.facebook.com/thepage',
                       '/thepage', 'thepage', 'facebook.com/thepage', 'http://facebook.com/thepage']
          check_contact_info(company, facebooks, 'facebook').should be_true
        end
      end

      context 'When there is a twitter page' do
        it 'With a valid twitter format' do
          twitters = ['www.twitter.com/thepage', 'http://www.twitter.com/thepage',
                      '/thepage','@thepage', 'thepage', 'twitter.com/thepage', 'http://twitter.com/thepage']
          check_contact_info(company, twitters, 'twitter').should be_true
        end
      end
    end

    context 'Company is not valid' do
      it "Without title" do
        company.title = nil
        company.should_not be_valid
      end

      it 'Without an email' do
        company.email = nil
        company.should_not be_valid
      end

      context 'When there is a website' do
        it 'With an invalid website format' do
          websites = ['ww.website.com', 'htp://www.website.com', 'websitecom', 'httpbsite.com']
          check_contact_info(company, websites, 'website').should be_false
        end
      end

      context 'When there is a facebook page' do
        it 'With an invalid facebook format' do
          facebooks = ['www.facebook.comthepage', 'httpfacebook.com/thepage',
                       'thepage', 'thepage', 'facebook.com/thepage', 'http://facebook.com/']
          check_contact_info(company, facebooks, 'facebook').should be_false
        end
      end

      context 'When there is a twitter page' do
        it 'With a an invalid twitter format' do
          twitters = ['www.twitter_thepage', 'http://www.thepage',
                      '/thepage', '@@thepage', 'twitter/thepage', 'http://twitter.com/@thepage']
          check_contact_info(company, twitters, 'twitter').should be_false
        end
      end

    end
  end

  context 'Instance methods' do
    describe '.has_logo' do
      context 'When company has logo uploaded' do
        it 'Returns true' do
          company.stub_chain(:logo, :file?).and_return(true)
          company.has_logo.should be_true
        end
      end

      context 'When company does not has logo uploaded'
        it 'Returns false' do
          company.stub_chain(:logo, :file?).and_return(false)
          company.has_logo.should be_false
        end
    end

    describe '.to_param' do
      it 'Returns the id and the title separated by dashes' do
        company.update_attributes(:title => "Sample Company Inc")
        company.to_param.should eql("#{company.id}-sample-company-inc")
      end
    end

    describe '.admin?' do
      context 'When comany role is admin' do
        it 'Returns true' do
          company.role = 'admin'
          company.save
          company.should be_admin
        end
      end

      context 'When company role is not admin' do
        it 'Returns false' do
          company.role = 'not-admin'
          company.save
          company.should_not be_admin
        end
      end
    end

    describe '.member?' do
      context 'When company role is member' do
        it 'Returns true' do
          company.role = 'member'
          company.save
          company.should be_member
        end
      end
      context 'When company role is not member' do
        it 'Returns false' do
          company.role = 'not-member'
          company.save
          company.should_not be_member
        end
      end
    end

    describe '.logo_url' do
        context 'When environment is production' do
          it 'Returns the logo url' do
            company.stub_chain(:logo, :url).and_return('www.a-website.com/image.jpg')
            Rails.stub(:env).and_return("production")
            company.logo_url.should eql('www.a-website.com/image.jpg')
          end
        end

        context 'When environment is not production' do
          context 'When there is no logo uploaded' do
            it 'Returns the default logo route' do
              company.logo_url.should eql(Company::DEFAULT_LOGO_ROUTE)
            end
          end

          context 'When there is a logo uploaded' do
            it 'Returns the logo path without the /public' do
              company.stub_chain(:logo, :path).and_return('public/the/path/image.jpg')
              company.logo_url.should eql('/the/path/image.jpg')
            end
          end
        end
    end

    describe '.has_facebook?' do
      context 'With facebook page' do
        it 'Returns true' do
          company.update_attribute('facebook', 'foobar')
          company.should have_facebook
        end
      end

      context 'Without facebook page' do
        it 'Returns false' do
          company.update_attribute('facebook', nil)
          company.should_not have_facebook
        end
      end
    end

    describe '.has_website?' do
      context 'With website page' do
        it 'Returns true' do
          company.update_attribute('website', 'foobar')
          company.should have_website
        end

      end

      context 'Without website page' do
        it 'Returns false' do
          company.update_attribute('website', nil)
          company.should_not have_website
        end
      end
    end

    describe '.has_twitter?' do
      context 'With twitter page' do
        it 'Returns true' do
          company.update_attribute('twitter', 'foobar')
          company.should have_twitter
        end
      end

      context 'Without twitter page' do
        it 'Returns false' do
          company.update_attribute('twitter', nil)
          company.should_not have_twitter
        end
      end
    end

    describe '.contact_email' do
      context 'With contact_email page' do
        it 'Returns true' do
          company.update_attribute('contact_email', 'foobar')
          company.should have_contact_email
        end
      end

      context 'Without contact_email page' do
        it 'Returns false' do
          company.update_attribute('contact_email', nil)
          company.should_not have_contact_email
        end
      end
    end

    describe '.phone1?' do
      context 'With phone1 page' do
        it 'Returns true' do
          company.update_attribute('phone1', 'foobar')
          company.should have_phone1
        end
      end

      context 'Without phone1 page' do
        it 'Returns false' do
          company.update_attribute('phone1', nil)
          company.should_not have_phone1
        end
      end
    end

    describe '.latests_jobs' do
      context 'When company has no jobs' do
        it 'Returns an empty array' do
          company.latests_jobs.should be_blank
        end
      end

      context 'When company has jobs' do
        before do
          5.times { FactoryGirl.create(:job, :company => company) }
          @jobs = Job.ordered[0..3]
          @job = Job.first
        end

        it 'Returns the four latests jobs' do
          company.latests_jobs.should eql(@jobs)
        end

        it 'Does not return older jobs' do
          company.latests_jobs.should_not include(@job)
        end
      end
    end

    describe '.formatted_facebook' do
      context 'With a full facebook url' do
        it 'Returns the correct full url' do
          company.facebook = "http://www.facebook.com/the_page"
          company.formatted_facebook.should eql("http://www.facebook.com/the_page")
        end
      end

      context 'With a facebook url without http://' do
        it 'returns the correct full url' do
          company.facebook = "www.facebook.com/the_page"
          company.formatted_facebook.should eql("http://www.facebook.com/the_page")
        end
      end

      context 'With a facebook url without http://www.' do
        it 'returns the correct full url' do
          company.facebook = "facebook.com/the_page"
          company.formatted_facebook.should eql("http://www.facebook.com/the_page")
        end
      end

      context 'With a facebook url with only the relative path ' do
        it 'returns the correct full url' do
          company.facebook = "the_page"
          company.formatted_facebook.should eql("http://www.facebook.com/the_page")
        end
      end
      context 'With a facebook url with a relative path with slash' do
        it 'returns the correct full url' do
          company.facebook = "/the_page"
          company.formatted_facebook.should eql("http://www.facebook.com/the_page")
        end
      end
    end

    describe '.facebook_text' do
      context 'With a full facebook url' do
        it 'Returns the correct url' do
          company.facebook = "http://www.facebook.com/the_page"
          company.facebook_text.should eql("facebook.com/the_page")
        end
      end

      context 'With a facebook url without http://' do
        it 'Returns the correct url' do
          company.facebook = "www.facebook.com/the_page"
          company.facebook_text.should eql("facebook.com/the_page")
        end
      end

      context 'With a facebook url without http://www.' do
        it 'Returns the correct url' do
          company.facebook = "facebook.com/the_page"
          company.facebook_text.should eql("facebook.com/the_page")
        end
      end

      context 'With a facebook url with only the relative path ' do
        it 'Returns the correct url' do
          company.facebook = "the_page"
          company.facebook_text.should eql("facebook.com/the_page")
        end
      end

      context 'With a facebook url with a relative path with slash' do
        it 'Returns the correct url' do
          company.facebook = "/the_page"
          company.facebook_text.should eql("facebook.com/the_page")
        end
      end
    end

    describe '.formatted_twitter' do
      context 'With a full twitter url' do
        it 'Returns the correct full url' do
          company.twitter = "http://www.twitter.com/the_page"
          company.formatted_twitter.should eql("http://www.twitter.com/the_page")
        end
      end

      context 'With a twitter url without http://' do
        it 'Returns the correct full url' do
          company.twitter = "www.twitter.com/the_page"
          company.formatted_twitter.should eql("http://www.twitter.com/the_page")
        end
      end

      context 'With a twitter url without http://www.' do
        it 'Returns the correct full url' do
          company.twitter = "twitter.com/the_page"
          company.formatted_twitter.should eql("http://www.twitter.com/the_page")
        end
      end

      context 'With a twitter url with only the relative path ' do
        it 'Returns the correct full url' do
          company.twitter = "the_page"
          company.formatted_twitter.should eql("http://www.twitter.com/the_page")
        end
      end

      context 'With a twitter url with a relative path with slash' do
        it 'Returns the correct full url' do
          company.twitter = "/the_page"
          company.formatted_twitter.should eql("http://www.twitter.com/the_page")
        end
      end

      context 'With a twitter url with a relative path with @' do
        it 'Returns the correct full url' do
          company.twitter = "@the_page"
          company.formatted_twitter.should eql("http://www.twitter.com/the_page")
        end
      end
    end

    describe '.twitter_text' do
      context 'With a full twitter url' do
        it 'Returns the correct url' do
          company.twitter = "http://www.twitter.com/the_page"
          company.twitter_text.should eql("@the_page")
        end
      end

      context 'With a twitter url without http://' do
        it 'Returns the correct url' do
          company.twitter = "www.twitter.com/the_page"
          company.twitter_text.should eql("@the_page")
        end
      end

      context 'With a twitter url without http://www.' do
        it 'Returns the correct url' do
          company.twitter = "twitter.com/the_page"
          company.twitter_text.should eql("@the_page")
        end
      end

      context 'With a twitter url with only the relative path ' do
        it 'Returns the correct url' do
          company.twitter = "the_page"
          company.twitter_text.should eql("@the_page")
        end
      end

      context 'With a twitter url with a relative path with slash' do
        it 'Returns the correct url' do
          company.twitter = "/the_page"
          company.twitter_text.should eql("@the_page")
        end
      end

      context 'With a twitter url with a relative path with slash' do
        it 'Returns the correct url' do
          company.twitter = "@the_page"
          company.twitter_text.should eql("@the_page")
        end
      end
    end

    describe '.formatted_website' do
      context 'With a full website url' do
        it 'Returns the correct full url' do
          company.website = "http://www.company.com"
          company.formatted_website.should eql("http://www.company.com")
        end
      end

      context 'With a website url without http://' do
        it 'Returns the correct full url' do
          company.website = "www.company.com"
          company.formatted_website.should eql("http://www.company.com")
        end
      end

      context 'With a website url without http://www.' do
        it 'Returns the correct full url' do
          company.website = "company.com"
          company.formatted_website.should eql("http://company.com")
        end
      end
    end
  end
end
