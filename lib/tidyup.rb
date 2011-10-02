
module Tidyup
  module_function
  def tidyup str
    str.scan(/\w+|[^\s\w]/).sort
  end
end
