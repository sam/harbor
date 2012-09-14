require 'bureaucrat'
require 'bureaucrat/fields'
require 'bureaucrat/widgets'

  # Shortcuts for declaring form fields
module Quickfields
  include Bureaucrat::Fields

  # Hide field named +name+
  def hide(name)
    base_fields[name] = base_fields[name].dup
    base_fields[name].widget = Bureaucrat::Widgets::HiddenInput.new
  end

  # Delete field named +name+
  def delete(name)
    base_fields.delete name
  end

  # Declare a +CharField+ with text input widget
  def string(name, options = {})
    field_with_html_attrs(name, CharField, Bureaucrat::Widgets::TextInput, options)
  end

  # Declare a +CharField+ with text area widget
  def text(name, options = {})
    field_with_html_attrs(name, CharField, Bureaucrat::Widgets::Textarea, options)
  end

  # Declare a +CharField+ with password widget
  def password(name, options = {})
    field_with_html_attrs(name, CharField, Bureaucrat::Widgets::PasswordInput, options)
  end

  # Declare an +IntegerField+
  def integer(name, options = {})
    field_with_html_attrs(name, IntegerField, Bureaucrat::Widgets::TextInput, options)
  end

  # Declare a +BigDecimalField+
  def decimal(name, options = {})
    field_with_html_attrs(name, BigDecimalField, Bureaucrat::Widgets::TextInput, options)
  end

  # Declare a +RegexField+
  def regex(name, regexp, options = {})
    html_attrs = options.delete(:html_attrs)
    field name, RegexField.new(regexp, options.merge(widget: Bureaucrat::Widgets::TextInput.new(html_attrs)))
  end

  # Declare an +EmailField+
  def email(name, options = {})
    field_with_html_attrs(name, EmailField, Bureaucrat::Widgets::TextInput, options)
  end

  # Declare a +FileField+
  def file(name, options = {})
    field_with_html_attrs(name, FileField, Bureaucrat::Widgets::ClearableFileInput, options)
  end

  # Declare a +BooleanField+
  def boolean(name, options = {})
    field_with_html_attrs(name, BooleanField, Bureaucrat::Widgets::CheckboxInput, options)
  end

  # Declare a +NullBooleanField+
  def null_boolean(name, options = {})
    field_with_html_attrs(name, NullBooleanField, Bureaucrat::Widgets::NullBooleanSelect, options)
  end

  # Declare a +ChoiceField+ with +choices+
  def choice(name, choices = [], options = {})
    field_with_html_attrs(name, ChoiceField, Bureaucrat::Widgets::Select, options)
  end

  # Declare a +TypedChoiceField+ with +choices+
  def typed_choice(name, choices = [], options = {})
    field_with_html_attrs(name, TypedChoiceField, Bureaucrat::Widgets::Select, options)
  end

  # Declare a +MultipleChoiceField+ with +choices+
  def multiple_choice(name, choices = [], options = {})
    field_with_html_attrs(name, MultipleChoiceField, Bureaucrat::Widgets::Select, options)
  end

  # Declare a +ChoiceField+ using the +RadioSelect+ widget
  def radio_choice(name, choices = [], options = {})
    html_attrs = options.delete(:html_attrs)
    field name, ChoiceField.new(choices, options.merge(widget: Bureaucrat::Widgets::RadioSelect.new(html_attrs)))
  end

  # Declare a +MultipleChoiceField+ with the +CheckboxSelectMultiple+ widget
  def checkbox_multiple_choice(name, choices = [], options = {})
    html_attrs = options.delete(:html_attrs)
    field name, MultipleChoiceField.new(choices, options.merge(widget: Bureaucrat::Widgets::CheckboxSelectMultiple.new(html_attrs)))
  end

  private
  
  def field_with_html_attrs(name, field_clazz, widget_clazz, options)
    html_attrs = options.delete(:html_attrs)
    field name, field_clazz.new(options.merge(widget: widget_clazz.new(html_attrs)))
  end

end
