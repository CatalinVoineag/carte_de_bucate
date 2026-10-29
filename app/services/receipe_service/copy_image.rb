module ReceipeService
  # Gives `to` its own copy of `from`'s image, so deleting one receipe never removes the other's picture.
  # If the file is missing from storage, it falls back to sharing the blob, which Active Storage
  # keeps for as long as any receipe still uses it.
  class CopyImage
    def self.call(from:, to:)
      return unless from.image.attached?

      blob = from.image.blob
      to.image.attach(
        io: StringIO.new(blob.download),
        filename: blob.filename.to_s,
        content_type: blob.content_type
      )
    rescue ActiveStorage::FileNotFoundError, Errno::ENOENT
      to.image.attach(blob)
    end
  end
end
