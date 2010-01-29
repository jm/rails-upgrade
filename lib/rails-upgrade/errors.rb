class FileNotFoundError < StandardError; end

class NotInRailsAppError < StandardError
  def message
    "I'm not in a Rails application!"
  end
end