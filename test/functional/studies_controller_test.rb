require 'test_helper'

class StudiesControllerTest < ActionController::TestCase

  should_eventually 'test the other actions: map, index_third_party, claim, users, etc.'

  context "without a logged in user" do

    context "on GET to new" do
      setup do
        get :new
      end

      should 'redirect appropriately' do
        assert_redirected_to login_path
      end
    end

    context "on POST to create" do
      setup do
        @count = Study.count
        post :create
      end

      should_not set_the_flash.to /successfully created/i

      should 'redirect appropriately' do
        assert_redirected_to login_path
      end

      should 'not increase the study count' do
        assert_equal @count, Study.count
      end
    end

    context "on GET to show" do
      setup do
        study = Factory :study
        get :show, :id => study.to_param
      end

      should 'redirect appropriately' do
        assert_redirected_to login_path
      end
    end

    context "on PUT to update" do
      setup do
        @study = Factory :study
        put :update, :id => @study.to_param, :study => { :participant_description => 'Crazy new participant_description' }
      end

      should_not set_the_flash.to /successfully updated/i

      should 'redirect appropriately' do
        assert_redirected_to login_path
      end

      should 'not have updated the participant_description' do
        assert_not_equal Study.find(@study.to_param)[:participant_description], 'Crazy new participant_description'
      end
    end

    context "on DELETE to destroy" do
      setup do
        @study = Factory :study
        @count = Study.count
        delete :destroy, :id => @study.to_param
      end

      should 'still be able to find the study' do
        assert Study.find(@study)
      end

      should 'leave the study count as is' do
        assert_equal @count, Study.count
      end

      should 'redirect appropriately' do
        assert_redirected_to login_path
      end
    end

    should "route verify_participant_id url" do
      assert_routing("/third_party/study/12345/verify_participant_id/abcdef0123456789",
                     :controller => "studies",
                     :action => "verify_participant_id",
                     :id => "12345",
                     :app_token => "abcdef0123456789")
    end

    context "with an active third party study" do
      setup do
        @user_interested = Factory(:enrolled_user)
        @user_uninterested = Factory(:enrolled_user)
        @study = Factory(:active_third_party_study)
        @goodtoken_interested = @user_interested.app_token("Study##{@study.id}")
        @goodtoken_uninterested = @user_uninterested.app_token("Study##{@study.id}")
        StudyParticipant.create!(:study => @study,
                                 :user => @user_interested,
                                 :status => StudyParticipant::STATUSES['interested'])
      end

      [["00000000000000000000000000000000", true],
       ["eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee", false]].each do |token, valid|
        should "verify token #{token} => #{valid}" do
          get :verify_participant_id, {
            :id => @study.id,
            :app_token => token,
          }
          assert_response (valid ? :success : 404)
          assert_equal valid, JSON.parse(response.body)["valid"]
        end
      end

      should "reject token for uninterested participant" do
        get :verify_participant_id, {
          :id => @study.id,
          :app_token => @goodtoken_uninterested,
        }
        assert_response 404
        assert_equal false, JSON.parse(response.body)["valid"]
      end

      should "accept token for interested participant" do
        get :verify_participant_id, {
          :id => @study.id,
          :app_token => @goodtoken_interested,
        }
        assert_response :success
        assert_equal true, JSON.parse(response.body)["valid"]
      end

      context "adding new dataset" do

        should "have routing" do
          assert_routing({ :path => "/third_party/add_dataset",
                           :method => "post" },
                         { :controller => "studies",
                           :action => "add_dataset" })
        end

        setup do
          @goodparams = {
            :api_key => @study.api_key,
            :participant_code => @goodtoken_interested,
            :data_sources_tsv => "d41d8cd98f00b204e9800998ecf8427e\t0\thttp://example./empty.txt\r\n",
          }
        end

        context "with valid params" do
          should "accept valid req and queue download" do
            ArvadosJob.expects(:run_pipeline).once
            post :add_dataset, @goodparams
            assert_response :success
          end

          should "return error if arv-run-pipeline-instance fails" do
            @controller.stubs(:dataset_download_tmpl).
              returns '/nonexistent/test/template.json'
            post :add_dataset, @goodparams
            assert_response 400
            assert_match /Process.*exited/, JSON.parse(response.body)["errors"][0]
          end
        end

        context "with invalid params" do
          setup do
            ArvadosJob.expects(:run_pipeline).never
          end

          [:participant_code, :api_key, :data_sources_tsv].each do |param|
            should "reject missing #{param}" do
              post :add_dataset, @goodparams.reject { |k,v| k == param }
              assert_response 400
            end

            should "reject invalid #{param}" do
              post :add_dataset, @goodparams.merge(param => '1/2345')
              assert_response 400
            end
          end

          should "reject api_key for non-approved study" do
            @study.update_attributes(:approved => false)
            post :add_dataset, @goodparams
            assert_response 400
          end
        end
      end
    end

  end

  logged_in_researcher_context do

    context "on GET to new" do
      setup do
        get :new
      end

      should respond_with :success
      should render_template :new
    end

    context "on POST to create" do
      setup do
        @count = Study.count
        post :create, :study => Factory.attributes_for(:study)
      end

      should set_the_flash.to /successfully created/i

      should 'redirect appropriately' do
        assert_redirected_to page_path(:researcher_tools)
      end

      should 'increase the study count' do
        assert_equal @count+1, Study.count
      end
    end

    context "on GET to show" do
      setup do
        study = Factory :study, :creator => @user
        get :edit, :id => study.to_param
      end

      should respond_with :success
      should render_template :edit
    end

    context "on PUT to update" do
      setup do
        @study = Factory :study, :creator => @user
        put :update, :id => @study.to_param, :study => { :participant_description => 'Crazy new participant_description' }
      end

      should set_the_flash.to /successfully updated/i

      should 'redirect appropriately' do
        assert_redirected_to page_path(:researcher_tools)
      end

      should 'have updated the participant_description' do
        assert_equal assigns[:study][:participant_description], 'Crazy new participant_description'
        assert_equal Study.find(@study)[:participant_description], 'Crazy new participant_description'
      end
    end


    context "on DELETE to destroy" do
      setup do
        @study = Factory :study, :creator => @user
        @count = Study.count
        delete :destroy, :id => @study.to_param
      end

      should 'not be able to find the study' do
        assert_raise ActiveRecord::RecordNotFound do
          Study.find(@study)
        end
      end

      should 'reduce the study count' do
        assert_equal @count-1, Study.count
      end

      should 'redirect appropriately' do
        assert_redirected_to collection_events_path
      end
    end

  end

  logged_in_enrolled_user_context do


  end

end
