import { FieldArray, Formik, useFormikContext } from "formik";
import { Form, Input, SubmitButton } from "formik-semantic-ui-react";
import { Button } from "semantic-ui-react";
import { Form as FormSemantic, Dropdown, Label } from "semantic-ui-react";
import { Dropdown as DropdownFormik } from "../../components/Forms/Dropdown";
import { Layout } from "../../components/Layout";
import { z } from "zod";
import { toFormikValidationSchema } from "zod-formik-adapter";

import { FormikSemanticDatepicker } from "../../components/Forms/FormikSemanticDatepicker";
// import {
//   useTradingPartnersAdd,
//   useTradingPartnersList,
// } from "../../hooks/partnersApi";
// import { useUser } from "../../hooks/userApi";
import { useState } from "react";
import { GetServerSideProps, InferGetServerSidePropsType } from "next";
import { trpc } from "../../utils/trpc";
import { getSession, useSession } from "next-auth/react";
import { Session } from "next-auth";
import Router from "next/router";

export const getServerSideProps: GetServerSideProps = async (context) => {
  const session = await getSession(context);
  if (!session) {
    return { redirect: { destination: "/" }, props: {} };
  }
  console.log(session);
  return { props: { session: session } };
};

export default function InvoiceAdd() {
  const { data: session, status } = useSession({ required: true });
  if (status === "loading") {
    return <Layout></Layout>;
  }
  if (!session.user.fav_enterprise_id) {
    return <Layout>Musisz wybrać firmę!</Layout>;
  }

  const trade_partners =
    trpc.useQuery([
      "trade_partners.getTradePartners",
      { enterprise_id: session.user.fav_enterprise_id },
    ]).data || [];
  //   const user = useUser();
  //   const trading_partners_list = useTradingPartnersList(
  // 1,
  // user.data?.data.fav_enterprise_id || -1
  //   );
  //   const [tradepartnerQuery, setTradePartnerQuery] = useState("");
  const [addTradePartnerSectionActive, setaddTradePartnerSectionActive] =
    useState(false);
  //   const tradePartnerAddMutation = useTradingPartnersAdd();

  const validationSchema = z.object({
    invoice_business_id: z.string(),
    issue_date: z.date().nullable(),
    received_date: z.date().nullable(),
    invoice_type: z.string(),
    trade_partner_search_string: z.string().optional(),
    trade_partner: z.object({
      name: z.string(),
      address: z.string(),
      nip_number: z.string().length(10),
    }),
    invoice_positions: z.array(
      z.object({
        name: z.string(),
        num_items: z.number(),
        price_net: z.number(),
      })
    ),
  });

  const initialValues: z.infer<typeof validationSchema> = {
    issue_date: null,
    received_date: null,
    trade_partner_search_string: "",
    invoice_type: "",
    trade_partner: {
      name: "",
      address: "",
      nip_number: "",
    },
    invoice_business_id: "",
    invoice_positions: [],
  };
  //   const { setFieldValue } = useFormikContext();
  return (
    <Layout>
      <Formik
        initialValues={initialValues}
        validationSchema={toFormikValidationSchema(validationSchema)}
        onSubmit={(values) => {
          console.log("SUBMITTED: ", values);
        }}
      >
        {({ values, errors }) => (
          <Form size="large">
            {addTradePartnerSectionActive ? (
              <>
                <Input
                  name="trade_partner.nip_number"
                  label="Numer NIP kontrahenta"
                />
                <Input name="trade_partner.name" label="Nazwa kontrahenta" />
                <Input name="trade_partner.address" label="Adres kontrahenta" />
              </>
            ) : (
              <FormSemantic.Field>
                <label children="Kontrahent" />
                <Dropdown
                  name="trade_partner_search_string"
                  label="Nazwa kontrahenta"
                  options={trade_partners.map((t) => ({
                    text: t.name,
                    value: t.name,
                  }))}
                  search
                  selection
                  allowAdditions
                  placeholder="Wybierz lub dodaj kontrahenta"
                  // onSearchChange={(e, data) => setTradePartnerQuery(data.value as string)}
                  onAddItem={(e, v) => {
                    setaddTradePartnerSectionActive(true);
                  }}
                  noResultsMessage={"Nie masz żadnego kontrahenta"}
                  additionLabel="Dodaj nowego kontrahenta: "
                />
              </FormSemantic.Field>
            )}
            <br />
            <FormSemantic.Field>
              <label children="Wybierz rodzaj faktury" />
              <DropdownFormik
                name="invoice_type"
                placeholder="Rodzaj faktury"
                selection
                options={[
                  { text: "Sprzedaż", value: "OUTBOUND" },
                  { text: "Zakup", value: "INBOUND" },
                ]}
              />
            </FormSemantic.Field>
            <Input name="invoice_business_id" label="Numer faktury" />
            <FormikSemanticDatepicker
              name="issue_date"
              label="Data wystawienia"
            />
            <FormikSemanticDatepicker
              name="received_date"
              label="Data otrzymania"
            />
            {/* // <FormSemantic.Field> */}
            <br />
            <FieldArray
              name="invoice_positions"
              render={(arrayHelpers) => (
                <>
                  <label children="Pozycje" />
                  {values.invoice_positions.map((position, index) => (
                    <FormSemantic.Group key={index}>
                      <Label content={`${index}.`} size="big" />
                      <Input
                        label="Opis pozycji"
                        name={`invoice_positions[${index}].name`}
                      />

                      <Input
                        label="Liczba jednostek"
                        name={`invoice_positions[${index}].num_items`}
                        type="number"
                      />
                      <Input
                        label="Cena jednostkowa"
                        name={`invoice_positions[${index}].price_net`}
                        type="number"
                      />
                    </FormSemantic.Group>
                  ))}
                  <br />
                  <Button
                    color="blue"
                    content="Dodaj pozycję"
                    onClick={(e) => {
                      e.preventDefault();
                      arrayHelpers.push({
                        name: "",
                        num_items: 0,
                        price_net: 0,
                      });
                    }}
                  />
                </>
              )}
            />
            {JSON.stringify(errors)}
            <SubmitButton content="Dodaj" primary />
          </Form>
        )}
      </Formik>
    </Layout>
  );
}

InvoiceAdd.auth = true;
