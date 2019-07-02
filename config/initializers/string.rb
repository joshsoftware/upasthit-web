class String
  def constantize_with_care(klasses = [])
    klasses.each do |klass|
      return constantize if self == klass
    end
    raise NameError, "Invalid type: #{self}"
  end
end
