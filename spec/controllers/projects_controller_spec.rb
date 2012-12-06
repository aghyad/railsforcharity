require 'spec_helper'

# This spec was generated by rspec-rails when you ran the scaffold generator.
# It demonstrates how one might use RSpec to specify the controller code that
# was generated by Rails when you ran the scaffold generator.
#
# It assumes that the implementation code is generated by the rails scaffold
# generator.  If you are using any extension libraries to generate different
# controller code, this generated spec may or may not pass.
#
# It only uses APIs available in rails and/or rspec-rails.  There are a number
# of tools you can use to make these specs even more expressive, but we're
# sticking to rails and rspec-rails APIs to keep things simple and stable.
#
# Compared to earlier versions of this generator, there is very limited use of
# stub and message expectations in this spec.  Stubs are only used when there
# is no simpler way to get a handle on the object needed for the example.
# Message expectations are only used when there is no simpler way to specify
# that an instance is receiving a specific message.

describe ProjectsController do
  describe "GET index" do
    it "assigns all projects as @projects" do
      project = Project.create! attributes_for(:project)
      get :index, {}
      assigns(:projects).should eq([project])
    end
  end

  describe "GET show" do
    it "assigns the requested project as @project" do
      project = Project.create! attributes_for(:project)
      get :show, {:id => project.to_param}
      assigns(:project).should eq(project)
    end
  end

  describe "GET new" do
    login_user

    it "assigns a new project as @project" do
      get :new, {}
      assigns(:project).should be_a_new(Project)
    end
  end

  describe "GET edit" do
    it "assigns the requested project as @project" do
      project = Project.create! attributes_for(:project)
      get :edit, {:id => project.to_param}
      assigns(:project).should eq(project)
    end
  end

  describe "POST create" do
    login_user

    describe "with valid params" do
      it "creates a new Project" do
        expect {
          post :create, {:project => attributes_for(:project)}
        }.to change(Project, :count).by(1)
      end

      it "assigns a newly created project as @project" do
        post :create, {:project => attributes_for(:project)}
        assigns(:project).should be_a(Project)
        assigns(:project).should be_persisted
      end

      it "assigns collaborators" do
        users_csv = [create(:user).id, create(:user).id].join(",")
        project = Project.create!(attributes_for(:project).merge({:collaborator_tokens => users_csv}))
        post :create, {:project => attributes_for(:project)}
        project.users.size.should == 2
      end

      it "redirects to the created project" do
        post :create, {:project => attributes_for(:project)}
        response.should redirect_to(project_path(assigns(:project)))
      end

      context 'with tags' do
        it "creates the requisite tags for categories" do
          post :create, {:project => attributes_for(:project_with_tags)}
          Tag.find_all_by_tag_type('project').size.should == 2
          Tagging.find_all_by_taggable_type_and_taggable_id('Project', assigns(:project).id).size.should == 4
        end

        #it "creates the requisite tags for categories and technologies correctly even when they are same" do
        #  post :create, {:project => attributes_for(:project_same_category_and_technology)}
        #  puts Tagging.all.inspect
        #  Tag.find_all_by_tag_type('project').size.should == 1
        #  Tagging.find_all_by_taggable_type_and_taggable_id('Project', assigns(:project).id).size.should == 1
        #end
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved project as @project" do
        # Trigger the behavior that occurs when invalid params are submitted
        Project.any_instance.stub(:save).and_return(false)
        post :create, {:project => {}}
        assigns(:project).should be_a_new(Project)
      end

      it "re-renders the 'new' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        Project.any_instance.stub(:save).and_return(false)
        post :create, {:project => {}}
        response.should render_template("new")
      end
    end
  end

  describe "PUT update" do

    login_user

    describe "with valid params" do
      it "updates the requested project" do
        project = Project.create! attributes_for(:project)
        # Assuming there are no other projects in the database, this
        # specifies that the Project created on the previous line
        # receives the :update_attributes message with whatever params are
        # submitted in the request.
        Project.any_instance.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, {:id => project.to_param, :project => {'these' => 'params'}}
      end

      it "assigns the requested project as @project" do
        project = Project.create! attributes_for(:project)
        put :update, {:id => project.to_param, :project => attributes_for(:project)}
        assigns(:project).should eq(project)
      end

      it "assigns collaborators" do
        users_csv = [create(:user).id, create(:user).id].join(",")
        project = Project.create! attributes_for(:project).merge({:collaborator_tokens => users_csv})
        put :update, {:id => project.to_param, :project => attributes_for(:project)}
        assigns(:project).should eq(project)
        assigns(:project).users.size.should == 2
      end

      it "redirects to the project" do
        project = Project.create! attributes_for(:project)
        put :update, {:id => project.to_param, :project => attributes_for(:project)}
        response.should redirect_to(project)
      end
    end

    describe "with invalid params" do
      it "assigns the project as @project" do
        project = Project.create! attributes_for(:project)
        # Trigger the behavior that occurs when invalid params are submitted
        Project.any_instance.stub(:save).and_return(false)
        put :update, {:id => project.to_param, :project => {}}
        assigns(:project).should eq(project)
      end

      it "re-renders the 'edit' template" do
        project = Project.create! attributes_for(:project)
        # Trigger the behavior that occurs when invalid params are submitted
        Project.any_instance.stub(:save).and_return(false)
        put :update, {:id => project.to_param, :project => {}}
        response.should render_template("edit")
      end
    end
  end

  describe "DELETE destroy" do
    login_user

    it "destroys the requested project" do
      project = Project.create! attributes_for(:project)
      expect {
        delete :destroy, {:id => project.to_param}
      }.to change(Project, :count).by(-1)
    end

    it "redirects to the projects list" do
      project = Project.create! attributes_for(:project)
      delete :destroy, {:id => project.to_param}
      response.should redirect_to(projects_url)
    end
  end

  describe 'existing project' do
    let!(:project) { create(:project) }
    login_user

    before :each do
      request.env["HTTP_REFERER"] = projects_url
    end

    describe "join" do
      context 'success' do
        it "makes the current user a collaborator" do
          expect do
            post :join, { :id => project }
          end.to change(project.users, :count).by(1)
        end

        it "sets email preferences for user with respect to the project" do
          post :join, { :id => project }

          preference = Preference.find_by_user_id_and_entity_type_and_entity_id(user.id, 'Project', assigns(:project).id)
          expected_properties = EmailTemplate::TYPES.reduce({}) { |accumulator, property| accumulator.merge(property.first.to_s => "1") }
          preference.should_not be_nil
          preference.properties.should == expected_properties
        end

        it 'sets the flash message' do
          post :join, { :id => project }
          should set_the_flash.to("Thank you for joining #{project.name}!, Happy collaborating !!!")
        end
      end

      context 'failure' do
        it 'sets the flash message' do
          Project.any_instance.stub(:join).and_return(false)
          post :join, { :id => project }
          should set_the_flash.to("Failed to join the project #{project.name}, please try again later!")
        end
      end
    end

    describe 'unjoin' do
      it 'remove the current user from project collaborators list' do
        expect do
          post :unjoin, { :id => project }
        end.to change(project.users, :count).by(-1)
      end

      it 'sets the flash message' do
        post :unjoin, { :id => project }
        should set_the_flash.to("Sorry to see you leave #{project.name}!, Hope you come back again !!!")
      end

      it 'deletes the project preference for that user' do
        post :unjoin, { :id => project }
        preference = Preference.find_by_user_id_and_entity_type_and_entity_id(user.id, 'Project', project.id)
        preference.should be_nil
      end
    end
  end
end
