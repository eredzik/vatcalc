import { useFormikContext, useField } from "formik";
import SemanticDatepicker from "react-semantic-ui-datepickers";

export function FormikSemanticDatepicker({
  name,
  ...props
}: {
  name: string;
  label: string;
}) {
  const { setFieldValue } = useFormikContext();
  const [field] = useField(name);
  return (
    <SemanticDatepicker
      name={name}
      onChange={(event, data) => setFieldValue(field.name, data.value)}
      {...props}
    />
  );
}
