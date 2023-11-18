# frozen_string_literal: true

class Post < ActiveRecord::Base
  scope :published, (-> { where(status: 'published') })
  scope :by_status, (->(status) { where(status:) if status.present? })

  def self.by_author(author)
    where(author:) if author.present? || all
  end

  def self.by_title(title)
    where(title:) if title.present? || all
  end
end
