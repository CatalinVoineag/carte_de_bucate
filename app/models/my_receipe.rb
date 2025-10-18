class MyReceipe < Receipe
  belongs_to :user
  belongs_to :global_receipe, optional: true
end
