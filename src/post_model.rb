class Post < ActiveRecord::Base

  attr_accessible :author, :status, :category, :title

  scope :published, -> { where(status: 'published') }
  scope :by_status, -> status { where(status: status) if status.present? }

  def self.by_author(author)
    where(author: author) if author.present? or all
  end

  def self.by_title(title)
    where(title: title) if title.present? or all
  end
end


