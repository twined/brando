import Brando.Blueprint

singular "project"
plural "projects"

translation :messages do
  t :label, "Label"
  t :key, "Key"
  t :type, "Type"
  t :value, "Value"
  t :title, "Pages and sections"
  t :subtitle, "Content administration"
  t :created, "Page created"
  t :updated, "Page updated"
  t :index, "Index"
  t :actions, "Actions"
  t :fragments_rerendered, "Fragments rerendered"
  t :pages_rerendered, "Pages rerendered"
  t :page_rerendered, "Page rerendered"
  t :section_rerendered, "Section rerendered"
  t :new, "New page"
  t :rerender, "Rerender pages/sections"
  t :new_section, "New section"
  t :new_subpage, "New subpage"
  t :section, "Section"
  t :sequence_updated, "Sequence updated"
  t :delete_page, "Delete page"
  t :delete_pages, "Delete pages"
  t :duplicate_page, "Duplicate page"
  t :duplicate_section, "Duplicate section"
  t :edit_section, "Edit section"
  t :delete_section, "Delete section"
  t :are_you_sure_you_want_to_delete_this_section, "Are you sure you want to delete this section?"
  t :no_title, "No title"
  t :edit_page, "Edit page"
  t :rerender_page, "Rerender page"
  t :rerender_section, "Rerender section"
  t :section_deleted, "Section deleted"
  t :delete_confirm, "Are you sure you want to delete this page?"
  t :delete_confirm_many, "Are you sure you want to delete these pages?"
  t :page_deleted, "Page deleted"
  t :page_duplicated, "Page duplicated"
  t :section_duplicated, "Section duplicated"
  t :subpage, "Subpage"
  t :subpages, "Subpages"
  t :edit_subpage, "Edit subpage"
  t :delete_subpage, "Delete subpage"
end

translation :fields do
  t :advanced_config do
    label "Advanced configuration"
  end
  t :language do
    label "Language"
  end
  t :parent_id do
    label "Parent page"
  end
  t :title do
    label "Title"
  end
  t :template do
    label "Template"
  end
  t :uri do
    label "URI"
    placeholder "uri/goes/here"
    instructions "Path for routing"
  end
  t :is_homepage do
    label "Homepage"
  end
  t :css_classes do
    label "Extra CSS classes"
  end
  t :properties do
    label "Page properties (advanced)"
  end
  t :data do
    label "Contents"
  end
  t :publish_at do
    label "Publish at"
    instructions "Leave blank if you wish to publish immidiately"
  end
end
