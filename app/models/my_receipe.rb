class MyReceipe < Receipe
  belongs_to :user, optional: true
  belongs_to :global_receipe
end
