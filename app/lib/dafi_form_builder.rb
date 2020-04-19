class DafiFormBuilder < Cfa::Styleguide::CfaFormBuilder
  def cfa_button(text, value: nil, **options)
    button(value, class: 'button button--primary') { text }
  end
end
