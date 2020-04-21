module ApplicationHelper

  def capture_form(&block)
    lambda do |form|
      capture do
        block.call(form)
      end
    end
  end
end
