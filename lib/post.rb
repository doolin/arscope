class Post < ActiveRecord::Base
  scope :published, (-> { where(status: 'published') })
  scope :by_status, (->(status) { where(status: status) if status.present? })

  def self.by_author(author)
    where(author: author) if author.present? || all
  end

  def self.by_title(title)
    where(title: title) if title.present? || all
  end
end
