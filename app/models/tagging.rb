class Tagging < ActiveRecord::Base
  
  belongs_to :tag
  belongs_to :taggable, :polymorphic => true
  belongs_to :tagger, :polymorphic => true
  
  validates_presence_of :context
  
  belongs_to :priority, :class_name => "Priority", :foreign_key => "taggable_id"
      
  after_create :increment_tag
  before_destroy :decrement_tag
  
  def increment_tag
    return unless tag
    if taggable.class == Priority
      tag.increment!(:priorities_count)
      tag.update_counts # recalculate the discussions/questions/documents
      tag.save_with_validation(false)
    end
  end
  
  def decrement_tag
    return unless tag
    if taggable.class == Priority
      tag.decrement!(:priorities_count)
      tag.update_counts # recalculate the discussions/questions/documents
      tag.save_with_validation(false)
    end    
  end
  
end