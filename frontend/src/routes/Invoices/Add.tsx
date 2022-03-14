import { Formik } from "formik";
import { Form, SubmitButton } from "formik-semantic-ui-react";
import { Dropdown } from "semantic-ui-react";
import { Layout } from "../../components/Layout";
import { z } from "zod";
import { toFormikValidationSchema } from "zod-formik-adapter";

import { FormikSemanticDatepicker } from "../../components/Forms/FormikSemanticDatepicker";
import {
  useTradingPartnersAdd,
  useTradingPartnersList,
} from "../../hooks/partnersApi";
import { useUser } from "../../hooks/userApi";
import { useState } from "react";

export function InvoiceAdd() {
  const validationSchema = z.object({
    issue_date: z.date().nullable(),
    received_date: z.date().nullable(),
    trade_partner_search_string: z.string(),
  });

  const initialValues: z.infer<typeof validationSchema> = {
    issue_date: null,
    received_date: null,
    trade_partner_search_string: "",
  };
  const user = useUser();
  const trading_partners_list = useTradingPartnersList(
    1,
    user.data?.data.fav_enterprise_id || -1
  );
  const [tradepartnerQuery, setTradePartnerQuery] = useState("");
  const [addTradePartnerSectionActive, setaddTradePartnerSectionActive] =
    useState(false);
  const tradePartnerAddMutation = useTradingPartnersAdd();

  return (
    <Layout>
      <Dropdown
        name="trade_partner_search_string"
        label="Kontrahent"
        options={trading_partners_list.data?.data.map((t) => ({
          text: t.name,
          value: t.name,
        }))}
        search
        selection
        allowAdditions
        placeholder="Wybierz lub dodaj kontrahenta"
        onSearchChange={(e, data) => setTradePartnerQuery(data.value as string)}
        onAddItem={() => setaddTradePartnerSectionActive(true)}
        noResultsMessage={"Nie masz żadnego kontrahenta"}
        additionLabel="Dodaj nowego kontrahenta o nazwie "
      />
      <Formik
        initialValues={initialValues}
        validationSchema={toFormikValidationSchema(validationSchema)}
        onSubmit={(values) => {
          console.log("SUBMITTED: ", values);
        }}
      >
        <Form size="large">
          <FormikSemanticDatepicker
            name="issue_date"
            label="Data wystawienia"
          />
          <FormikSemanticDatepicker
            name="received_date"
            label="Data otrzymania"
          />
          <SubmitButton content="Dodaj" />
        </Form>
      </Formik>
    </Layout>
  );
}
