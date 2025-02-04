require 'fix_top_endorsements'
require 'priority_ranker'
require 'user_ranker'

namespace :schedule do
  desc "Fix top endorsements"
  task :fix_top_endorsements => :environment do
    o = FixTopEndorsements.new
    o.perform
  end

  desc "Priority Ranker"
  task :priority_ranker => :environment do
    o = PriorityRanker.new
    o.perform
  end

  desc "User Ranker"
  task :user_ranker => :environment do
    o = UserRanker.new
    o.perform
  end
  
  desc "Fix counts"
  task :fix_counts => :environment do
    Government.current = Government.all.last
    puts "Fixing priorities endorsements count"    
    for p in Priority.find(:all)
      p.endorsements_count = p.endorsements.active_and_inactive.size
      p.up_endorsements_count = p.endorsements.endorsing.active_and_inactive.size
      p.down_endorsements_count = p.endorsements.opposing.active_and_inactive.size
      p.save(:validate => false)      
    end

    puts "Fixing user endorsements positions"    
    for u in User.active.at_least_one_endorsement.all(:order => "users.id asc")
      row = 0
      for e in u.endorsements.active.by_position
        row += 1
        e.update_attribute(:position,row) unless e.position == row
        u.update_attribute(:top_endorsement_id,e.id) if u.top_endorsement_id != e.id and row == 1
      end
    end

#    puts "Fixing priorities endorsements count"    
#    Endorsement.active.find_in_batches(:include => :user) do |endorsement_group|
#      for e in endorsement_group
#        current_score = e.score
#        new_score = e.calculate_score
#        e.update_attribute(:score, new_score) if new_score != current_score
#      end
#    end      

    puts "Fixing endorsements dups"    
    endorsements = Endorsement.find_by_sql("
        select user_id, priority_id, count(*) as num_times
        from endorsements
        group by user_id,priority_id
        having count(*) > 1
    ")
    for e in endorsements
      user = e.user
      priority = e.priority
      multiple_endorsements = user.endorsements.active.find(:all, :conditions => ["priority_id = ?",priority.id], :order => "endorsements.position")
      if multiple_endorsements.length > 1
        for c in 1..multiple_endorsements.length-1
          puts "Destroying endorsement #{multiple_endorsements[c]}"
          multiple_endorsements[c].destroy
        end
      end
    end

    puts "Fixing discussions count"
    priorities = Priority.find(:all)
    for p in priorities
      p.update_attribute(:discussions_count,p.activities.discussions.for_all_users.active.size) if p.activities.discussions.for_all_users.active.size != p.discussions_count
    end
    points = Point.find(:all)
    for p in points
      p.update_attribute(:discussions_count,p.activities.discussions.for_all_users.active.size) if p.activities.discussions.for_all_users.active.size != p.discussions_count
    end
    docs = Document.find(:all)
    for d in docs
      d.update_attribute(:discussions_count, d.activities.discussions.for_all_users.active.size) if d.activities.discussions.for_all_users.active.size != d.discussions_count
    end

    puts "Fixing tags count"
    for t in Tag.all
      t.update_counts
      t.save(:validate => false)
    end

    puts "Fixing users counts"
    users = User.find(:all)
    for u in users
      u.update_counts
      u.save(:validate => false)
    end

  end  
end