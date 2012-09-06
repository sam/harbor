
class ExampleForm < Harbor::Form
  # Available field types: string, text, password, integer, decimal, regex, email, file, boolean, null_boolean, choice, typed_choice, multiple_choice, radio_choice, and checkbox_multiple_choice.
  # Fields are required by default
  string :first_name, label: 'Your first name'
  integer :age, min_value: 18
  email :email
  boolean :admin, required: false
  regex :tele, /^\d{3}-\d{3}-\d{4}$/, required: false
  choice :state, [['', 'Select a state'],
                  ['AL', 'Alabama'],
                  ['AK', 'Arkansas'],
                  ['AR', 'Arizona']], required: false
  text :memo, label: 'Memo for this user', required: false
end

