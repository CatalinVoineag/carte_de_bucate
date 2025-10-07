# frozen_string_literal: true

class SaveReceipeComponent < ViewComponent::Base
  attr_reader :receipe, :user

  def initialize(receipe:, user:)
    @receipe = receipe
    @user = user
  end
end
