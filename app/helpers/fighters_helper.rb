module FightersHelper
  def score_color(score)
    case score
    when 0..45
      "text-red-500"
    when 46..50
      "text-orange-400"
    when 51..60
      "text-gray-500"
    when 61..70
      "text-purple-500"
    when 71..80
      "text-green-500 font-semibold"
    else
      "text-green-500 font-bold underline"
    end
  end
end
