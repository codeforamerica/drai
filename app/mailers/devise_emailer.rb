class DeviseEmailer < Devise::Mailer
  def confirmation_instructions(record, token, opts={})
    opts[:subject] = 'DRAI Portal account set up instructions'
    super
  end
end
