
class ExampleForm < Harbor::Form
  string :first_name
  integer :age, min_value: 18
end

