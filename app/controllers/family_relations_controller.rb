class FamilyRelationsController < ApplicationController
  def index
    @family_members = current_user.family_relations
  end

  def new
    @family_relation = FamilyRelation.new()
  end

  def create
    @family_relation = FamilyRelation.new()
    @family_relation.user_id = current_user.id

    relative = User.find_by_email(params[:email])

    if relative.blank?
      flash[:error] = 'No user found with that email.'
      render :action => 'new'
      return
    end

    if (!['parent', 'child', 'sibling', 'grandparent', 'grandchild'].include?(params['relation']))
      flash[:error] = 'Please specify the type of relationship'
      render :action => 'new'
      return
    end

    existing_relation = FamilyRelation.find :all, :conditions => ['relative_id = ? AND user_id = ?', relative.id, current_user.id]
    if !existing_relation.blank?
      flash[:error] = 'You already have a relationship with that person'
      render :action => 'new'
      return
    end

    confirmed_relation = FamilyRelation.find :all, :conditions => ['relative_id = ? AND user_id = ?', current_user.id, relative.id]
    if confirmed_relation.blank?
      @family_relation.is_confirmed = false
    else
      @family_relation.is_confirmed = true
      confirmed_relation[0].is_confirmed = true
      confirmed_relation[0].save
    end

    if relative.id == current_user.id
      flash[:error] = 'Cannot add yourself as a relative.'
      render :action => 'new'
      return
    end

    @family_relation.relative_id = relative.id
    @family_relation.relation = params['relation']

    if @family_relation.save
      flash[:notice] = 'Family member successfully added'
      redirect_to family_relations_path
    else
      flash[:error] = 'Error adding this family member'
      render :action => 'new'
    end
  end


  def destroy
    @family_relation = FamilyRelation.find(params[:id])
    @family_relation.destroy

    redirect_to(family_relations_url)
  end
end
