
module Tidyup
  module_function
  def tidyup str
    str.scan(/(\w+|[^\s\w])/).sort.join(' ')
  end
end
