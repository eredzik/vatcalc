import { useFormik } from "formik";
import { useHistory, useParams } from "react-router";
import { Form, Message } from "semantic-ui-react";
import { Layout } from "../../../../components/Layout";
import { useVatRateAddMutation } from "../../../hooks/vatratesApi";
import * as yup from "yup";
export function VatrateAdd() {
  const history = useHistory();
  const { enterprise_id } = useParams<{ enterprise_id: string }>();
  const vatrateadd = useVatRateAddMutation();

  const formik = useFormik<{ vat_rate?: number; comment?: string }>({
    initialValues: {
      vat_rate: undefined,
      comment: undefined,
    },
    validationSchema: yup.object().shape({
      vat_rate: yup
        .number()
        .transform((o, v) => parseFloat(v.replace(/,/g, ".")))
        .required("Stawka VAT musi być niepusta")
        .typeError(
          "Musisz podać liczbę (należy używać kropki zamiast przecinka)"
        )
        .min(0, "Stawka VAT nie może być ujemna")
        .max(1, "Stawka VAT nie może przekraczać 100%"),
      comment: yup.string().required("Komentarz nie może być pusty"),
    }),
    validateOnBlur: true,
    validateOnChange: false,
    validateOnMount: true,

    onSubmit: async (v) =>
      vatrateadd.mutate({
        enterprise_id: parseInt(enterprise_id),
        comment: v.comment as string,
        vat_rate: v.vat_rate as number,
      }),
  });
  console.log(formik);
  return (
    <Layout>
      <Form
        onSubmit={formik.handleSubmit}
        error={vatrateadd.isError}
        success={vatrateadd.isSuccess}
      >
        <Form.Input
          label="Stawka VAT"
          id="vat_rate"
          value={formik.values.vat_rate}
          onChange={formik.handleChange}
          onBlur={formik.handleBlur}
          error={formik.touched.vat_rate && formik.errors.vat_rate}
        />
        <Form.Input
          label="Komentarz"
          id="comment"
          onChange={formik.handleChange}
          onBlur={formik.handleBlur}
          value={formik.values.comment}
          error={formik.touched.comment && formik.errors.comment}
        />
        <Message
          error
          content={"Błąd dodawania kontrahenta." + vatrateadd.error}
        />
        <Message success content={"Dodano stawkę VAT!"} />
        <Form.Group>
          <Form.Button
            content="Dodaj"
            primary
            disabled={!formik.isValid}
            type="submit"
          />
          <Form.Button
            content="Cofnij"
            secondary
            type="button"
            onClick={() => history.goBack()}
          />
        </Form.Group>
      </Form>
    </Layout>
  );
}
