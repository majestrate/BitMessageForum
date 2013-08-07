module BMF;end

class BMF::ThreadedMessage
  attr_reader :message, :children
  attr_accessor :parent

  def initialize message, p=nil
    @message = message
    @children = []
    @parent = p
  end

  def get_best_match new_message
    return nil if !new_message.message['message'].include?(self.message['message'])

    good_child = @children.map{ |c| c.get_best_match(new_message)}.compact
    if !good_child.empty?
      return good_child.first
    end

    return self
  end

  def depth x=1
    if @parent
      x + @parent.depth
    else
      x
    end
  end
  
  def puts_threaded indent=0
    indent_string = " " * indent
    # puts indent_string + "***"

    puts "<blockquote><pre>"

    breaks = 0
    self.message['message'].split("\n").each do |line|
      breaks += 1 if line == "------------------------------------------------------"
      break if breaks >= 1
      puts indent_string + line
    end

    self.children.each do |child|
      child.puts_threaded indent+1
    end

    puts "</pre></blockquote>"
  end

  def message_text
    quoted_text = self.parent ? self.parent.message['message'] : nil
    
    new_text = (quoted_text && !quoted_text.empty?) ? message['message'].sub(quoted_text,"") : message['message']

    [new_text, quoted_text]
  end
  

end

class BMF::MessageThread
  attr_reader :children
  def initialize
    @children = []
  end

  def insert message
    msg = BMF::ThreadedMessage.new(message)
    match = @children.map { |child| child.get_best_match(msg) }.compact.first

    if match.nil?
      puts "."
      @children << msg
    else
      raise "WHAT?" if match.message['message'].length > msg.message['message'].length
      msg.parent = match
      match.children << msg
      puts "." * msg.depth

    end
  end

end

