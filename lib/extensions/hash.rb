class Hash
  def except(*blacklist)
    self.reject {|key, value| blacklist.include?(key.to_s) }
  end
  
  def only(*whitelist)
    self.reject {|key, value| !whitelist.include?(key.to_s) }
  end
end
