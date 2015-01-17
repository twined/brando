defmodule Brando.Form.Fields do
  @doc """
  Returns a div classed as `form-group` (used in bootstrap).

  Sets classes:

    * `required` -- if the wrapped field is marked such
    * `has-error` -- if the field is found in `errors`
  """
  @spec __form_group__(String.t, String.t, Keyword.t, Keyword.t) :: String.t
  def __form_group__(contents, _name, opts, errors) do
    """
    <div data-field-span="1" class="form-group#{get_required(opts[:required])}#{get_has_error(errors)}">
      #{contents}
      #{__render_errors__(errors)}
    </div>
    """
  end

  @doc """
  Renders `errors` in a nicely formatted <div> by calling __parse_error__/1
  on each error in the `errors` list.
  """
  def __render_errors__([]), do: ""
  def __render_errors__(errors) when is_list(errors) do
    for error <- errors do
      ~s(<div class="error"><i class="fa fa-exclamation-circle"> </i> #{__parse_error__(error)}</div>)
    end
  end

  @doc """
  Converts error atoms to strings
  """
  @spec __parse_error__({atom, term} | atom) :: String.t
  def __parse_error__(error) do
    case error do
      :required -> "Feltet er påkrevet."
      :unique   -> "Feltet må være unikt. Verdien finnes allerede i databasen."
      :format   -> "Feltet har feil format."
      {:too_short, length} -> "Feltets verdi er for kort. Må være > #{length} tegn."
    end
  end

  @doc """
  Concats `wrapped_field` and `label`, with `label` being
  the first
  """
  @spec __concat__(String.t, String.t) :: String.t
  def __concat__(wrapped_field, label) do
    label <> wrapped_field
  end

  @doc """
  Returns a div with class=`class` and `content`
  """
  def __div__(contents, class) do
    ~s(<div class="#{class}">#{contents}</div>)
  end

  @doc """
  Wraps `field` in a div with `wrapper_class` as class.
  """
  def __wrap__(field, nil), do: field
  def __wrap__(field, wrapper_class) do
    ~s(<div class="#{wrapper_class}">#{field}</div>)
  end

  @doc """
  Renders a label for `name`, with `class` and `text` as the
  label's content.
  """
  def __label__(name, class, text) do
    ~s(<label for="#{name}" class="#{class}">#{text}</label>)
  end

  @doc """
  Renders a <select> tag. Passes `choices` to __tag__/4
  """
  def __select__(_, name, choices, opts, _value, _errors) do
    opts = List.delete(opts, :default)
    __tag__("select", name, choices, opts[:class])
  end

  def __option__(:update, choice_value, choice_text, value, _default) do
    ~s(<option value="#{choice_value}"#{get_selected(choice_value, value)}>#{choice_text}</option>)
  end

  # no `value` - :create - match `choice_value` to `default`
  def __option__(:create, choice_value, choice_text, [], default) do
    ~s(<option value="#{choice_value}"#{get_selected(choice_value, default)}>#{choice_text}</option>)
  end

  def __option__(:create, choice_value, choice_text, value, _default) do
    ~s(<option value="#{choice_value}"#{get_selected(choice_value, value)}>#{choice_text}</option>)
  end

  def __fieldset_open__(nil, in_fieldset) do
    ~s(<fieldset><div data-row-span="#{in_fieldset}">)
  end

  def __fieldset_open__(legend, in_fieldset) do
    ~s(<fieldset><legend><br>#{legend}</legend><div data-row-span="#{in_fieldset}">)
  end

  def __fieldset_close__() do
    ~s(</div></fieldset>)
  end

  def __data_row_span__(content, nil) do
    ~s(<div data-row-span="1">#{content}</div>)
  end

  def __data_row_span__(content, _span) do
    content
  end

  def __input__(:checkbox, _action, name, value, _errors, opts) do
    checked =
      case value do
        v when v in ["on", true] -> " " <> "checked=\"checked\""
        v when v in [false, nil] -> ""
        [] ->
          case opts[:default] do
            true  -> " " <> "checked=\"checked\""
            false -> ""
          end
      end
    ~s(<input name="#{name}" type="checkbox"#{get_placeholder(opts[:placeholder])}#{get_class(opts[:class])}#{checked} />)
  end

  def __input__(type, :update, name, value, _errors, opts) do
    opts = List.delete(opts, :default)
   __input__(type, :create, name, value, _errors, opts)
  end

  def __input__(type, :create, name, value, _errors, opts) do
    ~s(<input name="#{name}" type="#{type}"#{get_value(value)}#{get_placeholder(opts[:placeholder])}#{get_class(opts[:class])} />)
  end

  def __tag__(tag, name, contents, class) do
    ~s(<#{tag} name="#{name}" class="#{class}">#{contents}</#{tag}>)
  end

  def get_selected(cv, v) when cv == v, do: " " <> "selected"
  def get_selected(_, _), do: ""

  def get_required(true), do: " " <> "required"
  def get_required(false), do: ""
  def get_required(nil), do: ""

  def get_has_error([]), do: ""
  def get_has_error(_), do: " " <> "has-error"

  def get_placeholder(nil), do: ""
  def get_placeholder(placeholder), do: " " <> "placeholder=\"#{placeholder}\""

  def get_class(nil), do: ""
  def get_class(class), do: " " <> "class=\"#{class}\""

  def get_value([]), do: ""
  def get_value(nil), do: ""
  def get_value(value) when is_map(value), do: ""
  def get_value(value), do: " " <> "value=\"#{value}\""

end