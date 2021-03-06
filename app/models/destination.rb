class Destination < ApplicationRecord
  has_many :parking_events
  has_many :users, through: :parking_events
  has_many :parking_locations, through: :parking_events

  def query_limitation(attribute, symbol, criteria)
    Limitation.all.where("#{attribute} #{symbol} ?", criteria)
  end

  def get_parking_locations(matches)
    all_locations = matches.map(&:parking_locations).flatten
    all_events = all_locations.map{|loc| loc.parking_events}.flatten
    all_destinations = all_events.select do |event|
      event.destination == self
    end
    all_destinations.map(&:parking_location).uniq
  end

  def filter_handicap(boolean)
    matches = query_limitation("handicap_accessible", "=", boolean)
    get_parking_locations(matches)
  end

  def filter_sweep_day(day)
    matches = query_limitation("sweep_day", "!=", day)
    get_parking_locations(matches)
  end

  def filter_cost(price)
    matches = query_limitation("cost", "<", price)
    get_parking_locations(matches)
  end

  def filter_time_limit(max_time)
    matches = query_limitation("time_limit", "<=", max_time)
    get_parking_locations(matches)
  end

  def filter_ease_rating(int)
    self.parking_locations.select do |location|
      location.average_ease >= int.to_f
    end
  end

  #do by location for specific destination
  def filter_walkability_rating(int)
    self.parking_locations.select do |location|
      location.average_walkability >= int.to_f
    end
  end

  def filter_safety_rating(int)
    self.parking_locations.select do |location|
      location.average_safety >= int.to_f
    end
  end

  def best_parking_location
    sorted_by_overall_score.last
  end

  def worst_parking_location
    sorted_by_overall_score.first
  end

  def sorted_by_overall_score
    self.parking_locations.sort_by(&:overall_score)
  end

end
