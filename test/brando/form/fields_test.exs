defmodule Brando.Form.FieldsTest do
  use ExUnit.Case, async: true
  require Brando.Form.Fields, as: F

  @opts [context: Brando.Form.Fields]

  defmodule UserForm do
    use Bitwise, only_operators: true
    use Brando.Form

    def get_role_choices(_) do
      [[value: "1", text: "Staff"],
       [value: "2", text: "Admin"],
       [value: "4", text: "Superuser"]]
    end

    def role_selected?(choice_value, values) do
      {:ok, role_int} = Brando.Type.Role.dump(values)
      choice_int = String.to_integer(choice_value)
      (role_int &&& choice_int) == choice_int
    end

    def get_status_choices(_) do
      [[value: "1", text: "Valg 1"],
       [value: "2", text: "Valg 2"]]
    end

    def selected_fun_true(_form_value, _model_value) do
      true
    end

    def selected_fun_false(_form_value, _model_value) do
      false
    end

    form "user", [helper: :admin_user_path, class: "grid-form"] do
      field :full_name, :text,
        [required: true,
         label: "Full name",
         label_class: "control-label",
         placeholder: "Full name",
         help_text: "Enter full name",
         class: "form-control",
         wrapper_class: ""]
      field :username, :text,
        [required: true,
         label: "Brukernavn",
         label_class: "control-label",
         placeholder: "Brukernavn",
         class: "form-control",
         wrapper_class: ""]
      field :email, :email,
        [required: true,
         label: "E-mail",
         label_class: "control-label",
         placeholder: "E-post",
         class: "form-control",
         wrapper_class: ""]
      field :password, :password,
        [required: true,
         label: "Passord",
         label_class: "control-label",
         placeholder: "Passord",
         class: "form-control",
         wrapper_class: ""]
      field :role, :select,
        [choices: &__MODULE__.get_role_choices/1,
         multiple: true,
         label: "Role",
         language: "en",
         label_class: "control-label",
         class: "form-control",
         wrapper_class: ""]
      field :status2, :select,
        [choices: &__MODULE__.get_status_choices/1,
         default: "1",
         label: "Status",
         language: "en",
         label_class: "control-label",
         class: "form-control",
         wrapper_class: ""]
      field :role2, :radio,
        [choices: &__MODULE__.get_role_choices/1,
         language: "en",
         label: "Rolle 2"]
      field :avatar, :file,
        [label: "Avatar",
         label_class: "control-label",
         wrapper_class: ""]
      submit "Save",
        [class: "btn btn-default",
         wrapper_class: ""]
    end
  end

  test "render_options/4" do
    assert F.render_options(:create, %{choices: &UserForm.get_status_choices/1, language: "en"}, "val", nil)
           == [["<option value=\"1\">", "Valg 1", "</option>"], ["<option value=\"2\">", "Valg 2", "</option>"]]
  end

  test "get_choices/1" do
    opts = %{language: "en", choices: &UserForm.get_status_choices/1}
    assert F.get_choices(opts) == [[value: "1", text: "Valg 1"], [value: "2", text: "Valg 2"]]
  end

  test "concat_fields/2" do
    label = "<label>Label</label>"
    wrapped_field = "<div><input /></div>"
    assert F.concat_fields(wrapped_field, label)
           == ["<label>Label</label>", "<div><input /></div>"]
  end

  test "div_tag/2" do
    assert F.div_tag("contents", "class") == ["<div class=\"class\">", "contents", "</div>"]
    assert F.div_tag("<b>contents</b>", "class class2") == ["<div class=\"class class2\">", "<b>contents</b>", "</div>"]
  end

  test "form_group/4" do
    assert F.form_group("1234", "name", [], [])
           == ["<div class=\"form-group required\">", ["1234", "", ""], "</div>"]
    opts = %{required: false}
    fg = F.form_group("1234", "name", opts, ["can't be blank"]) |> Enum.join
    refute fg =~ "required"
    assert fg =~ "has-error"
    assert fg =~ "fa-exclamation-circle"

    fg = F.form_group("1234", "name", opts, []) |> Enum.join
    refute fg =~ "required"
    refute fg =~ "has-error"

    fg = F.form_group("1234", "name", [], []) |> Enum.join
    assert fg =~ "required"
    refute fg =~ "has-error"

    opts = %{required: false}
    fg = F.form_group("1234", "name", opts, []) |> Enum.join
    refute fg =~ "required"
    refute fg =~ "has-error"

    fg = assert F.form_group("1234", "name", opts, ["must be unique"]) |> Enum.join
    assert fg =~ "has-error"
    assert fg =~ "fa-exclamation-circle"
  end

  test "wrap/2" do
    assert F.wrap("test", nil) == "test"
    assert F.wrap("test", "wrapper_class")
           == ["<div class=\"wrapper_class\">", "test", "</div>"]
  end

  test "textarea/5" do
    assert F.textarea(:create, "name", [], nil, %{})
           == ["<textarea name=\"name\">", "", "</textarea>"]
    assert F.textarea(:update, "name", "blah", nil, %{})
           == ["<textarea name=\"name\">", "blah", "</textarea>"]
    assert F.textarea(:update, "name", %{test: "testing"}, nil, %{})
           == ["<textarea name=\"name\">", "{&quot;test&quot;:&quot;testing&quot;}", "</textarea>"]
    assert F.textarea(:update, "name", "blah", nil, %{default: "default"})
           == ["<textarea name=\"name\">", "blah", "</textarea>"]
    assert F.textarea(:update, "name", [], nil, %{default: "default"})
           == ["<textarea name=\"name\">", "", "</textarea>"]
    assert F.textarea(:create, "name", [], nil, %{default: "default"})
           == ["<textarea name=\"name\">", "default", "</textarea>"]
    assert F.textarea(:update, "name", [], nil, %{default: "default", class: "class"})
           == ["<textarea class=\"class\" name=\"name\">", "", "</textarea>"]
  end

  test "file/4" do
    assert F.file(:update, "user[avatar]", %{sizes: %{"thumb" => "images/default/thumb/0.jpeg"}}, [], %{type: :file, label: "Bilde"})
           == [["<div class=\"image-preview\">", "<img src=\"/media/images/default/thumb/0.jpeg\">", "</div>"], "<input name=\"user[avatar]\" type=\"file\">"]
  end

  test "get_val/2" do
    assert F.get_val([]) == ""
    assert F.get_val(nil) == ""
    assert F.get_val("test") == "test"
    assert F.get_val("test", nil) == "test"
    assert F.get_val(["test", "ing"], nil) == "test,ing"
    assert F.get_val("test", "default") == "test"
    assert F.get_val([], "default") == "default"
  end

  test "input checkbox" do
    assert F.input(:checkbox, :create, "name", [], [], []) ==
      ["<input name=\"name\" type=\"hidden\" value=\"false\">", "<input name=\"name\" type=\"checkbox\" value=\"true\">"]
    assert F.input(:checkbox, :create, "name", false, [], []) ==
      ["<input name=\"name\" type=\"hidden\" value=\"false\">", "<input name=\"name\" type=\"checkbox\" value=\"true\">"]
    assert F.input(:checkbox, :create, "name", nil, [], []) ==
      ["<input name=\"name\" type=\"hidden\" value=\"false\">", "<input name=\"name\" type=\"checkbox\" value=\"true\">"]
    assert F.input(:checkbox, :create, "name", true, [], []) ==
      ["<input name=\"name\" type=\"hidden\" value=\"false\">", "<input checked=\"checked\" name=\"name\" type=\"checkbox\" value=\"true\">"]
    assert F.input(:checkbox, :create, "name", "on", [], []) ==
      ["<input name=\"name\" type=\"hidden\" value=\"false\">", "<input checked=\"checked\" name=\"name\" type=\"checkbox\" value=\"true\">"]
  end

  test "render_errors/1" do
    assert F.render_errors([]) == ""
    assert F.render_errors(["can't be blank", "must be unique"]) |> Enum.join
           =~ "Feltet er påkrevet."
    assert F.render_errors(["can't be blank", "must be unique"]) |> Enum.join
           =~ "Feltet må være unikt. Verdien finnes allerede i databasen."
  end

  test "parse_error/1" do
    assert F.parse_error("can't be blank") == "Feltet er påkrevet."
    assert F.parse_error("must be unique") == "Feltet må være unikt. Verdien finnes allerede i databasen."
    assert F.parse_error("has invalid format") == "Feltet har feil format."
    assert F.parse_error("is reserved") == "Verdien er reservert."
    assert F.parse_error({"should be at least %{count} characters", count: 10}) == "Feltets verdi er for kort. Må være > 10 tegn."
  end

  test "render_help_text/1" do
    opts = %{help_text: "Help text"}
    assert F.render_help_text(nil) == ""
    assert F.render_help_text(opts)
           == ["<div class=\"help\">", [["<i class=\"fa fa-fw fa-question-circle\">", " ", "</i>"], ["<span>", "Help text", "</span>"]], "</div>"]
  end

  test "label/3" do
    assert F.label("name", "class", "text")
           == ["<label class=\"class\" for=\"name\">", "text", "</label>"]
  end

  test "select/6" do
    assert F.select(:create, "name", "choices", %{}, [], [])
           == ["<select name=\"name\">", "choices", "</select>"]
    assert F.select(:create, "name", "choices", %{multiple: true}, [], [])
           == ["<select multiple=\"multiple\" name=\"name[]\">", "choices", "</select>"]
  end

  test "option/6" do
    assert F.option(:create, "choice_val", "choice_text", [], nil, nil)
           == ["<option value=\"choice_val\">", "choice_text", "</option>"]
    assert F.option(:create, "choice_val", "choice_text", [], "choice_val", nil)
           == ["<option selected=\"selected\" value=\"choice_val\">", "choice_text", "</option>"]
    assert F.option(:create, "choice_val", "choice_text", "choice_wrong", "choice_val", nil)
           == ["<option value=\"choice_val\">", "choice_text", "</option>"]
    assert F.option(:create, "choice_val", "choice_text", "choice_val", "choice_val", nil)
           == ["<option selected=\"selected\" value=\"choice_val\">", "choice_text", "</option>"]
    assert F.option(:update, "choice_val", "choice_text", "choice_val", "choice_val", &__MODULE__.UserForm.selected_fun_true/2)
           == ["<option selected=\"selected\" value=\"choice_val\">", "choice_text", "</option>"]
    assert F.option(:update, "choice_val", "choice_text", "choice_val", "choice_val", &__MODULE__.UserForm.selected_fun_false/2)
           == ["<option value=\"choice_val\">", "choice_text", "</option>"]
  end

  test "radio/7" do
    assert F.radio(:create, "choice_name", "choice_val", "choice_text", [], nil, nil)
           == ["<div>", [["<label for=\"choice_name\">", "", "</label>"], ["<label for=\"choice_name\">", ["<input name=\"choice_name\" type=\"radio\" value=\"choice_val\">", "choice_text"], "</label>"]], "</div>"]
    assert F.radio(:create, "choice_name", "choice_val", "choice_text", [], "choice_val", nil)
           == ["<div>", [["<label for=\"choice_name\">", "", "</label>"], ["<label for=\"choice_name\">", ["<input checked=\"checked\" name=\"choice_name\" type=\"radio\" value=\"choice_val\">", "choice_text"], "</label>"]], "</div>"]
    assert F.radio(:create, "choice_name", "choice_val", "choice_text", "choice_wrong", "choice_val", nil)
           == ["<div>", [["<label for=\"choice_name\">", "", "</label>"], ["<label for=\"choice_name\">", ["<input name=\"choice_name\" type=\"radio\" value=\"choice_val\">", "choice_text"], "</label>"]], "</div>"]
    assert F.radio(:create, "choice_name", "choice_val", "choice_text", "choice_val", "choice_val", nil)
           == ["<div>", [["<label for=\"choice_name\">", "", "</label>"], ["<label for=\"choice_name\">", ["<input checked=\"checked\" name=\"choice_name\" type=\"radio\" value=\"choice_val\">", "choice_text"], "</label>"]], "</div>"]

    assert F.radio(:create, "choice_name", "choice_val", "choice_text", "choice_val", "choice_val", &__MODULE__.UserForm.selected_fun_true/2)
           == ["<div>", [["<label for=\"choice_name\">", "", "</label>"], ["<label for=\"choice_name\">", ["<input checked=\"checked\" name=\"choice_name\" type=\"radio\" value=\"choice_val\">", "choice_text"], "</label>"]], "</div>"]
    assert F.radio(:create, "choice_name", "choice_val", "choice_text", "choice_val", "choice_val", &__MODULE__.UserForm.selected_fun_false/2)
           == ["<div>", [["<label for=\"choice_name\">", "", "</label>"], ["<label for=\"choice_name\">", ["<input name=\"choice_name\" type=\"radio\" value=\"choice_val\">", "choice_text"], "</label>"]], "</div>"]
  end

  test "render_checks/5" do
    opts = %{choices: &Brando.Form.FieldsTest.UserForm.get_role_choices/1,
             is_selected: &Brando.Form.FieldsTest.UserForm.role_selected?/2,
             label: "Role", language: "en", label_class: "control-label",
             class: "form-control", wrapper_class: "", multiple: true}
    assert F.render_checks(:create, :checks_test, opts, [], [])
           == ["",
            [["<div>",
              [["<label for=\"checks_test\">", "", "</label>"],
               ["<label for=\"checks_test\">", ["<input name=\"checks_test[]\" type=\"checkbox\" value=\"1\">", "Staff"], "</label>"]], "</div>"],
             ["<div>",
              [["<label for=\"checks_test\">", "", "</label>"],
               ["<label for=\"checks_test\">", ["<input name=\"checks_test[]\" type=\"checkbox\" value=\"2\">", "Admin"], "</label>"]], "</div>"],
             ["<div>",
              [["<label for=\"checks_test\">", "", "</label>"],
               ["<label for=\"checks_test\">", ["<input name=\"checks_test[]\" type=\"checkbox\" value=\"4\">", "Superuser"], "</label>"]], "</div>"]]]
    assert F.render_checks(:create, :checks_test, Map.put(opts, :default, "2"), [], [])
           == ["",
            [["<div>",
              [["<label for=\"checks_test\">", "", "</label>"],
               ["<label for=\"checks_test\">", ["<input name=\"checks_test[]\" type=\"checkbox\" value=\"1\">", "Staff"], "</label>"]], "</div>"],
             ["<div>",
              [["<label for=\"checks_test\">", "", "</label>"],
               ["<label for=\"checks_test\">", ["<input checked=\"checked\" name=\"checks_test[]\" type=\"checkbox\" value=\"2\">", "Admin"], "</label>"]],
              "</div>"],
             ["<div>",
              [["<label for=\"checks_test\">", "", "</label>"],
               ["<label for=\"checks_test\">", ["<input name=\"checks_test[]\" type=\"checkbox\" value=\"4\">", "Superuser"], "</label>"]], "</div>"]]]
    assert F.render_checks(:update, :checks_test, Map.put(opts, :default, "2"), [], [])
           == ["",
            [["<div>",
              [["<label for=\"checks_test\">", "", "</label>"],
               ["<label for=\"checks_test\">", ["<input name=\"checks_test[]\" type=\"checkbox\" value=\"1\">", "Staff"], "</label>"]], "</div>"],
             ["<div>",
              [["<label for=\"checks_test\">", "", "</label>"],
               ["<label for=\"checks_test\">", ["<input name=\"checks_test[]\" type=\"checkbox\" value=\"2\">", "Admin"], "</label>"]], "</div>"],
             ["<div>",
              [["<label for=\"checks_test\">", "", "</label>"],
               ["<label for=\"checks_test\">", ["<input name=\"checks_test[]\" type=\"checkbox\" value=\"4\">", "Superuser"], "</label>"]], "</div>"]]]
    assert F.render_checks(:update, :checks_test, Map.put(opts, :default, "2"), [:admin], [])
           == ["",
            [["<div>",
              [["<label for=\"checks_test\">", "", "</label>"],
               ["<label for=\"checks_test\">", ["<input name=\"checks_test[]\" type=\"checkbox\" value=\"1\">", "Staff"], "</label>"]], "</div>"],
             ["<div>",
              [["<label for=\"checks_test\">", "", "</label>"],
               ["<label for=\"checks_test\">", ["<input checked=\"checked\" name=\"checks_test[]\" type=\"checkbox\" value=\"2\">", "Admin"], "</label>"]],
              "</div>"],
             ["<div>",
              [["<label for=\"checks_test\">", "", "</label>"],
               ["<label for=\"checks_test\">", ["<input name=\"checks_test[]\" type=\"checkbox\" value=\"4\">", "Superuser"], "</label>"]], "</div>"]]]
    assert F.render_checks(:update, :checks_test, Map.put(opts, :default, "2"), [:admin, :superuser], [])
           == ["",
            [["<div>",
              [["<label for=\"checks_test\">", "", "</label>"],
               ["<label for=\"checks_test\">", ["<input name=\"checks_test[]\" type=\"checkbox\" value=\"1\">", "Staff"], "</label>"]], "</div>"],
             ["<div>",
              [["<label for=\"checks_test\">", "", "</label>"],
               ["<label for=\"checks_test\">", ["<input checked=\"checked\" name=\"checks_test[]\" type=\"checkbox\" value=\"2\">", "Admin"], "</label>"]],
              "</div>"],
             ["<div>",
              [["<label for=\"checks_test\">", "", "</label>"],
               ["<label for=\"checks_test\">", ["<input checked=\"checked\" name=\"checks_test[]\" type=\"checkbox\" value=\"4\">", "Superuser"], "</label>"]],
              "</div>"]]]
  end
end
