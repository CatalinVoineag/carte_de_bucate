# frozen_string_literal: true

class SaveReceipeComponent < ViewComponent::Base
  attr_reader :receipe, :user

  def initialize(receipe:, user:)
    @receipe = receipe
    @user = user
  end

  def render?
    receipe.present? && user.present?
  end

  def button_name
    if user.receipes.find_by(id: receipe.id).present?
      "Remove from my receipes"
    else
      "Save to my receipes"
    end
  end

  def path_of_button
    if user.receipes.find_by(id: receipe.id).present?
      save_receipe_path(receipe.id)
    else
      save_receipes_path(receipe_id: receipe.id)
    end
  end

  def method
    if user.receipes.find_by(id: receipe.id).present?
      :delete
    else
      :post
    end
  end
end
