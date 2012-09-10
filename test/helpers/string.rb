class String

  ##
  # Remove whitespace margin.
  #
  # @return [String] receiver with whitespace margin removed
  #
  # @api public
  def margin
    lines = self.dup.split($/)

    min_margin = 0
    lines.each do |line|
      if line =~ /^(\s+)/ && (min_margin == 0 || $1.size < min_margin)
        min_margin = $1.size
      end
    end
    lines.map { |line| line.sub(/^\s{#{min_margin}}/, '') }.join($/)
  end

end