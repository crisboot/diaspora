#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe Profile do
  describe 'validation' do
    describe "of first_name" do
      it "strips leading and trailing whitespace" do
        profile = Factory.build(:profile, :first_name => "     Shelly    ")
        profile.should be_valid
        pp profile
        profile.first_name.should == "Shelly"
      end
      
      it "can be 32 characters long" do
        profile = Factory.build(:profile, :first_name => "Hexagoooooooooooooooooooooooooon")
        profile.should be_valid
      end
      
      it "cannot be 33 characters" do
        profile = Factory.build(:profile, :first_name => "Hexagooooooooooooooooooooooooooon")
        profile.should_not be_valid
      end
    end
    describe "of last_name" do
      it "strips leading and trailing whitespace" do
        profile = Factory.build(:profile, :last_name => "     Ohba    ")
        profile.should be_valid
        profile.last_name.should == "Ohba"
      end
      
      it "can be 32 characters long" do
        profile = Factory.build(:profile, :last_name => "Hexagoooooooooooooooooooooooooon")
        profile.should be_valid
      end
      
      it "cannot be 33 characters" do
        profile = Factory.build(:profile, :last_name => "Hexagooooooooooooooooooooooooooon")
        profile.should_not be_valid
      end
    end
  end

  describe '#image_url=' do
    before do
      @profile = Factory.build(:profile)
      @profile.image_url = "http://tom.joindiaspora.com/images/user/tom.jpg"
      @pod_url = (APP_CONFIG[:pod_url][-1,1] == '/' ? APP_CONFIG[:pod_url].chop : APP_CONFIG[:pod_url])
    end
    it 'ignores an empty string' do
      lambda {@profile.image_url = ""}.should_not change(@profile, :image_url)
    end
    it 'makes relative urls absolute' do
      @profile.image_url = "/relative/url"
      @profile.image_url.should == "#{@pod_url}/relative/url"
    end
    it "doesn't change absolute urls" do
      @profile.image_url = "http://not/a/relative/url"
      @profile.image_url.should == "http://not/a/relative/url"
    end
  end

  describe 'serialization' do
    it "includes the person's diaspora handle if it doesn't have one" do
      person = Factory(:person, :diaspora_handle => "foobar")
      xml = person.profile.to_diaspora_xml
      xml.should include "foobar"
    end
  end

  describe 'date=' do
    let(:profile) { Factory(:profile) }

    it 'accepts form data' do
      profile.birthday.should == nil
      profile.date = { 'year' => '2000', 'month' => '01', 'day' => '01' }
      profile.birthday.year.should == 2000
      profile.birthday.month.should == 1
      profile.birthday.day.should == 1
    end

    it 'unsets the birthday' do
      profile.birthday = Date.new(2000, 1, 1)
      profile.date = { 'year' => '', 'month' => '', 'day' => ''}
      profile.birthday.should == nil
    end

    it 'does not change with blank  month and day values' do
      profile.birthday = Date.new(2000, 1, 1)
      profile.date = { 'year' => '2001', 'month' => '', 'day' => ''}
      profile.birthday.year.should == 2000
      profile.birthday.month.should == 1
      profile.birthday.day.should == 1
    end

    it 'accepts blank initial vallues' do
      profile.birthday.should == nil
      profile.date = { 'year' => '2001', 'month' => '', 'day' => ''}
      profile.birthday.should == nil
    end
  end

end
