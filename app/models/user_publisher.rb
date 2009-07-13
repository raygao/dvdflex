class UserPublisher < Facebooker::Rails::Publisher

  ###################################################
  ### profile section                             ###
  ### see utils/_profile.erb                      ###
  ### u= User.find(:first)                        ###
  ### UserPublisher.create_profile_update(u)      ###
  ### UserPublisher.deliver_profile_update(u)     ###
  ###################################################
  def profile_update(user)
    case DVDFLEX_ENV
    when 'dev'
      begin
        send_as :profile
        recipients user
        #this goes to the boxes
        profile render(:partial => "utils/profile_boxes_dev",
          :assigns => {:user => user})
        #this goes to the wall on front page
        profile_main render(:partial => "utils/profile_boxes_dev",
          :assigns => {:user => user})
      end
    when 'test'
      begin
        send_as :profile
        recipients user
        #this goes to the boxes
        profile render(:partial => "utils/profile_boxes_test",
          :assigns => {:user => user})
        #this goes to the wall on front page
        profile_main render(:partial => "utils/profile_boxes_test",
          :assigns => {:user => user})
      end
    when 'prod'
      begin
        send_as :profile
        recipients user
        #this goes to the boxes
        profile render(:partial => "utils/profile_boxes",
          :assigns => {:user => user})
        #this goes to the wall on front page
        profile_main render(:partial => "utils/profile_boxes",
          :assigns => {:user => user})
      end
    end


  end


  ###################################################
  ### News feed section                           ###
  ### see utils/_profile.erb                      ###
  ### listing=Listing.find(:last)                 ###
  ### UserPublisher.register_addlisting           ###
  ### UserPublisher.deliver_addlisting(listing)   ###
  ###################################################
  def addlisting_template
    one_line_story_template "{*actor*} added DVD: {*show_dvd_link*} to his/her library."
    short_story_template "{*actor*} added a DVD", "It is {*show_dvd_link*}."
  end

  def addlisting (listing)
    send_as :user_action
    from listing.user.facebook_session.user
    data :show_dvd_link => link_to(listing.dvd.title, listing_url(listing.id))
  end

end