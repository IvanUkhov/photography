module ApplicationHelper
  def encode(string)
    string.chars.map { |c| "&##{c.ord};" }.join
  end

  def stamp
    @stamp ||= Time.now.to_i
  end
end
