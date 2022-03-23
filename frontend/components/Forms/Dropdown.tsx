import { useField, useFormikContext } from "formik";
import { Dropdown as SemanticDropdown, DropdownProps } from "semantic-ui-react";
export function Dropdown({ name, ...props }: DropdownProps) {
  const { setFieldValue } = useFormikContext();
  const [field] = useField(name);
  return (
    <SemanticDropdown
      name={name}
      onChange={(event, data) => setFieldValue(field.name, data.value)}
      {...props}
    />
  );
}
