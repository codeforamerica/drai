class DafiFormBuilder < Cfa::Styleguide::CfaFormBuilder
  def cfa_button(text, value: nil, **options)
    button(value, class: 'button button--primary') { text }
  end

# Expecting array of strings
  def gcf_collection_check_boxes(method, label_text, collection)

    formatted_label = label(
        method,
        label_contents(
            label_text,
            nil
        )
    )

    checkboxes = collection_check_boxes method,
                                        collection, ->(str) { str }, ->(str) { str } do |b|
      b.label(class: "checkbox") { b.check_box + b.text }
    end

    html_output = <<~HTML
          <div class="form-group#{error_state(object, method)}">
            #{formatted_label}
            #{checkboxes}
            #{errors_for(object, method)}
          </div>
    HTML

    html_output.html_safe
  end

  def gcf_date_input(method, label_text, classes: [], options: {}, help_text: "")
    classes_string = classes.join(' ')
    helper_text_array = help_text.split('/')

    month_field = text_field(method, text_field_options(method, {
      type: "number",
      class: classes_string,
    }.merge({}.merge(options).merge(
      value: object.send(method) ? object.send(method).month : nil,
      class: 'text-input date-input form-width--month',
      id: "#{object_name}_#{method}_2i",
      name: "#{object_name}[#{method}(2i)]",
      aria: { label: "#{I18n.t('shared.date_select.month')} #{helper_text_array[0]}" },
      size: 2
    ))))

    day_field = text_field(method, text_field_options(method, {
      type: "number",
      class: classes_string,
    }.merge({}.merge(options).merge(
      value: object.send(method) ? object.send(method).day : nil,
      class: 'text-input date-input form-width--day',
      id: "#{object_name}_#{method}_3i",
      name: "#{object_name}[#{method}(3i)]",
      aria: { label: "#{I18n.t('shared.date_select.day')} #{helper_text_array[1]}" },
      size: 2
    ))))

    year_field = text_field(method, text_field_options(method, {
      type: "number",
      class: classes_string,
    }.merge({}.merge(options).merge(
      value: object.send(method) ? object.send(method).year : nil,
      class: 'text-input date-input form-width--year',
      id: "#{object_name}_#{method}_1i",
      name: "#{object_name}[#{method}(1i)]",
      aria: { label: "#{I18n.t('shared.date_select.year')} #{helper_text_array[2]}" },
      size: 4
    ))))

    <<~HTML.html_safe
      <fieldset class="form-group#{error_state(object, method)} date-input--fieldset">
        #{fieldset_label_contents(label_text: label_text, help_text: help_text)}
        <div class="input-group--inline spacing-above-25">
            <div class="form-group date-input">
              #{label_and_field("#{method}_2i", I18n.t('shared.date_select.month'), month_field)}
            </div>
            <div class="date-input--separator">/</div>
            <div class="form-group date-input">
              #{label_and_field("#{method}_3i", I18n.t('shared.date_select.day'), day_field)}
            </div>
            <div class="date-input--separator">/</div>
            <div class="form-group date-input">
              #{label_and_field("#{method}_1i", I18n.t('shared.date_select.year'), year_field)}
            </div>
        </div>
        #{errors_for(object, method)}
      </fieldset>
    HTML
  end

  def text_field_options(method, options)
    add_a11y_error_attributes(method, {
      autocomplete: 'off',
      autocorrect: 'off',
      autocapitalize: 'off',
      spellcheck: 'false',
    }.merge(options))
  end

  def add_a11y_error_attributes(method, options)
    if object.errors[method].any?
      options['aria-describedby'] = ["#{method}-error", options['aria-describedby']].compact.join(' ')
    end

    options
  end

  def optional_text(optional)
    if optional
      " <span class='card__optional'>#{optional}</span>"
    else
      ""
    end
  end
end
