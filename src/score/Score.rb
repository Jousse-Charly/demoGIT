class Score
	#	@modeJeu
  #	@tempsBrut
  # @malus

  attr_reader :modeJeu, :tempsBrut, :malus
  
  def initialize(modeJeu, tempsBrut, malus)
    @modeJeu, @tempsBrut, @malus = modeJeu, tempsBrut, malus
  end

  def tempsBrut_to_s()
    return time_to_s(@tempsBrut)
  end

  def malus_to_s()
    return time_to_s(@malus)
  end

  def time_to_s(time)
    return Time.at(time).utc.strftime("%H:%M:%S")
  end

end
