# A copy of a published receipe in someone's My receipes list. Copies mirror the receipe in the Receipes tab
# and can only be removed from the list, never edited there.
class MyReceipe < Receipe
  belongs_to :user
  belongs_to :global_receipe, optional: true, inverse_of: :saved_copies
end
